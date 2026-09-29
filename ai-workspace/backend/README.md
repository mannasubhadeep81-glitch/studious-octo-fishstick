# AI Developer Workspace backend

This folder defines the secure backend boundary for the Workspace. The browser/mobile UI must call this server; the OpenAI API key must remain server-side and never be committed to this repository.

## Runtime contract

`POST /api/execute`

Request:
```json
{"instruction":"Build a simple calculator","projectId":"demo"}
```

Response:
```json
{"ok":true,"status":"queued","message":"Instruction accepted. The server-side coding worker can now inspect the authorized project and run its controlled workflow."}
```

The production implementation should authenticate the user, authorize the selected project, validate requested file operations, invoke the OpenAI API from the server, run builds in an isolated sandbox, and return structured results/logs.
