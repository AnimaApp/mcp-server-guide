---
name: agent-grid-sandboxed
description: "Create, host, publish, and edit local text files on Agent Grid with MCP in a sandboxed agent."
mcpServers:
  - anima
compatibility: "Use this skill without a shell, Git, GitHub, or direct internet uploads."
homepage: "https://github.com/AnimaApp/mcp-server-guide"
metadata: {"clawdbot":{"emoji":"🎨","requires":{"env":["ANIMA_API_TOKEN"]},"primaryEnv":"ANIMA_API_TOKEN"},"author":"animaapp","version":"2.0.0"}
---

# Use Agent Grid in a sandbox

Agent Grid hosts artifacts. Each artifact is one repository in your workspace.

Use this skill when you cannot use a shell, Git, GitHub, or direct internet uploads.

## Create an artifact

Create all code first. Then call `artifact-create` with `type: "import"` and `files`.

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

Use `artifact-explore` to list, search, read, or review artifact content.

Use the returned `revision` as `baseRevision` in `artifact-edit`. The edit creates one commit.

Use `str_replace`, `write`, `delete`, or `move`. Do not use any external upload process.

Read [MCP edit workflow](references/edit-workflow.md) before you change content.

## Use lifecycle tools

- Use `workspace-list_artifacts()` to find artifacts.
- Use `artifact-update_metadata` to change the name or privacy.
- Use `artifact-duplicate` to create an independent copy.
- Use `artifact-publish` only when the user asks for a public deployment.
- Use `artifact-unpublish` to stop the public deployment.
- Use `artifact-delete` only when the user explicitly asks for deletion.

Read [MCP tools](references/mcp-tools.md) for exact parameters. Read [workflows](references/workflows.md) for sequences.

Read [troubleshooting](references/troubleshooting.md) when an MCP operation fails.
