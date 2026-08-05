# Troubleshooting

## `artifact-create` seems to hang, or the app isn't there yet

**Not a failure.** Generation types return immediately with `status: "generating"` — the app is still building. Call `artifact-status(sessionId, wait: true)` and keep calling until the status leaves `generating`.

**Never call `artifact-create` again for the same request.** That creates a second artifact instead of retrying the first.

## Status polling spins or burns calls

Use `wait: true`. It returns as soon as the artifact is `ready` or `failed`, or after ~45s still generating. `wait: false` is a one-off snapshot — never loop on it.

## "field X is only valid for type Y"

Each create type accepts a different field set:

| Field | Valid types |
|---|---|
| `prompt`, `guidelines` | `p2c` |
| `url` | `l2c` |
| `fileKey`, `nodesId` | `f2c` |
| `files`, `zipUploadId` | `import` |
| `language` | `p2c`, `l2c`, `f2c` |
| `uiLibrary` | `l2c`, `f2c` |

`name` and `styling` are accepted everywhere but ignored where they don't apply.

## "styling X is not supported for type Y"

| Type | Valid `styling` |
|---|---|
| `p2c` | `tailwind`, `css`, `inline_styles` |
| `l2c` | `tailwind`, `inline_styles`, `vanilla_css` |
| `f2c` | `tailwind`, `plain_css`, `css_modules`, `inline_styles` |

Same for `uiLibrary`: `p2c` supports none, `l2c` only `shadcn`, `f2c` takes `mui`, `antd`, `shadcn`, `clean_react`.

## I got HTML when I wanted React

The default depends on the tool, not on whether you called it over MCP or the CLI — both surfaces agree:

| Tool | Default `framework` |
|---|---|
| `artifact-create` / `anima create` | `html` |
| `codegen-figma_to_code` / `anima codegen` | `react` |

So creating an artifact gives you HTML unless you ask for React. Pass `framework` explicitly and the difference stops mattering.

## "`uiLibrary` is only applicable when framework is react"

`language` and `uiLibrary` apply only when `framework: "react"`. Set the framework first.

## "framework is required for type empty"

There are no files to detect it from. Declare `react` if you'll push React code, `html` otherwise.

## "type import requires exactly one of files or zipUploadId"

Pass one, never both. `files` is for text projects (enforced caps: 1000 files, 10 MB decoded); binaries or anything larger go through `artifact-get_zip_upload_url`. For a repo you'll push to yourself, use type `empty` instead.

## "files contains N entries (max 1000)" / "files totals NMB (max 10MB)"

You hit the inline transport's real caps. Switch to the zip flow via `artifact-get_zip_upload_url`. Note the tool description's "roughly 100 KB" is guidance, not the enforced limit — the file count is usually what trips first.

## "Too many concurrent jobs"

A user may have at most **3 active jobs** at once, counted across generation, codegen, and deploy. Generating three variants in parallel sits exactly on that cap, so a concurrent publish or a leftover job pushes you over. Wait for one to finish and retry the failed call — don't silently drop a variant.

## Push to an `empty` artifact is rejected as non-fast-forward

`empty` isn't a bare repo — it has an initial commit with a seed `README.md`. Clone the artifact and commit on top of that history instead of pushing an unrelated local history.

## The model rejected a snapshot image

You re-embedded it under the wrong media type. Snapshots are **JPEG**; declaring `image/png` over JPEG bytes is rejected outright by APIs that validate the two against each other. The URLs are extension-less by design (Figma's CDN format), so read `Content-Type` from the download rather than guessing from the URL — but check the status code first and confirm the value starts with `image/`. These objects expire on a 30-day lifecycle rule, and an expired one answers `403` with `Content-Type: application/xml`; trusting that header embeds an S3 error document as your image.

## Snapshots are bigger than expected

They're full-resolution renders from Figma's CDN, not thumbnails. Measured: 1.2 MB for a 1728×1163 frame, 3.1 MB for a 1440×1848 one — 4 MB once base64-encoded, which is close to the per-image cap on some model APIs. Downscale before re-embedding, and download once and reuse rather than re-fetching per step.

## "This agent did not start this generation"

You passed a `sessionId` from `codegen-figma_to_code` to an `artifact-*` tool. Codegen creates no artifact; its `sessionId` identifies the codegen run and will never appear in `workspace-list_artifacts`. The message reads like a permissions problem but is a category error — if you want a hosted artifact from a Figma design, use `artifact-create` with `type: "f2c"` instead.

## Components are missing from the codegen response

Expected. `codegen-figma_to_code` filters boilerplate out of `files`: config files, entry points, `*.d.ts`, `src/lib/utils.*`, and everything under `src/components/` — which is exactly where extracted and shadcn components live. Generation did not fail. Use the files you received plus `guidelines` and the snapshots.

## Zip import rejected or files missing

- Max **50 MB**
- Source, config, and assets only — strip `node_modules` and build output
- Shell and executable files are skipped and listed back in `skippedFiles`
- `zipUploadId` is **single-use** and expires **30 minutes** after the last upload

## Figma node id error

The URL uses `-`, the API wants `:`. `?node-id=42-15` → `nodesId: ["42:15"]`.

## Figma call rejected as unauthenticated

The Figma token travels as the **`X-Figma-Token` header**, not a tool argument. For the CLI, set `FIGMA_TOKEN` or pass `--figma-token`.

## Git push rejected: token expired

Git tokens **cannot be renewed** — max lifetime is 3600s. Mint a fresh one and repoint the remote:

```bash
git remote set-url origin <new gitRemoteUrl>
```

## I want to edit an artifact but only have a URL

The `sessionId` is the last path segment of `https://app.agentgrid.io/artifacts/<sessionId>` (also served as `https://dev.animaapp.com/chat/<sessionId>`). Pass it to `artifact-get_git_token`. If you have no URL at all, run `workspace-list_artifacts`.

## How do I edit an artifact's content?

Through git — `artifact-get_git_token`, clone, commit, push. (The webapp is the human's editor; don't drive it with browser automation.) Renames and visibility are the exception: those are metadata, via `artifact-update_metadata`.

## `designSystem` publish fails

It's unavailable over MCP by design and always returns an enterprise contact link. Only `mode: "webapp"` works here.

## Duplicate timed out — should I retry?

Check first. Duplication is **not idempotent**: run `workspace-list_artifacts` to see whether the copy already exists, then retry only if it doesn't.

## Published, but the user only wanted to share

Publishing makes an app public to the world; sharing doesn't need it. The `playgroundUrl` is already viewable by anyone who can reach it. `artifact-unpublish` takes the live URL down without touching the code, and re-publishing reuses the subdomain.

## Generated code doesn't match the project's style

Detect the stack before calling, and pass `framework`, `styling`, `language`, and `uiLibrary` to match it. Defaults won't match most real projects.

## The design came out generic

Over-specified prompts override Agent Grid's design intelligence. Drop the hex values, pixel sizes, and CSS from the prompt; describe purpose, audience, mood, and 3–5 features instead.
