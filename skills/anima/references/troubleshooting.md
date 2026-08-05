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

`framework` **defaults to `html`** over MCP — pass `framework: "react"` explicitly. (The CLI's `codegen` command defaults to `react` instead, which is easy to trip over. Always be explicit.)

## "`uiLibrary` is only applicable when framework is react"

`language` and `uiLibrary` apply only when `framework: "react"`. Set the framework first.

## "framework is required for type empty"

There are no files to detect it from. Declare `react` if you'll push React code, `html` otherwise.

## "type import requires exactly one of files or zipUploadId"

Pass one, never both. `files` is for text under ~100 KB; anything bigger or binary goes through `artifact-get_zip_upload_url`. For a repo with no starting content, use type `empty` instead.

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

## Editing through the browser doesn't stick

It isn't supported. Content changes go through git — `artifact-get_git_token`, clone, commit, push. Renames and visibility are the exception: those are metadata, via `artifact-update_metadata`.

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
