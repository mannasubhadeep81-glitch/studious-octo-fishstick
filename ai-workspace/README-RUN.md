# AI Developer Workspace — Run Guide

## Web UI
Open `index.html` from a static host. The UI needs the deployed backend URL.

## Backend
Deploy `ai-workspace/backend` as a Node web service. A Render deployment file is included at `ai-workspace/backend/render.yaml`.

Required environment variable:
- `OPENAI_API_KEY` — keep this only on the backend.

Optional:
- `OPENAI_MODEL` — defaults to `gpt-5.6` in the included configuration.

Health check: `/health`

API routes:
- `POST /api/plan`
- `POST /api/workspace/read`
- `POST /api/workspace/write`
- `POST /api/build`
- `POST /api/fix`
- `POST /api/build-and-analyze`

The current backend intentionally does not claim to have applied AI code changes. It provides controlled file read/write, build execution, and error analysis; the next security-sensitive step is authentication and a stricter command/file allowlist before exposing write/build endpoints publicly.
