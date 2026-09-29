import express from 'express';
import cors from 'cors';
import OpenAI from 'openai';
import fs from 'node:fs/promises';
import path from 'node:path';
import { spawn } from 'node:child_process';

const app = express();
const API_TOKEN = process.env.WORKSPACE_API_TOKEN;

app.use(cors({ origin: true }));
app.use(express.json({ limit: '1mb' }));

function requireAuth(req, res, next) {
  if (!API_TOKEN) return res.status(503).json({ ok: false, error: 'WORKSPACE_API_TOKEN is not configured' });
  const auth = req.headers.authorization || '';
  if (auth !== `Bearer ${API_TOKEN}`) return res.status(401).json({ ok: false, error: 'Unauthorized' });
  next();
}

const WORKSPACE_ROOT = path.resolve(process.env.WORKSPACE_ROOT || './workspace');
const BUILD_COMMAND = 'npm test';

function getClient() {
  if (!process.env.OPENAI_API_KEY) throw new Error('OPENAI_API_KEY is not configured');
  return new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
}

function safePath(relativePath) {
  const target = path.resolve(WORKSPACE_ROOT, relativePath || '');
  if (target !== WORKSPACE_ROOT && !target.startsWith(`${WORKSPACE_ROOT}${path.sep}`)) {
    throw new Error('Path is outside the allowed workspace');
  }
  return target;
}

function runCommand(command, cwd, timeoutMs = 120000) {
  return new Promise((resolve) => {
    const child = spawn(command, { cwd, shell: true, env: process.env });
    let stdout = '';
    let stderr = '';
    let timedOut = false;
    const timer = setTimeout(() => { timedOut = true; child.kill('SIGTERM'); }, timeoutMs);
    child.stdout.on('data', (d) => { stdout += d.toString(); });
    child.stderr.on('data', (d) => { stderr += d.toString(); });
    child.on('close', (code) => {
      clearTimeout(timer);
      resolve({ ok: !timedOut && code === 0, code, timedOut, stdout, stderr });
    });
    child.on('error', (error) => {
      clearTimeout(timer);
      resolve({ ok: false, code: null, timedOut, stdout, stderr: `${stderr}\n${error.message}`.trim() });
    });
  });
}

async function analyzeError(instruction, errorLog) {
  const client = getClient();
  const response = await client.responses.create({
    model: process.env.OPENAI_MODEL || 'gpt-5.6',
    input: [
      { role: 'system', content: 'You are an error-analysis layer for a controlled software workspace. Return concise JSON with diagnosis, likelyFiles, patchPlan, and verificationSteps. Do not claim to have applied a fix.' },
      { role: 'user', content: JSON.stringify({ instruction, errorLog }) }
    ]
  });
  return response.output_text;
}

app.get('/health', (_req, res) => res.json({ ok: true, service: 'ai-developer-workspace' }));

app.post('/api/plan', requireAuth, async (req, res) => {
  try {
    const instruction = String(req.body?.instruction || '').trim();
    if (!instruction) return res.status(400).json({ error: 'instruction is required' });
    const client = getClient();
    const response = await client.responses.create({
      model: process.env.OPENAI_MODEL || 'gpt-5.6',
      input: [
        { role: 'system', content: 'You are the planning layer for a controlled software-development workspace. Return concise JSON with goal, steps, files, tests, and risks. Do not claim to have edited or executed files.' },
        { role: 'user', content: instruction }
      ]
    });
    res.json({ ok: true, plan: response.output_text });
  } catch (error) {
    res.status(500).json({ ok: false, error: error.message || 'AI request failed' });
  }
});

app.post('/api/workspace/read', requireAuth, async (req, res) => {
  try {
    const file = safePath(String(req.body?.path || ''));
    const content = await fs.readFile(file, 'utf8');
    res.json({ ok: true, path: req.body.path, content });
  } catch (error) {
    res.status(400).json({ ok: false, error: error.message || 'Read failed' });
  }
});

app.post('/api/workspace/write', requireAuth, async (req, res) => {
  try {
    const relativePath = String(req.body?.path || '').trim();
    const content = String(req.body?.content ?? '');
    if (!relativePath) return res.status(400).json({ error: 'path is required' });
    const file = safePath(relativePath);
    await fs.mkdir(path.dirname(file), { recursive: true });
    await fs.writeFile(file, content, 'utf8');
    res.json({ ok: true, path: relativePath });
  } catch (error) {
    res.status(400).json({ ok: false, error: error.message || 'Write failed' });
  }
});

app.post('/api/build', requireAuth, async (_req, res) => {
  try {
    const result = await runCommand(BUILD_COMMAND, WORKSPACE_ROOT);
    res.status(result.ok ? 200 : 422).json({ ok: result.ok, command: BUILD_COMMAND, ...result });
  } catch (error) {
    res.status(500).json({ ok: false, error: error.message || 'Build failed' });
  }
});

app.post('/api/fix', requireAuth, async (req, res) => {
  try {
    const instruction = String(req.body?.instruction || '').trim();
    const errorLog = String(req.body?.errorLog || '').trim();
    if (!errorLog) return res.status(400).json({ error: 'errorLog is required' });
    const analysis = await analyzeError(instruction, errorLog);
    res.json({ ok: true, analysis });
  } catch (error) {
    res.status(500).json({ ok: false, error: error.message || 'Fix analysis failed' });
  }
});

app.post('/api/build-and-analyze', requireAuth, async (req, res) => {
  try {
    const instruction = String(req.body?.instruction || '').trim();
    const build = await runCommand(BUILD_COMMAND, WORKSPACE_ROOT);
    if (build.ok) return res.json({ ok: true, stage: 'build', build, analysis: null });
    const errorLog = [build.stdout, build.stderr].filter(Boolean).join('\n').slice(-20000);
    const analysis = await analyzeError(instruction, errorLog);
    res.status(422).json({ ok: false, stage: 'analysis', build, analysis });
  } catch (error) {
    res.status(500).json({ ok: false, stage: 'server', error: error.message || 'Build/analyze workflow failed' });
  }
});

const port = Number(process.env.PORT || 8787);
app.listen(port, () => console.log(`AI Developer Workspace backend listening on ${port}`));
