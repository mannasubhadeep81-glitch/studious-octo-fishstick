import express from 'express';
import cors from 'cors';
import OpenAI from 'openai';

const app = express();
app.use(cors());
app.use(express.json({ limit: '1mb' }));

function getClient() {
  if (!process.env.OPENAI_API_KEY) throw new Error('OPENAI_API_KEY is not configured');
  return new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
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
        {
          role: 'system',
          content: 'You are the planning layer for a controlled software-development workspace. Return a concise JSON object with goal, steps, files, tests, and risks. Do not claim to have edited or executed files.'
        },
        { role: 'user', content: instruction }
      ]
    });

    res.json({ ok: true, plan: response.output_text });
  } catch (error) {
    res.status(500).json({ ok: false, error: error.message || 'AI request failed' });
  }
});

const port = Number(process.env.PORT || 8787);
app.listen(port, () => console.log(`AI Developer Workspace backend listening on ${port}`));
