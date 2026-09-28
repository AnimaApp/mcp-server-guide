# Agent Grid MCP tools

Use these tools for the selected Agent Grid lifecycle features.

The `sessionId` is the artifact ID. It is also the last path segment of an artifact URL.

## `artifact-create`

This skill uses only the local-files flow. Create all code first. Then send the code in `files`.

Use this schema for the local-files flow:

| Parameter | Type | Rule |
|---|---|---|
| `type` | `"import"` | Required. |
| `files` | `{ "<path>": "<UTF-8 text>" }` | Required. |
| `artifactType` | `"app" \| "markdown"` | Optional. The default is `"app"`. |
| `framework` | `"react" \| "html"` | Optional. The server can detect it from `package.json`. |
| `name` | string | Optional. Maximum length is 120 characters. |

The server accepts at most 1000 files and 10 MB of decoded text.

Each file path has a maximum length of 512 characters.

An app needs `index.html`. A markdown artifact needs at least one `.md` file and no framework.

The call returns the first commit in `revision`. It also returns `sessionId`, URLs, and file details.

## `artifact-get_git_token`

Call `artifact-get_git_token(sessionId, ttlSeconds?)` for Git access.

The optional `ttlSeconds` value has a minimum of `300`. Its default and maximum are `3600`.

The result includes `gitRemoteUrl`, `access`, `expiresAt`, and `nextSteps`.

## Lifecycle tools

| Tool | Exact parameters | Important rule |
|---|---|---|
| `workspace-list_workspaces` | `{}` | Rows contain `workspaceId`, `name`, `isGeneral`, and the `capabilities` you hold there. |
| `workspace-list_artifacts` | `{ workspaceId? }` | Rows contain `sessionId`, `type`, and the `workspaceId` the artifact is filed in; the bounded list can set `truncated`. |
| `artifact-update_metadata` | `{ sessionId, name?, privacy? }` | Send `name` or `privacy`. Privacy is `"public"` or `"private"`. |
| `artifact-duplicate` | `{ sessionId, name?, workspaceId? }` | Check the list before you retry a lost response. |
| `workspace-move_artifact` | `{ sessionId, workspaceId }` | Both are required. Needs `write` on the artifact and in the destination. |
| `artifact-publish` | `{ sessionId, mode?: "webapp" }` | Publishing makes the app public. |
| `artifact-unpublish` | `{ sessionId }` | This tool keeps the artifact and its code. |
| `artifact-delete` | `{ sessionId }` | This tool makes a reversible soft deletion. |

A team has a General workspace and may have any number of others, and what you may do can differ between them. A workspace id is opaque: `workspace-list_workspaces` names the ones you can reach, and every `workspace-list_artifacts` row carries the id of the workspace its artifact is filed in.

`workspace-list_artifacts` spans every workspace you can read, most recently updated first, or one when you pass `workspaceId`. A short or empty result is not a complete inventory, even when `truncated` is false.

`artifact-duplicate` files the copy in the workspace you name, or in the one workspace you can write in when you name none. When you can write in several, it refuses and lists them.

`workspace-move_artifact` re-files an artifact under another workspace of the same team. The repository, `sessionId`, URL, history, and live deployment stay as they are; what changes is who can reach it, so say what a move will change before making one the user did not ask for. Moving an artifact where it already is leaves everything as it was.

Unpublish a published artifact before deletion. MCP cannot permanently delete an artifact.
