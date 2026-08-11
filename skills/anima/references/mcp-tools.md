# Agent Grid MCP tool reference

Twelve tools in four groups appear below. `artifact-*` owns one artifact's lifecycle. `workspace-*` owns the registry. `codegen-*` writes files into your project. Enterprise workspaces can also show `design_system-*` tools. This guide does not include those tools.

Every artifact tool takes a **`sessionId`** — the artifact id from `artifact-create`, or the last path segment of an artifact URL (`https://app.agentgrid.io/artifacts/mr25vsjppVtbMx` → `mr25vsjppVtbMx`; also served as `https://dev.animaapp.com/chat/<sessionId>`).

---

## `artifact-create`

Creates a **new** artifact. Never edits an existing one.

| Parameter | Required for | Type | Notes |
|---|---|---|---|
| `type` | all | enum | `p2c`, `l2c`, `f2c`, `empty`, `import` |
| `prompt` | `p2c` | string | What to build |
| `guidelines` | — | string | `p2c` only; steers conventions/structure |
| `url` | `l2c` | string | Website to clone |
| `fileKey` | `f2c` | string | Figma file key |
| `nodesId` | `f2c` | string[] | Figma node ids, `:` not `-` |
| `files` | `import` | object | `{path: text}`, text only; enforced caps are **1000 files / 10 MB** decoded |
| `zipUploadId` | `import` | uuid | From `artifact-get_zip_upload_url` |
| `framework` | `empty` | enum | `html` \| `react` — **only these two**. Generation types default to `html`; `import` detects it from `package.json` |
| `styling` | — | enum | Generation types only; valid set varies (below) |
| `language` | — | enum | `typescript` \| `javascript`; `react` only |
| `uiLibrary` | — | enum | Generation types with `react` only |
| `name` | — | string | `empty`/`import` only; ≤120 chars |

`import` requires **exactly one** of `files` or `zipUploadId`. `f2c` also requires the `X-Figma-Token` header.

**Valid `styling` / `uiLibrary` per type:**

| Type | `styling` | `uiLibrary` |
|---|---|---|
| `p2c` | `tailwind`, `css`, `inline_styles` | not supported |
| `l2c` | `tailwind`, `inline_styles`, `vanilla_css` | `shadcn` |
| `f2c` | `tailwind`, `plain_css`, `css_modules`, `inline_styles` | `mui`, `antd`, `shadcn`, `clean_react` |

`language` applies to `l2c`/`f2c` with `framework: "react"` only — `p2c` accepts it and discards it, and the default `html` framework has no language. `l2c` with `react` is always TypeScript whatever you pass. `name` is accepted but ignored by generation types (they name themselves) — rename later with `artifact-update_metadata`.

**Returns — generation types (async):**
`{ success, status: "generating", sessionId, playgroundUrl, previewUrl }` → then poll `artifact-status`.

**Returns — `empty` / `import` (immediate):**
`{ sessionId, playgroundUrl, previewUrl, name, framework, gitRemoteUrl, access, expiresAt, nextSteps }` plus `fileCount` / `skippedFiles` for `import`, and `notes` when the framework was clamped. **A read-write git token normally comes back in this same response** — use it instead of calling `artifact-get_git_token`. The mint can be skipped or fail, though: if there's no `gitRemoteUrl`, follow `nextSteps` and call `artifact-get_git_token`.

`empty` is not a bare repo — it lands an initial commit with a seed `README.md`, so clone it rather than pushing an unrelated history.

---

## `artifact-status`

Read-only. How you learn that an async generation finished.

| Parameter | Required | Type | Notes |
|---|---|---|---|
| `sessionId` | yes | string | |
| `wait` | no | boolean | Default `false`. `true` blocks until done |

With `wait: true` the call returns as soon as status is `ready` or `failed`, or after ~45s still `generating` — then call again. Never spin with `wait: false`.

**Returns:** `{ success, sessionId, status: "generating" | "ready" | "failed", progress (0–100 while generating), name, playgroundUrl, previewUrl, thumbnailUrl, error (when failed), nextStep }`

---

## `artifact-get_git_token`

Use git for large repositories or full git workflows, such as branches and history changes.

| Parameter | Required | Type | Notes |
|---|---|---|---|
| `sessionId` | yes | string | |
| `ttlSeconds` | no | int | Default and max `3600`, min `300` |

**Returns:** a `gitRemoteUrl` with an embedded short-lived token scoped to this one artifact, read-only or read-write depending on your access. Treat it as a secret. Tokens **cannot be renewed** — mint a fresh one and `git remote set-url origin <new url>`. See [git-workflow.md](git-workflow.md).

---

## `artifact-explore`

Inspects an existing artifact without git, a shell, or network access. Use it to list, search, read, or review files.

| Parameter | Required for | Type | Notes |
|---|---|---|---|
| `sessionId` | all | string | Artifact id |
| `action` | all | enum | `tree` \| `search` \| `read` \| `history` |
| `paths` | `read` | string[] | Up to 10 file paths |
| `query` | `search` | string | Literal text, or a JavaScript regular expression with `regex: true` |
| `path` | — | string | Literal directory prefix for `tree` and `search`; not a glob |
| `range` | — | string | `read` line range: `"startLine,endLine"`; use with one path |
| `revision` | — | string | Commit for `tree`, `search`, or `read`; commit detail for `history` |
| `regex` / `caseSensitive` | — | boolean | `search` options |
| `includeExcluded` | — | boolean | `tree` option; includes `node_modules`, `dist`, and `build` |
| `limit` | — | int | Maximum: 500 `tree` rows, 500 `search` rows, or 50 `history` commits |
| `cursor` | — | string | `history` cursor from `nextCursor` |

Start with `search` when you do not know the file. Read each file before you change it.

Every response includes the current `revision`. Pass this exact full commit id to `artifact-edit` as `baseRevision`.

Successful responses include `success: true`. `history` lists the newest commit first.

| Action | Output |
|---|---|
| `tree` | `files`, `truncated`, and optional `directories` |
| `search` | `matches` with line context and occurrence counts, plus `truncated` |
| `read` | `readAt`, `files`, `missingPaths`, and `suggestions`; files can report `truncated`, `deferred`, `binary`, or `eol` |
| `history` | `commits` and `nextCursor`, or one `commit` with `changedFiles` |

Use `revision` with `read` to inspect earlier content. The top-level `revision` still identifies the current commit.

For `revision`, use a commit id, an unambiguous abbreviation, or `HEAD`. Do not use a branch, tag, or range.

---

## `artifact-edit`

Changes an existing artifact without git or a shell. Use it for normal text file changes.

| Parameter | Required | Type | Notes |
|---|---|---|---|
| `sessionId` | yes | string | Artifact id |
| `baseRevision` | yes | string | Full `revision` from the most recent `artifact-explore` response |
| `commitMessage` | yes | string | Plain text; omit `Co-Authored-By`, `Agent-Id`, and `Anima-Actor-*` trailers |
| `changes` | yes | object[] | 1–20 operations; the server applies them in order |

| `op` | Required fields | Important optional fields |
|---|---|---|
| `str_replace` | `path`, `oldText`, `newText` | `replaceAll`, `expectedReplacements` |
| `write` | `path`, `content` | — |
| `delete` | `path` | — |
| `move` | `fromPath`, `toPath` | — |

Prefer `str_replace` for an existing file. `oldText` must match exact bytes and occur once unless `replaceAll` is `true`.

Use `expectedReplacements` only with `replaceAll`. It stops the edit when the occurrence count differs.

Do not use `write` with content from a truncated or deferred read. It can remove unseen content.

The server applies all operations in order and creates one commit. If one operation fails, the server applies none.

A `move` does not change imports. Add later `str_replace` operations. Use the new path after the `move`.

**Returns:** `{ success, revision, previousRevision, changedFiles }`. The preview uses the new commit immediately.

If the artifact changed, the tool returns `error.code: "REVISION_CONFLICT"` and `changedSinceBase`. Read the changed files and retry.

---

## `artifact-get_zip_upload_url`

Step 1 of the zip import flow. No parameters.

1. Call it → `{ zipUploadId, uploadUrl, uploadUrlExpiresAt, nextSteps }`
2. HTTP `PUT` your zip to `uploadUrl` (a secret)
3. `artifact-create(type: "import", zipUploadId)` within **30 minutes**; single-use

**Limits:** 50 MB; source, config, and assets only — no `node_modules`, no build output. Shell/executable files are skipped and reported.

---

## `artifact-publish`

Deploys the app to a live public URL.

| Parameter | Required | Type | Notes |
|---|---|---|---|
| `sessionId` | yes | string | |
| `mode` | no | enum | `webapp` (default). `designSystem` **always fails over MCP** |
| `packageName` / `packageVersion` | no | string | `designSystem` only. Passing either with `mode: "webapp"` is a hard validation error — omit them |

Publishing makes the app public to the world, and is **not** needed for sharing. Only call it when explicitly asked.

**Returns:** `{ success, liveUrl, subdomain }`

---

## `artifact-unpublish`

Takes a published artifact offline. Does not delete the artifact or its code; the same subdomain is reused if you publish again.

| Parameter | Required | Type |
|---|---|---|
| `sessionId` | yes | string |

**Returns:** `{ success, message }`

---

## `artifact-update_metadata`

Metadata only — never touches code.

| Parameter | Required | Type | Notes |
|---|---|---|---|
| `sessionId` | yes | string | |
| `name` | one of | string | New display name, ≤120 chars |
| `privacy` | one of | enum | `public` (anyone with the link) \| `private` (team only) |

Send at least one of `name` / `privacy`; both may be set in one call.

**Returns:** `{ success, message }`

---

## `artifact-duplicate`

Clones an artifact into a new, independent one in your team's Default workspace.

| Parameter | Required | Type | Notes |
|---|---|---|---|
| `sessionId` | yes | string | Source, must be in your current team |
| `name` | no | string | Defaults to `"<source name> (Copy)"` |

Copies code, assets, and supported database content. Does **not** copy chat or custom domains. If the database can't be copied, the whole duplication fails. Duplicating across teams is not currently supported.

> **Not idempotent.** On a timeout or lost response, check `workspace-list_artifacts` before retrying.

**Returns:** `{ success, sessionId, sourceSessionId, name, playgroundUrl, previewUrl, nextSteps }`

---

## `workspace-list_artifacts`

Lists your team's artifacts. **No parameters.** App rows include the `sessionId` the `artifact-*` tools need; `markdown` and `asset` rows carry only an `id`. The result may set `truncated`, and an agent lacking `read` access gets an empty list rather than an error — an empty result is not proof the workspace is empty.

---

## `codegen-figma_to_code`

Generates code files for **your own project**. Creates no artifact and hosts nothing.

| Parameter | Required | Type | Notes |
|---|---|---|---|
| `fileKey` | yes | string | From the Figma URL |
| `nodesId` | yes | string[] | `:` not `-` |
| `framework` | no | enum | `react` (default) \| `html` |
| `styling` | no | enum | `tailwind` (default) \| `plain_css` |
| `language` | no | enum | `typescript` (default) \| `javascript` |
| `uiLibrary` | no | enum | `mui`, `antd`, `shadcn`, `clean_react`; omit for plain React/HTML |
| `assetsBaseUrl` | no | string | Where assets will live in your project |

Requires the `X-Figma-Token` header.

**Returns:** `{ files: {path: {content, isBinary}}, assets: [{name, url}], snapshotsUrls: {nodeId: url}, guidelines, tokenUsage }`

**The response is not just code.** Download and view `snapshotsUrls` as visual ground truth, follow `guidelines`, map `data-variant` attributes to your props, and download `assets` to your `assetsBaseUrl` — otherwise the generated references break.

**`files` is filtered.** Boilerplate is removed before the response is built: `package.json`, `tsconfig*.json`, `vite.config.*`, `src/index.*`, `src/main.*`, `*.d.ts`, `src/lib/utils.*`, and everything under `src/components/` — where extracted and shadcn components live. Expect a partial tree, not a runnable project.
