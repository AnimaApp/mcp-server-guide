# Agent Grid MCP tools

Use these tools for the selected Agent Grid lifecycle features.

The `sessionId` is the artifact ID. It is also the last path segment of an artifact URL.

## `artifact-create`

This skill uses only the local-files flow. Create all code first. Then send the code in `files`.

Use this schema for the local-files flow:

| Parameter | Type | Rule |
|---|---|---|
| `type` | `"import"` | Required. |
| `files` | `{ "<path>": "<UTF-8 text>" }` | Required for this flow. Do not send `zipUploadId`. |
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
| `workspace-list_artifacts` | `{}` | The list can set `truncated`. |
| `artifact-update_metadata` | `{ sessionId, name?, privacy? }` | Send `name` or `privacy`. Privacy is `"public"` or `"private"`. |
| `artifact-duplicate` | `{ sessionId, name? }` | Check the list before you retry a lost response. |
| `artifact-publish` | `{ sessionId, mode?: "webapp" }` | Publishing makes the app public. |
| `artifact-unpublish` | `{ sessionId }` | This tool keeps the artifact and its code. |
| `artifact-delete` | `{ sessionId }` | This tool makes a reversible soft deletion. |

`artifact-duplicate` does not copy chat or custom domains. The source must belong to the current team.

Unpublish a published artifact before deletion. MCP cannot permanently delete an artifact.
