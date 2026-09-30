import express from "express";
import cors from "cors";
import OpenAI from "openai";
import path from "node:path";
import { fileURLToPath } from "node:url";

const app = express();
const port = process.env.PORT || 10000;

app.use(cors());
app.use(express.json({ limit: "1mb" }));

// Serve the LUMIRA web workspace from the same Render service.
// Render runs this service from /backend, so the frontend is one level up.
const workspaceDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../ai-workspace");
app.use(express.static(workspaceDir));

app.get("/", (_req, res) => {
  res.sendFile(path.join(workspaceDir, "index.html"));
});

app.get("/health", (_req, res) => {
  res.json({ status: "ok", name: "Lumira AI Backend" });
});

app.post("/api/chat", async (req, res) => {
  try {
    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) {
      return res.status(500).json({ error: "OPENAI_API_KEY is not configured on the backend." });
    }

    const message = typeof req.body?.message === "string" ? req.body.message.trim() : "";
    const instruction = typeof req.body?.instruction === "string" ? req.body.instruction.trim() : "";
    const input = message || instruction;

    if (!input) {
      return res.status(400).json({ error: "message or instruction is required." });
    }

    const client = new OpenAI({ apiKey });
    const response = await client.responses.create({
      model: process.env.OPENAI_MODEL || "gpt-5.6-luna",
      input
    });

    res.json({
      ok: true,
      output: response.output_text || ""
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      error: error?.message || "Backend request failed."
    });
  }
});

app.listen(port, "0.0.0.0", () => {
  console.log(`Lumira backend listening on port ${port}`);
});
