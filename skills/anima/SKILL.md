---
name: anima
description: "Build and ship web apps on Agent Grid — a governed hub where AI agents create, host, publish, and share apps. Create an artifact (a real git repo) from a text prompt, a website URL to clone, a Figma design, your own existing code, or an empty repo; then edit it over git and publish it to a live URL. Also generates design-aware code from Figma directly into an existing codebase. Triggers when the user provides a Figma URL, a website URL to clone, an Agent Grid artifact URL, asks to design, build, prototype, or deploy an app, asks to edit or fix an existing artifact, or wants to publish something to a live URL."
mcpServers:
  - anima
compatibility: "Works via the Agent Grid MCP server (HTTP transport) or the Anima CLI (npx @animaapp/cli). Both talk to the same governed endpoint."
homepage: "https://github.com/AnimaApp/mcp-server-guide"
metadata: {"clawdbot":{"emoji":"🎨","requires":{"env":["ANIMA_API_TOKEN"]},"primaryEnv":"ANIMA_API_TOKEN"},"author":"animaapp","version":"2.0.0"}
---

# Build on Agent Grid

## What this is

Agent Grid is a governed hub where AI agents build, host, publish, and share web apps. You reach it through the **Agent Grid MCP server** or the **Anima CLI** — both are the same surface, so use whichever is already connected.

The unit you work with is an **artifact**: one real git repository in your team's workspace. Everything is an artifact — the code, the running app, the thing you publish. When an artifact holds a web app, it renders live at its URL.

Two ideas carry most of the work:

- **`artifact-*` tools own one artifact's lifecycle** — create, check, edit, rename, publish.
- **`workspace-*` tools own the registry** — what artifacts exist.

**The `sessionId` is the artifact's id.** It's returned by `artifact-create`, and it's the last path segment of any artifact URL (`https://app.agentgrid.io/artifacts/mr25vsjppVtbMx` → `mr25vsjppVtbMx`). Artifact URLs are currently also served on the Playground host (`https://dev.animaapp.com/chat/<sessionId>`) — same artifact, same id, take the last segment either way.

---

## Pick the job first

| The user wants | Job | Start with |
|---|---|---|
| Something new built for them | **A. Generate** | `artifact-create` (p2c / l2c / f2c) |
| Their own code hosted on Agent Grid | **B. Bring your own** | `artifact-create` (import / empty) |
| An existing artifact changed | **C. Edit** | `artifact-get_git_token` → clone, commit, push |
| Figma design implemented **in their repo** | **D. Codegen** | `codegen-figma_to_code` |

The one that gets confused most is A vs D. "Turn this Figma into a live site" is **A** (creates a hosted artifact). "Implement this Figma in my project" is **D** (writes files into their codebase, no artifact). When it's genuinely unclear, ask: *"Do you want a live hosted app, or code files in your project?"*

Job C is how you change an artifact's content: humans edit in the Agent Grid webapp, agents use git. Don't reach for browser automation, and don't re-generate an artifact to edit it.

---

## The async contract (read before Job A)

`artifact-create` with a generation type (`p2c`, `l2c`, `f2c`) **returns immediately**, while the app is still building:

```
{ success, status: "generating", sessionId, playgroundUrl, previewUrl }
```

That is not a finished app. Your next action — **before you reply to the user** — is one call to:

```
artifact-status(sessionId: "<id>", wait: true)
```

With `wait: true` the call blocks until the artifact is `ready` or `failed`, or returns after ~45s still `generating`. If it comes back still generating, **call it again**. Keep going until the status changes, then report a finished app rather than a promise.

Three rules that prevent the common failures:

1. **Never call `artifact-create` twice for the same request.** A slow generation is not a failed one — it creates a duplicate artifact.
2. **Never poll with `wait: false` in a tight loop.** Use `wait: true`; the snapshot mode exists for one-off checks.
3. **Don't rely on a long client timeout.** The `wait: true` cycle is the supported pattern, not a single 10-minute call.

Own-code types (`empty`, `import`) skip all of this — they're ready the moment they return.

---

## Job A: Generate an artifact

### Choose the type

| User provides | Type | Required fields |
|---|---|---|
| A description of what to build | `p2c` | `prompt` |
| A website URL to clone | `l2c` | `url` |
| A Figma design to make live | `f2c` | `fileKey`, `nodesId`, `X-Figma-Token` header |

### Write the prompt (p2c)

Agent Grid is design-aware. Describe the *feel* and the *purpose*; over-specifying with hex values and pixel dimensions overrides that design intelligence and yields generic results.

**Include:** purpose, audience, mood/style, 3–5 key features, content tone.
**Leave out:** code snippets, CSS values, hex colors, pixel sizes, font sizes, file structure, component library names (use `uiLibrary` instead).

Bad:
```
Create a dashboard. Use #1a1a2e background, #16213e sidebar at 280px width,
#0f3460 cards with 16px padding, border-radius 12px. Font: Inter 14px.
```

Good:
```
SaaS analytics dashboard for a B2B product team. Clean, minimal feel.
Sidebar navigation, KPI cards for key metrics, a usage trend chart, and a
recent activity feed. Professional but approachable. Think Linear meets Stripe.
```

**Ready to build, or ask first?** If you can name the **purpose**, **audience**, and **3–5 features**, build. If you can't ("build me a website"), ask — everything in one message, no drip-feeding. If the user won't specify, don't stall: generate 3 variants (see [Explore mode](#explore-mode-parallel-variants)). Showing beats asking.

### Options that actually exist

`framework` is **`html` or `react` only**, and **defaults to `html`** over MCP. If the user wants React, say so explicitly.

`styling` is per-type — passing the wrong one is rejected:

| Type | Valid `styling` | Valid `uiLibrary` |
|---|---|---|
| `p2c` | `tailwind`, `css`, `inline_styles` | *(none — not supported)* |
| `l2c` | `tailwind`, `inline_styles`, `vanilla_css` | `shadcn` |
| `f2c` | `tailwind`, `plain_css`, `css_modules`, `inline_styles` | `mui`, `antd`, `shadcn`, `clean_react` |

`language` (`typescript` / `javascript`) applies only when `framework` is `react`, and only to `l2c` and `f2c` — `p2c` accepts it but discards it. `l2c` with `framework: "react"` is always TypeScript regardless of what you pass; with the default `html` framework there is no language at all. `guidelines` is `p2c` only. `name` is ignored by generation types — they name themselves from the content; rename afterwards with `artifact-update_metadata`.

### Figma URLs

`https://figma.com/design/:fileKey/:name?node-id=1-2`

- **`fileKey`** — the segment after `/design/`
- **`nodesId`** — the `node-id` value with `-` replaced by `:` (`42-15` → `["42:15"]`)

### Examples

**MCP:**
```
artifact-create(
  type: "p2c",
  prompt: "SaaS analytics dashboard for a B2B product team. Clean, minimal feel. Sidebar navigation, KPI cards, a usage trend chart, and a recent activity feed.",
  framework: "react",
  styling: "tailwind"
)
→ { status: "generating", sessionId: "mr25vsjppVtbMx", previewUrl, playgroundUrl }

artifact-status(sessionId: "mr25vsjppVtbMx", wait: true)
→ { status: "ready", playgroundUrl, previewUrl }
```

**CLI:**
```bash
anima create -t p2c -p "SaaS analytics dashboard for a B2B product team..." \
  --framework react --guidelines "Dark mode, accessible contrast"

anima create -t l2c -u https://stripe.com/payments --framework react --ui-library shadcn

anima create -t f2c --file-key "https://figma.com/design/abc123/My-File?node-id=42-15" \
  --framework react --ui-library shadcn
```

The CLI parses full Figma URLs and normalizes node IDs for you.

**Pass `--framework react` whenever you pass `--ui-library` or `--language`.** The CLI defaults generation to `html`, and the server rejects both fields unless the framework is `react`.

> **The CLI does not wait for generation.** `anima create` prints "Artifact created!" as soon as the artifact is registered — while p2c/l2c/f2c are still building — and there is no `anima status` command. To know when the app is actually ready, use the MCP `artifact-status(wait: true)` cycle. Own-code types (`empty` / `import`) are genuinely finished when the command returns.

### Explore mode: parallel variants

When the user says "build me X" or "prototype X", generate several interpretations at once instead of one:

1. Write **3 prompt variants** — same core idea, different creative angle (faithful / opinionated / different visual language).
2. Fire all 3 `artifact-create` calls **in parallel**.
3. Run the `artifact-status(wait: true)` cycle for each as it comes back.
4. Publish each one only if the user asked for live URLs (see Job E), then return the set for comparison. Screenshot each if you have that ability.

Because they run in parallel, three variants cost roughly the wall-clock of one.

> **Three is the ceiling, not a suggestion.** A single user may have at most **3 active jobs** at once, counted across generation, codegen, and deploy. Three variants sit exactly on that cap, so a concurrent publish or a leftover job makes one variant fail with `Too many concurrent jobs`. If you see that error, wait for one to finish and retry it — don't reduce the request to two silently.

---

## Job B: Bring your own code

Two types, both **ready immediately** — no status polling:

**`import`** — your code becomes the first commit. Pass **exactly one** transport:

- `files` — a `{path: content}` map of UTF-8 text. Text only, capped at **1000 files** and **10 MB** decoded. (The tool description says "roughly 100 KB"; the enforced limits are the ones above, and the file count is the one that usually bites.)
- `zipUploadId` — for binaries or anything larger. Three steps:
  1. `artifact-get_zip_upload_url()` → `{ zipUploadId, uploadUrl }`
  2. HTTP `PUT` the zip to `uploadUrl` (treat it as a secret)
  3. `artifact-create(type: "import", zipUploadId: "...")` within **30 minutes**; the id is single-use

  Zip limits: **50 MB max**, source/config/assets only — **no `node_modules`, no build output**. Shell and executable files are skipped and reported back.

**`empty`** — a repo you push your own code to. `framework` is **required** here (there are no files to detect it from); declare `react` if you intend to push React code.

> It is not literally empty: `empty` lands an initial commit containing a seed `README.md`. **Clone it and commit on top** — pushing an unrelated local history is rejected as a non-fast-forward.

Both normally return `gitRemoteUrl` **with a read-write git token in the same response** — when it's there, clone it directly instead of calling `artifact-get_git_token`. If the response has no `gitRemoteUrl` (the mint can be skipped or fail), follow its `nextSteps` and call `artifact-get_git_token`.

```bash
anima create -t import --from ./my-project --name "My project"
anima create -t empty --framework react --name "My project"
```

---

## Job C: Edit an existing artifact

An artifact is a real git repo. Git is your route to its files — the webapp is the human's.

```
artifact-get_git_token(sessionId: "mr25vsjppVtbMx")
→ { gitRemoteUrl }
```

```bash
git clone <gitRemoteUrl> && cd <repo>
# edit, commit
git push          # pushing updates the live artifact
```

- The `gitRemoteUrl` embeds a **short-lived, single-artifact token** — treat it as a secret, never log or echo it.
- Lifetime is `ttlSeconds`: default and max **3600**, minimum **300**.
- **Tokens cannot be renewed.** On a "token expired" git error, call the tool again and point the remote at the fresh URL:
  ```bash
  git remote set-url origin <new gitRemoteUrl>
  ```
- Read-only or read-write is decided by your access to the artifact.

To change the **name or visibility** instead of the content, that's metadata — use `artifact-update_metadata`, not git.

Don't know the `sessionId`? `workspace-list_artifacts()` (no parameters) lists your team's artifacts with theirs.

---

## Job D: Figma into an existing codebase

`codegen-figma_to_code` returns files for **your** project. It creates no artifact and hosts nothing.

**Match the user's actual stack** — detect it, don't assume:

| Their stack | Parameter |
|---|---|
| React / not React | `framework`: `react` / `html` |
| Tailwind, plain CSS | `styling`: `tailwind` / `plain_css` |
| TypeScript | `language`: `typescript` |
| MUI, Ant Design, shadcn | `uiLibrary`: `mui` / `antd` / `shadcn` |
| No UI library | `uiLibrary`: `clean_react`, or omit it |

Requires the `X-Figma-Token` header (a Figma personal access token).

```
codegen-figma_to_code(
  fileKey: "abc123XYZ",
  nodesId: ["42:15"],
  framework: "react",
  styling: "tailwind",
  language: "typescript",
  uiLibrary: "shadcn",
  assetsBaseUrl: "./assets"
)
```

```bash
anima codegen --file-key "https://figma.com/design/abc123/My-File?node-id=42-15" \
  -o ./components --ui-library shadcn
```

**After the call, you are not done.** The response carries more than code:

1. **Download the images in `snapshotsUrls`** and actually look at them — they're the visual ground truth for the design. They are **JPEG**, served straight from Figma's CDN at the design's full resolution, so a single frame can run past 1 MB. The URLs have no file extension — that's Figma's URL format, not something missing. When you re-embed one for a model, take the media type from the response's `Content-Type`; hardcoding `image/png` gets the request rejected.
2. Implement using **both** the generated code and the snapshots.
3. Map `data-variant` attributes in the generated components onto your component props.
4. Pull CSS variables out of the generated styles for exact colors.
5. **Follow `guidelines` from the response** — it's the per-generation instruction set.
6. Compare your finished implementation against the snapshot.
7. Download everything in `assets` and place it at your `assetsBaseUrl` path, or the generated references will 404.

**`files` is filtered, not a full project.** Boilerplate is stripped before you see it: `package.json`, `tsconfig*.json`, `vite.config.*`, entry points (`src/index.*`, `src/main.*`), `*.d.ts`, `src/lib/utils.*`, and **everything under `src/components/`**. Extracted and shadcn components live in that last path, so don't expect them in the response or conclude the generation failed — work from the files you do get, plus `guidelines` and the snapshots.

---

## Job E: Publish

```
artifact-publish(sessionId: "mr25vsjppVtbMx", mode: "webapp")
→ { success, liveUrl, subdomain }
```

**Publishing makes the app public to the world.** It is *not* required for sharing — the artifact is already viewable at its `playgroundUrl` by anyone who can reach it. Only publish when the user explicitly asked to publish or deploy; otherwise share the URL and offer publishing as a follow-up.

- `mode: "webapp"` is the default and the only mode available over MCP. **`designSystem` always fails over MCP** with an enterprise contact link — don't offer it as a capability.
- `artifact-unpublish(sessionId)` takes the live URL offline. It does not delete the artifact or its code, and re-publishing reuses the same subdomain.

```bash
anima publish <sessionId>
anima unpublish <sessionId>
```

---

## Other lifecycle tools

**`artifact-update_metadata(sessionId, name?, privacy?)`** — display name and/or visibility (`public` = anyone with the link, `private` = team only). Send at least one. Never touches code.

**`artifact-duplicate(sessionId, name?)`** — clones an artifact into a new, independent one in your team's Default workspace. Copies code, assets, and supported database content; does **not** copy chat or custom domains. Source must be in your current team. Default name is `"<source name> (Copy)"`.

> **Not idempotent.** If a duplicate call times out or its response is lost, call `workspace-list_artifacts` to check before retrying — the first call may have already created the copy.

**`workspace-list_artifacts()`** — no parameters; lists your team's artifacts. App rows carry a `sessionId` (what the `artifact-*` tools need); `markdown` and `asset` rows carry only an `id`. The result may set `truncated`, and an agent without `read` access gets an empty list rather than an error.

---

## CLI ↔ MCP map

| Action | CLI | MCP |
|---|---|---|
| Generate | `anima create -t p2c\|l2c\|f2c ...` (does not await completion) | `artifact-create` + `artifact-status` |
| Import own code | `anima create -t import --from <path>` | `artifact-get_zip_upload_url` + `artifact-create` |
| Empty repo | `anima create -t empty --framework <fw>` | `artifact-create` |
| Edit content | `anima get-git-token <url\|id>` | `artifact-get_git_token` |
| List artifacts | `anima list` | `workspace-list_artifacts` |
| Rename / visibility | `anima update <id> --name --privacy` | `artifact-update_metadata` |
| Duplicate | `anima duplicate <url\|id>` | `artifact-duplicate` |
| Publish / unpublish | `anima publish\|unpublish <id>` | `artifact-publish` / `artifact-unpublish` |
| Figma → code files | `anima codegen --file-key <key> -o <dir>` | `codegen-figma_to_code` |

**Which to use:** the CLI needs no MCP setup and works headless, so it's the better fit for own-code flows (`empty`, `import`) and one-shot codegen. **For generation (p2c/l2c/f2c), prefer MCP** — only `artifact-status` can tell you the app finished, and the CLI cannot call it.

Watch the framework defaults, which differ by tool: `artifact-create` defaults to **`html`** (both over MCP and in the CLI), while `codegen-figma_to_code` and `anima codegen` default to **`react`**. Pass `--framework` / `framework` explicitly and you never have to remember which is which.

---

## References

- [Setup and authentication](references/setup.md)
- [Full MCP tool reference](references/mcp-tools.md)
- [Git workflow](references/git-workflow.md)
- [Worked examples](references/workflows.md)
- [Troubleshooting](references/troubleshooting.md)
