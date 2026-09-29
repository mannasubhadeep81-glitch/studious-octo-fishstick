import express from 'express';
import cors from 'cors';
import OpenAI from 'openai';
import fs from 'node:fs/promises';
import path from 'node:path';

const app = express();
app.use(cors());
app.use(express.json({ limit: '1mb' }));

const WORKSPACE_ROOT = path.resolve(process.env.WORKSPACE_ROOT || './workspace');

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

app.get('/health', (_req, res) => res.json({ ok: true, service: 'ai-developer-workspace' }));

app.post('/api/plan', async (req, res) => {
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

app.post('/api/workspace/read', async (req, res) => {
  try {
    const file = safePath(String(req.body?.path || ''));
    const content = await fs.readFile(file, 'utf8');
    res.json({ ok: true, path: req.body.path, content });
  } catch (error) {
    res.status(400).json({ ok: false, error: error.message || 'Read failed' });
  }
});

app.post('/api/workspace/write', async (req, res) => {
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

const port = Number(process.env.PORT || 8787);
app.listen(port, () => console.log(`AI Developer Workspace backend listening on ${port}`));
