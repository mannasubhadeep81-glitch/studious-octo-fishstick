# LUMIRA AI Office Workflow

## Role architecture
- ChatGPT/OpenAI: main AI reasoning and development assistant.
- LUMIRA: office/workspace UI for issuing commands and viewing results.
- GitHub: source code, version control, pull requests, and Actions builds/tests.
- Render: secure backend/orchestration and deployment.

## Intended flow
User -> LUMIRA Office -> Render Backend -> OpenAI API
                         -> GitHub repository / Actions
                         -> Render deployment
                         -> LUMIRA status/result

## Automatic build policy
Every commit pushed to `main` triggers `.github/workflows/build-apk.yml` automatically. The workflow builds the debug APK and uploads `LUMIRA-debug-apk` as an artifact.

## Development command lifecycle
1. User describes a task in LUMIRA.
2. Backend sends the task to the OpenAI API.
3. AI analyses the repository and proposes required changes.
4. Changes are made through GitHub using an authenticated integration.
5. A push to `main` automatically starts the APK build/test workflow.
6. Render deploys backend changes when appropriate.
7. LUMIRA displays build/deployment status and AI summary.
8. Destructive or production-impacting actions should require explicit user approval.

## Security
- Never put OPENAI_API_KEY in Android source code or the public repository.
- Keep secrets in Render/GitHub secret storage.
- Do not expose GitHub tokens to the Android client.
- Use least-privilege permissions.
