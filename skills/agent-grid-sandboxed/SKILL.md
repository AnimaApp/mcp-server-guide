---
name: agent-grid-sandboxed
description: "Create, inspect, review, publish, and edit Agent Grid artifacts entirely through MCP in a sandboxed agent."
mcpServers:
  - anima
compatibility: "Use this skill without a shell, Git, GitHub, or direct internet uploads."
homepage: "https://github.com/AnimaApp/mcp-server-guide"
metadata: {"clawdbot":{"emoji":"🎨","requires":{"env":["ANIMA_API_TOKEN"]},"primaryEnv":"ANIMA_API_TOKEN"},"author":"animaapp","version":"2.0.0"}
---

# Use Agent Grid in a sandbox

Agent Grid is a governed space where humans and agents share live artifacts. Each artifact is one repository in your team's General workspace.

Your access is limited to what the human who connected you consented to. It can be revoked at any time.

Use this skill when you cannot use a shell, Git, GitHub, or direct internet uploads.

## Create an artifact

Create all code first. Then call `artifact-create` with `files`. This sandboxed tool accepts only inline file creation; it does not take `type`.

Use `files` only for UTF-8 text files. The map key is the file path.

Do not call `artifact-create` to change an existing artifact. Each call creates a new artifact.

Example:

```
artifact-create(
  files: {
    "index.html": "<h1>Status</h1>",
    "styles.css": "h1 { color: navy; }"
  },
  name: "Status page"
)
```

The call returns `sessionId`, `revision`, `artifactUrl`, and the applicable preview URLs. The artifact is ready immediately. Share `artifactUrl` with the human.

To create a knowledge artifact from Anima's template, call `artifact-create_knowledge()` or pass only an optional `name`. Do not pass files, a framework, or an artifact type.

## Change artifact code

Use `artifact-explore` to list, search, read, or review artifact content.

Use the returned `revision` as `baseRevision` in `artifact-edit`. The edit creates one commit.

Use `str_replace`, `write`, `delete`, or `move`. Do not use any external upload process.

Read [MCP edit workflow](references/edit-workflow.md) before you change content.

## Handle reviews

Call `review-list` when a human mentions comments and when you resume reviewed work. Read replies before acting.

Put each addressed comment's `resolveTrailer` in the `artifact-edit` commit message. Use `review-reply` when the conversation must stay open. Use `review-resolve` only when no commit will close the comment.

## Use lifecycle tools

- Use `workspace-list_artifacts()` to find recent readable artifacts. The result is bounded, so a short or empty list is not proof that the workspace has no other artifacts.
- Use `artifact-update_metadata` to change the name or privacy.
- Use `artifact-duplicate` to create an independent copy.
- Use `artifact-publish` only when the user asks for a public deployment.
- Use `artifact-unpublish` to stop the public deployment.
- Use `artifact-delete` only when the user explicitly asks for deletion.

Read [MCP tools](references/mcp-tools.md) for exact parameters. Read [workflows](references/workflows.md) for sequences.

Read [troubleshooting](references/troubleshooting.md) when an MCP operation fails.
