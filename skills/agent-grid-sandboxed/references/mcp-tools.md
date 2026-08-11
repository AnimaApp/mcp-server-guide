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

## `artifact-explore`

Use `{ sessionId, action }`. The `action` value is `tree`, `search`, `read`, or `history`.

Use `path` to limit `tree` and `search`. Use `query` for `search`.

Use `paths` for `read`. You can read at most 10 paths in one call.

Use `range: "startLine,endLine"` with one path. Line numbers start at 1 and include both limits.

Use `revision` to read earlier content. Use `cursor` to continue `history`.

The maximum limits are 500 tree entries, 500 search matches, and 50 history commits.

`tree` and `search` can return `truncated: true`. Use `path` to narrow the next call.

Each search match gives its line and `occurrences`. One line can contain more than one occurrence.

## `artifact-edit`

Use `{ sessionId, baseRevision, commitMessage, changes }`. Send 1 through 20 changes.

Each change uses `op: "str_replace"`, `"write"`, `"delete"`, or `"move"`.

All changes create one atomic commit. The server applies changes in their listed order.

Read [MCP edit workflow](edit-workflow.md) for the exact operation fields and limits.

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
