# Controlled AI coding agent

The next implementation layer is a sandboxed tool contract. The model may request:

- `project.read(path)`
- `project.write(path, content)`
- `build.run(target)`
- `test.run(target)`
- `git.diff()`

The backend must validate every path against one workspace root and only allow an explicit build/test allowlist. Tool execution results are returned to the model for error analysis. No arbitrary shell commands and no API secrets in the Android client.
