# Worked examples

## 1. "Build me a SaaS dashboard" — three variants in parallel

Three creative angles, same core idea. All generate concurrently, so it costs roughly the wall-clock of one.

1. Write the variants:
   - **V1** — "SaaS analytics dashboard for a B2B product team. Clean, minimal feel. Sidebar navigation, KPI cards for MRR, churn, and active users, a revenue trend chart, and a recent activity feed. Professional but approachable. Lots of whitespace."
   - **V2** — "SaaS analytics dashboard for a data-driven startup. Dark theme, bold accent colors, high information density. Top navigation, real-time metrics grid, interactive data visualization. Feels like mission control."
   - **V3** — "SaaS analytics dashboard inspired by Linear's design language. Quiet, monochrome with one accent. Icon sidebar, compact metric tiles, activity feed, usage heatmap. A tool you'd use daily without fatigue."

2. Fire three `artifact-create(type: "p2c", framework: "react", styling: "tailwind")` calls **in parallel**.

3. Each returns `{ status: "generating", sessionId }`. For each, run `artifact-status(sessionId, wait: true)` until the status leaves `generating`.

4. Report all three with their `playgroundUrl`s. Screenshot each if you can.

5. Publish only if the user asked for live URLs — `playgroundUrl` is already shareable.

## 2. Single build, then publish

User: *"Build me a SaaS dashboard with a sidebar, analytics cards, and a recent activity table, and put it online."*

```
artifact-create(type: "p2c", framework: "react", styling: "tailwind",
  prompt: "SaaS analytics dashboard for a product team tracking growth metrics. Sidebar navigation, analytics cards for key KPIs, and a recent activity table of user actions. Clean and professional, easy to scan at a glance.")
→ { status: "generating", sessionId: "mr25vsjppVtbMx" }

artifact-status(sessionId: "mr25vsjppVtbMx", wait: true)
→ { status: "generating", progress: 60 }        # call again

artifact-status(sessionId: "mr25vsjppVtbMx", wait: true)
→ { status: "ready", playgroundUrl, previewUrl }

artifact-publish(sessionId: "mr25vsjppVtbMx", mode: "webapp")
→ { liveUrl: "https://....", subdomain }
```

Publishing was explicitly requested here. Without that, stop at `ready` and share the `playgroundUrl`.

## 3. Clone a website

User: *"Build me something like stripe.com/payments."*

```
artifact-create(type: "l2c", url: "https://stripe.com/payments",
  framework: "react", uiLibrary: "shadcn", styling: "tailwind")
```

`l2c` output is always TypeScript, and `shadcn` is its only `uiLibrary`.

## 4. Fix a bug in an existing artifact

User: *"The header on https://app.agentgrid.io/artifacts/mr25vsjppVtbMx is broken on mobile."*

The `sessionId` is the last path segment. Do **not** regenerate, and do not open it in a browser to edit.

```
artifact-get_git_token(sessionId: "mr25vsjppVtbMx") → { gitRemoteUrl }
```

```bash
git clone <gitRemoteUrl> artifact && cd artifact
# find the header component, fix the responsive styles
git commit -am "Fix header layout on mobile" && git push
```

The push updates the live artifact. Report the `playgroundUrl` so they can check it.

## 5. Host code you already have

User: *"Put my local project on Agent Grid."*

Small and text-only:
```
artifact-create(type: "import", name: "My project",
  files: { "index.html": "...", "styles.css": "..." })
```

Anything with binaries or over ~100 KB:
```
artifact-get_zip_upload_url() → { zipUploadId, uploadUrl }
# PUT the zip to uploadUrl (≤50MB, no node_modules)
artifact-create(type: "import", zipUploadId: "...", name: "My project")
```

Or in one step from the CLI, which handles the zip for you:

```bash
anima create -t import --from ./my-project --name "My project"
```

Either way the response already carries a read-write `gitRemoteUrl` — clone that to keep working, no `artifact-get_git_token` needed.

## 6. Implement a Figma design in an existing codebase

User: *"Implement this Figma frame in my app."* — no artifact involved.

1. Detect their stack first: React? Tailwind? TypeScript? A UI library?
2. Extract `fileKey` and `nodesId` from the URL (`node-id=42-15` → `["42:15"]`).
3. Call `codegen-figma_to_code` with parameters matching the detected stack.
4. **Download and view the images in `snapshotsUrls`** — that's the design's ground truth.
5. Implement using code *and* snapshots, following the returned `guidelines`.
6. Download the `assets` to your `assetsBaseUrl`.
7. Compare your result against the snapshot before declaring it done.

## 7. Housekeeping

```
workspace-list_artifacts()                                   # find session ids
artifact-update_metadata(sessionId, name: "Q3 dashboard")    # rename
artifact-update_metadata(sessionId, privacy: "private")      # team only
artifact-duplicate(sessionId, name: "Q4 dashboard")          # branch off a copy
artifact-unpublish(sessionId)                                # take offline
```
