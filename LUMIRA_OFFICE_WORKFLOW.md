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

## Development command lifecycle
1. User describes a task in LUMIRA.
2. Backend sends the task to the OpenAI API.
3. AI analyses the repository and proposes required changes.
4. Changes are made through GitHub using an authenticated integration.
5. GitHub Actions builds/tests the project.
6. Render deploys backend changes when appropriate.
7. LUMIRA displays build/deployment status and AI summary.
8. Destructive or production-impacting actions should require explicit user approval.

## Security
- Never put OPENAI_API_KEY in Android source code or the public repository.
- Keep secrets in Render/GitHub secret storage.
- Do not expose GitHub tokens to the Android client.
- Use least-privilege permissions.
