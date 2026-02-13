# MCP Tools Reference

## playground-create

Create an Anima Playground from a prompt, website URL, or Figma design.

| Parameter | Required | Type | Description |
|---|---|---|---|
| `type` | Yes | string | `p2c` (prompt), `l2c` (website URL), or `f2c` (Figma) |
| `prompt` | p2c only | string | Text description of what to build |
| `guidelines` | No | string | Additional coding guidelines (p2c only) |
| `url` | l2c only | string | Website URL to clone |
| `fileKey` | f2c only | string | Figma file key from URL |
| `nodesId` | f2c only | array | Figma node IDs (use `:` not `-`) |
| `framework` | No | string | `react` or `html` |
| `styling` | No | string | Varies by type (see below) |
| `language` | No | string | `typescript` or `javascript` (react only) |
| `uiLibrary` | No | string | UI library (react only, varies by type) |

**Styling options per type:**

| Type | Styling options |
|---|---|
| p2c | `tailwind`, `css`, `inline_styles` |
| l2c | `tailwind`, `inline_styles` |
| f2c | `tailwind`, `plain_css`, `css_modules`, `inline_styles` |

**UI Library options per type:**

| Type | UI Library options |
|---|---|
| p2c | Not supported |
| l2c | `shadcn` only |
| f2c | `mui`, `antd`, `shadcn`, `clean_react` |

**Returns:** `{ success, sessionId, playgroundUrl }`

## playground-publish

Publish a playground to a live URL or as an npm package.

| Parameter | Required | Type | Description |
|---|---|---|---|
| `sessionId` | Yes | string | Session ID from `playground-create` |
| `mode` | No | string | `webapp` (default) or `designSystem` |
| `packageName` | designSystem only | string | npm package name |
| `packageVersion` | designSystem only | string | npm package version |

**Returns (webapp):** `{ success, liveUrl, subdomain }`

**Returns (designSystem):** `{ success, packageUrl, packageName, packageVersion }`

## codegen-figma_to_code

Convert Figma design to production-ready code directly (no playground). **Path B only.**

| Parameter | Required | Type | Description |
|---|---|---|---|
| `fileKey` | Yes | string | Figma file key from URL |
| `nodesId` | Yes | array | Node IDs to convert (use `:` not `-`) |
| `framework` | No | string | `react` or `html` (default: react) |
| `styling` | No | string | `tailwind`, `plain_css`, `css_modules`, or `inline_styles` |
| `language` | No | string | `typescript` or `javascript` (default: typescript) |
| `uiLibrary` | No | string | `mui`, `antd`, `shadcn`, or `clean_react` |
| `assetsBaseUrl` | No | string | Base path for assets (e.g., `./assets`) |

**Returns:** `{ files, assets, snapshotsUrls, guidelines, tokenUsage }`

## project-download_from_playground

Download project files from an Anima Playground session. **Path B only.**

| Parameter | Required | Type | Description |
|---|---|---|---|
| `playgroundUrl` | Yes | string | Full Anima Playground URL |

**Returns:** Pre-signed download URL for zip file (valid 10 minutes)

## project-generate_upload_url

Generate pre-signed URLs for uploading a project zip file to Anima.

**Parameters:** None

**Returns:** `{ sessionId, uploadUrl, downloadUrl }` (URLs expire in 10 minutes)

## project-upload_to_playground

Upload a project to Anima playground from a zip file URL.

| Parameter | Required | Type | Description |
|---|---|---|---|
| `zipUrl` | Yes | string | Pre-signed GET URL from `project-generate_upload_url` |
| `sessionId` | Yes | string | Session ID from `project-generate_upload_url` |
| `projectName` | No | string | Project name (extracted from package.json if omitted) |

**Returns:** `{ sessionId, playgroundUrl }`

## design_system-get_manifest

Get the manifest.json describing a design system's documentation structure.

| Parameter | Required | Type | Description |
|---|---|---|---|
| `dsId` | Yes | string | The design system ID |

**Returns:** JSON object mapping file/folder paths to metadata.

## design_system-get_files

Fetch multiple documentation files by path.

| Parameter | Required | Type | Description |
|---|---|---|---|
| `dsId` | Yes | string | The design system ID |
| `filePaths` | Yes | array | File paths to fetch (e.g., `["README.md", "COMPONENTS.md"]`) |

**Returns:** JSON object mapping file paths to content.
