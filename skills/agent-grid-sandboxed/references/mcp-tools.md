# Agent Grid MCP tools

Use these tools for the selected Agent Grid lifecycle features.

The `sessionId` is the artifact ID. It is also the last path segment of an artifact URL. Every artifact also has an `artifactUrl`; share that URL with the human.

## `artifact-create`

This sandboxed tool uses only the inline-files flow. Create all code first. Then send the code in `files`. Do not pass `type`; the server supplies `"import"`.

Use this schema for the local-files flow:

| Parameter | Type | Rule |
|---|---|---|
| `files` | `{ "<path>": "<UTF-8 text>" }` | Required. |
| `artifactType` | `"app" \| "markdown"` | Optional. The default is `"app"`. |
| `framework` | `"react" \| "html"` | Optional. The server can detect it from `package.json`. |
| `name` | string | Optional. Maximum length is 120 characters. |

Inline projects are limited to roughly 100 KB of decoded text and cannot contain binary files. There is no ZIP or external-upload flow on this MCP surface.

Each file path has a maximum length of 512 characters.

An app needs `index.html`. A markdown artifact needs at least one `.md` file and no framework.

The call returns the first commit in `revision`. It also returns `sessionId`, `artifactUrl`, applicable preview URLs, and file details.

## `artifact-create_knowledge`

Creates a ready knowledge artifact from Anima's template in the team's General workspace.

Use `{}` or `{ name: "<optional name>" }`. The name has a maximum length of 120 characters. Do not pass files, a ZIP upload, a framework, or an artifact type; the template supplies them.

The call returns `sessionId`, the initial `revision`, `artifactUrl`, the applicable preview URLs, and template details. Use `artifact-explore` and `artifact-edit` to inspect and change it.

## `artifact-explore`

Use `{ sessionId, action }`. The `action` value is `tree`, `search`, `read`, or `history`.

Use `path` to limit `tree` and `search`; it is a literal directory prefix, not a glob. Use `query` for `search`. Set `regex` or `caseSensitive` when needed.

Use `paths` for `read`. You can read at most 10 paths in one call.

Use `range: "startLine,endLine"` with one path. Line numbers start at 1 and include both limits.

Use `revision` with `tree`, `read`, or `search` to inspect earlier content, or with `history` to inspect one commit. Use `cursor` to continue `history`.

The maximum limits are 500 tree entries, 500 search matches, and 50 history commits.

`tree` and `search` can return `truncated: true`. Use `path` or `limit` to narrow the next call.

Each search match gives its line and `occurrences`. One line can contain more than one occurrence.

Reading a binary file with `read` returns `asset: true` with its `size`, `mime`, and `oid` instead of `content`.

`tree` and `search` skip `node_modules`, `dist`, and `build` by default. Set `includeExcluded: true` to include them.

## `artifact-edit`

Use `{ sessionId, baseRevision, commitMessage, changes }`. Send 1 through 20 changes.

Each change uses `op: "str_replace"`, `"write"`, `"delete"`, or `"move"`.

All changes create one atomic commit. The server applies changes in their listed order.

Read [MCP edit workflow](edit-workflow.md) for the exact operation fields and limits.

## Review tools

| Tool | Exact parameters | Important rule |
|---|---|---|
| `review-list` | `{ sessionId?, limit? }` | Lists open comments addressed to you and unassigned comments. The limit is 1 through 50. |
| `review-reply` | `{ commentId, message, mentionUserIds? }` | Leaves the comment open. Mention only people returned in `mentionablePeople`. |
| `review-resolve` | `{ commentId, note? }` | Closes without a commit; prefer a returned `resolveTrailer` when an edit addresses the comment. |

Read all replies before acting. A reply to an unassigned comment announces that you are taking it but does not reserve it. Do not resolve a multi-party comment until all requested work is complete.

## Lifecycle tools

| Tool | Exact parameters | Important rule |
|---|---|---|
| `workspace-list_artifacts` | `{}` | Rows contain `sessionId` and `type`; the bounded list can set `truncated`. |
| `artifact-update_metadata` | `{ sessionId, name?, privacy? }` | Send `name` or `privacy`. Privacy is `"public"` or `"private"`. |
| `artifact-duplicate` | `{ sessionId, name? }` | Check the list before you retry a lost response. |
| `artifact-publish` | `{ sessionId, mode?: "webapp" }` | Publishing makes the app public. |
| `artifact-unpublish` | `{ sessionId }` | This tool keeps the artifact and its code. |
| `artifact-delete` | `{ sessionId }` | This tool makes a reversible soft deletion. |

`workspace-list_artifacts` reads the team's single General workspace, most recently updated first. Access is limited by the human's grant. A short or empty result is not a complete inventory, even when `truncated` is false.

`artifact-duplicate` creates the copy in that General workspace. It does not copy chat or custom domains, and the source must belong to the current team.

Unpublish a published artifact before deletion. MCP cannot permanently delete an artifact.
