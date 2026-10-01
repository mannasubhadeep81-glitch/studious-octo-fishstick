import express from "express";
import cors from "cors";
import OpenAI from "openai";
import path from "node:path";
import { fileURLToPath } from "node:url";

const app = express();
const port = process.env.PORT || 10000;
const AI_MODEL = process.env.OPENAI_MODEL || "gpt-5.6-luna";
const decisionWindow = new Map();

app.use(cors());
app.use(express.json({ limit: "1mb" }));

const workspaceDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../ai-workspace");
app.use(express.static(workspaceDir));

app.get("/", (_req, res) => {
  res.sendFile(path.join(workspaceDir, "index.html"));
});

app.get("/health", (_req, res) => {
  res.json({ status: "ok", name: "Lumira AI Backend" });
});

app.post("/api/racing/decision", async (req, res) => {
  try {
    const now = Date.now();
    const ip = req.ip || "unknown";
    const lastCall = decisionWindow.get(ip) || 0;
    if (now - lastCall < 1000) return res.status(429).json({ ok:false, error:"AI decision rate limit. Try again shortly." });
    decisionWindow.set(ip, now);

    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) return res.status(503).json({ ok:false, error:"LUMIRA AI is not connected yet. Add OPENAI_API_KEY to Render." });

    const state = req.body?.state;
    if (!state || typeof state !== "object") return res.status(400).json({ ok:false, error:"state is required." });

    const client = new OpenAI({ apiKey });
    const prompt = `You are the driving AI for a 2D arcade racing game. Return ONLY one JSON object, no markdown and no explanation. Choose the next driving action from lane -0.34, 0, or 0.34, plus nitro true/false. Avoid rocks, avoid collisions, and try to overtake the human when safe. State: ${JSON.stringify(state)}. Required JSON: {"lane":-0.34,"nitro":false}`;
    const response = await client.responses.create({ model: AI_MODEL, input: prompt });
    const raw = (response.output_text || "").trim().replace(/^```json\s*/,"").replace(/\s*```$/,"");
    let decision;
    try { decision = JSON.parse(raw); } catch { return res.status(502).json({ ok:false, error:"AI returned invalid driving decision." }); }
    const lane = [-0.34,0,0.34].reduce((best,x)=>Math.abs(x-Number(decision.lane))<Math.abs(best-Number(decision.lane))?x:best,-0.34);
    res.json({ ok:true, lane, nitro:Boolean(decision.nitro), model:AI_MODEL });
  } catch (error) {
    console.error(error);
    res.status(500).json({ ok:false, error:error?.message || "AI decision failed." });
  }
});

app.post("/api/chat", async (req, res) => {
  try {
    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) {
      return res.status(503).json({
        ok: false,
        error: "LUMIRA AI is not connected yet. Add OPENAI_API_KEY to the Render environment."
      });
    }

    const message = typeof req.body?.message === "string" ? req.body.message.trim() : "";
    const instruction = typeof req.body?.instruction === "string" ? req.body.instruction.trim() : "";
    const input = message || instruction;

    if (!input) {
      return res.status(400).json({ ok: false, error: "message or instruction is required." });
    }

    const client = new OpenAI({ apiKey });
    const response = await client.responses.create({
      model: AI_MODEL,
      input
    });

    res.json({ ok: true, output: response.output_text || "" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ ok: false, error: error?.message || "Backend request failed." });
  }
});

app.listen(port, "0.0.0.0", () => {
  console.log(`Lumira backend listening on port ${port}`);
});
