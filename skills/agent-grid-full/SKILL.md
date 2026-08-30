---
name: agent-grid-full
description: "Create, host, publish, and edit local code on Agent Grid with MCP, Git, a shell, and network access."
mcpServers:
  - anima
compatibility: "Use this skill with a shell, Git, and network access."
homepage: "https://github.com/AnimaApp/mcp-server-guide"
metadata: {"clawdbot":{"emoji":"🎨","requires":{"env":["ANIMA_API_TOKEN"]},"primaryEnv":"ANIMA_API_TOKEN"},"author":"animaapp","version":"2.0.0"}
---

# Use Agent Grid with Git

Agent Grid hosts artifacts. Each artifact is one Git repository in your workspace.

Use this skill only if you have a shell, Git, and network access.

## Create an artifact

Create the code in your local directory first. Then call `artifact-create` with `type: "import"` and `files`.

Use `files` only for UTF-8 text files. The map key is the file path.

Do not call `artifact-create` to change an existing artifact. Each call creates a new artifact.

Example:

```
artifact-create(
  type: "import",
  files: {
    "index.html": "<h1>Status</h1>",
    "styles.css": "h1 { color: navy; }"
  },
  name: "Status page"
)
```

The call returns `sessionId`, `revision`, `playgroundUrl`, and `previewUrl`. The artifact is ready immediately.

## Change artifact code

Call `artifact-get_git_token` with the `sessionId`. Then clone the returned `gitRemoteUrl`.

Edit the files in the clone. Commit the changes. Push the commit to update the artifact.

Do not use browser automation to change artifact code.

Read [Git workflow](references/git-workflow.md) before you use the Git remote.

## Use lifecycle tools

- Use `workspace-list_artifacts()` to find artifacts.
- Use `artifact-update_metadata` to change the name or privacy.
- Use `artifact-duplicate` to create an independent copy.
- Use `artifact-publish` only when the user asks for a public deployment.
- Use `artifact-unpublish` to stop the public deployment.
- Use `artifact-delete` only when the user explicitly asks for deletion.

Read [MCP tools](references/mcp-tools.md) for exact parameters. Read [workflows](references/workflows.md) for sequences.

Read [troubleshooting](references/troubleshooting.md) when a tool or Git operation fails.
