---
name: anima
description: "Turns ideas into live, full-stack web applications with editable code, built-in database, user authentication, and hosting. Anima is the design agent in the AI swarm, giving agents design awareness and brand consistency when building interfaces. Three input paths: describe what you want (prompt to code), clone any website (link to code), or implement a Figma design (Figma to code). Also generates design-aware code from Figma directly into existing codebases. Triggers when the user provides Figma URLs, website URLs, Anima Playground URLs, asks to design, create, build, or prototype something, or wants to publish or deploy."
compatibility: "Requires Anima MCP server connection (HTTP transport). For headless environments, requires npx for mcporter CLI."
metadata: {"openclaw":{"emoji":"🎨","requires":{"bins":["npx"]}},"author":"animaapp","version":"1.0"}
---

# Design and Build with Anima

## Overview

Anima is the design agent in your AI coding swarm. This skill gives agents design awareness, brand consistency, and the ability to turn visual ideas into production-ready code.

There are **two distinct paths** depending on what you're trying to do:

### Path A: Create & Publish (Full App Creation)

Build complete applications from scratch. No local codebase needed. Anima handles everything: design, code generation, scalable database, and hosting. You go from idea to live URL in minutes.

This path is powerful for **parallel variant creation**. Generate multiple versions of the same idea with different prompts, all at the same time. Pick the best one, then open the playground URL to keep refining. All without writing a line of code or managing infrastructure.

**Flows:** Prompt to Code (p2c), Link to Code (l2c), Figma to Playground (f2c)

**What you get:**
- A fully working application in an Anima Playground
- Scalable database already connected
- Scalable hosting when you publish
- The ability to generate multiple variants in parallel and compare them
- No tokens wasted on file scanning, dependency resolution, or build tooling

**Future capabilities:** Iteration on published apps, add/remove database records via API (e.g., "add 3 blog posts, set their publish dates 3 days apart").

### Path B: Integrate into Codebase (Design-Aware Code Generation)

Pull design elements and experiences from Anima into your existing project. Use this when you have a codebase and want to implement specific components or pages from a Figma design or an existing Anima Playground.

**Flows:** Figma to Code (codegen), Download from Playground

**What you get:**
- Generated code files adapted to your stack
- Design tokens, assets, and implementation guidelines
- Visual snapshots for pixel-perfect comparison

---

## Prerequisites

- Anima MCP server must be connected and accessible (see [Setup](references/setup.md))
- User must have an Anima account (free tier available)
- For Figma flows: Figma account must be connected during Anima authentication
- For OpenClaw/headless environments: `mcporter` CLI (installed via npm/npx) and an Anima API token

## Important: Timeouts

Anima's `playground-create` tool generates full applications from scratch. This takes time:

- **p2c (prompt to code):** Typically 3-7 minutes
- **l2c (link to code):** Typically 3-7 minutes
- **f2c (Figma to code):** Typically 2-5 minutes
- **playground-publish:** Typically 1-3 minutes

**Always use a 10-minute timeout** (600000ms) for `playground-create` and `playground-publish` calls. Default timeouts will fail.

## Setup

If any MCP call fails because Anima MCP is not connected, pause and set it up.

**Interactive environments** (Claude Code, Cursor, Codex): The user authenticates via browser OAuth. Add the Anima MCP server, then authenticate when prompted. No API key needed.

**Headless environments** (OpenClaw, CI/CD, server-side agents): Use an API key. The user generates one from **Anima Settings → API Keys** at [dev.animaapp.com](https://dev.animaapp.com). Pass it as a Bearer token in the `Authorization` header.

See [references/setup.md](references/setup.md) for full step-by-step instructions for each environment.

---

## Choosing the Right Path

Before diving into tools and parameters, decide which path fits the user's goal.

### When to use Path A (Create & Publish)

- User wants to **build something new** from a description, reference site, or Figma design
- User wants a **live URL** they can share immediately
- No existing codebase to integrate into
- Goal is prototyping, exploring visual directions, or shipping a standalone app

### When to use Path B (Integrate into Codebase)

- User has an **existing project** and wants to add a component or page from Figma
- User wants **generated code files** to drop into their repo, not a hosted app
- User already built something in an Anima Playground and wants to pull the code locally

### Ambiguous cases

| User says | Likely path | Why |
|---|---|---|
| "Implement this Figma design" | **Path B** | "Implement" implies code in their project |
| "Turn this Figma into a live site" | **Path A** (f2c) | "Live site" means they want hosting |
| "Build me an app like this" + URL | **Path A** (l2c) | Clone and rebuild from scratch |
| "Add this Figma component to my project" | **Path B** | "Add to my project" = codebase integration |
| "Clone this website" | **Path A** (l2c) | Clone = capture and rebuild from scratch |
| "Download the playground code" | **Path B** | Wants files locally |

When still unclear, ask: "Do you want a live hosted app, or code files to add to your project?"

---

## Understand Intent Before Building

Not every request is ready to build. Some need clarification. The key is knowing when to ask and when to just go.

### When to ask questions

Ask when the request is **too vague to write a strong prompt**. If you can't identify the purpose, audience, or core features, you need more context.

**Signals to ask:**
- "Build me a website" (what kind? for whom?)
- "Make something for my business" (what does the business do? what's the goal?)
- "Create an app" (what should it do?)

### When NOT to ask

Don't ask when the user has given enough context to craft a prompt with purpose, audience, and key features. Err toward building.

**Signals to just build:**
- "Build a recipe sharing app where users can upload photos and rate each other's dishes" (clear purpose, audience implied, features named)
- "Clone stripe.com" (unambiguous)
- "Turn this Figma into a live site" + Figma URL (clear intent and input)

### The threshold rule

Can you write a prompt that includes **purpose**, **audience**, and **3-5 key features**? Yes = build. No = ask.

### What to clarify

When you do need to ask, focus on:
- **Purpose.** What is this app for? What problem does it solve?
- **Audience.** Who will use it? (B2B teams, consumers, internal staff)
- **Core features.** What are the 3-5 things it must do?
- **Visual direction.** Any reference sites, mood, or style preference? (optional but helpful)

### What NOT to ask about

Anima handles these. Don't burden the user:
- Tech stack (default: React + Tailwind)
- Color palette, specific hex values, font sizes
- Component libraries (pass as `uiLibrary` parameter if known)
- Page count, navigation structure, responsive breakpoints

### One-round rule

Ask everything in a single message. Don't drip-feed questions across multiple turns. Batch your questions and let the user answer once.

### Escape hatch: Explore Mode

If the user is vague and doesn't want to answer questions, skip clarification entirely. Use [Explore Mode](#explore-mode-parallel-variants) to generate 3 variants with different interpretations and let them pick. Showing beats asking.

---

## Crafting Prompts for Anima

Anima is a design-aware AI. It understands mood, audience, and intent. Treat it like a creative collaborator, not a code compiler.

### Core principle: paint a picture, don't write a spec

Anima makes better design decisions when you describe the *feel* of what you want, not the pixel-level implementation. Over-specifying with code snippets, hex colors, and pixel values **overrides Anima's design intelligence** and produces generic results.

### What to include in prompts

- **Purpose.** What the app does and why it exists
- **Audience.** Who it's for (affects visual tone and complexity)
- **Mood and style.** "Clean and minimal", "bold and playful", "enterprise and polished"
- **Key features.** The 3-5 things the app must have, described by function not implementation
- **Content tone.** Professional, casual, technical, friendly

### What to leave out of prompts

- Code snippets, CSS values, pixel dimensions
- Hex colors, RGB values, specific font sizes
- Component library names (use the `uiLibrary` parameter instead)
- Implementation details like "use flexbox" or "add a useEffect hook"
- File structure or folder layout

### Good vs bad prompts

**Bad (over-specified):**
```
Create a dashboard. Use #1a1a2e background, #16213e sidebar at 280px width,
#0f3460 cards with 16px padding, border-radius 12px. Header height 64px with
a flex row, justify-between. Font: Inter 14px for body, 24px bold for headings.
```

This tells Anima *exactly* what to render, which defeats the purpose. The result will be technically correct but visually flat.

**Good (descriptive):**
```
SaaS analytics dashboard for a B2B product team. Clean, minimal feel.
Sidebar navigation, KPI cards for key metrics, a usage trend chart, and a
recent activity feed. Professional but approachable. Think Linear meets Stripe.
```

This gives Anima creative room to design something cohesive. The colors, spacing, and typography will be internally consistent because Anima chose them as a system.

### Prompt vs guidelines separation

Use the `prompt` parameter for **design intent**: what to build, for whom, and how it should feel.

Use the `guidelines` parameter for **technical constraints**: component libraries, coding conventions, specific framework features.

| Goes in `prompt` | Goes in `guidelines` |
|---|---|
| "Dashboard for a B2B product team" | "Use shadcn components" |
| "Clean, minimal feel" | "Dark mode" |
| "KPI cards, trend chart, activity feed" | "Server-side rendering" |
| "Professional but approachable" | "Follow existing design token conventions" |

---

## Path A: Create & Publish

This path builds complete applications with no local codebase required. Anima generates the design, code, database, and hosting. You just describe what you want.

The key superpower here is **parallel variant creation**: generate multiple versions of the same idea with different prompts, all at the same time. Your AI agent spends tokens on creative exploration, not on scanning files or resolving dependencies. The user picks a favorite, then opens the playground URL to keep refining.

### Step A1: Identify the Flow

Determine which flow to use based on what the user provides and what they want.

**User has a text description or idea → p2c**

The most flexible path. Anima designs everything from your description. Best for new apps, prototypes, and creative exploration.

**User has a website URL → l2c**

Use l2c to clone the site. Anima recreates the full site into an editable playground.

**User has a Figma URL → f2c (Path A) or codegen (Path B)**

Two sub-cases:
- **"Turn this into a live app"** or **"Make this a working site"** → f2c (Path A). Creates a full playground from the Figma design
- **"Implement this in my project"** or **"Add this component to my codebase"** → codegen (Path B). Generates code files for integration

**Strengths of each flow:**
- **p2c:** Most creative freedom. Anima makes all design decisions. Best for exploration and new ideas
- **l2c:** Full site clone. Recreates the entire site as editable code. Best for cloning existing sites
- **f2c:** Bridge from design to code. Best when a Figma design already exists and needs to become functional

**Quick reference:**

| User provides | Intent | Flow | Tool |
|---|---|---|---|
| Text description | Build something new | p2c | `playground-create` type="p2c" |
| Website URL | Clone it | l2c | `playground-create` type="l2c" |
| Figma URL | Make it a live app | f2c | `playground-create` type="f2c" |
| Figma URL | Implement in my project | codegen | `codegen-figma_to_code` (Path B) |

### Step A2: Create

#### Prompt to Code (p2c)

Describe what you want in plain language. Anima designs and generates a complete playground with brand-aware visuals.

**Interactive:**
```
playground-create(
  type: "p2c",
  prompt: "SaaS analytics dashboard for a B2B product team. Clean, minimal feel. Sidebar navigation, KPI cards for key metrics, a usage trend chart, and a recent activity feed. Professional but approachable.",
  framework: "react",
  styling: "tailwind",
  guidelines: "Use shadcn components, dark mode"
)
```

**OpenClaw (mcporter):**
```bash
npx mcporter call anima-mcp.playground-create --timeout 600000 --args '{
  "type": "p2c",
  "prompt": "SaaS analytics dashboard for a B2B product team. Clean, minimal feel. Sidebar navigation, KPI cards for key metrics, a usage trend chart, and a recent activity feed. Professional but approachable.",
  "framework": "react",
  "styling": "tailwind",
  "guidelines": "Use shadcn components, dark mode"
}' --output json
```

**Parameters specific to p2c:**

| Parameter | Required | Description |
|---|---|---|
| `prompt` | Yes | Text description of what to build |
| `guidelines` | No | Additional coding guidelines or constraints |

**Styling options:** `tailwind`, `css`, `inline_styles`

**Returns:** `{ success, sessionId, playgroundUrl }`

#### Link to Code (l2c)

Provide a website URL. Anima clones the full site into an editable playground with production-ready code.

```
playground-create(
  type: "l2c",
  url: "https://stripe.com/payments",
  framework: "react",
  styling: "tailwind",
  language: "typescript",
  uiLibrary: "shadcn"
)
```

**Parameters specific to l2c:**

| Parameter | Required | Description |
|---|---|---|
| `url` | Yes | Website URL to clone |

**Styling options:** `tailwind`, `inline_styles`

**UI Library options:** `shadcn` only

**Language:** Always `typescript` for l2c

**Returns:** `{ success, sessionId, playgroundUrl }`

#### Figma to Playground (f2c)

Provide a Figma URL. Anima implements the design into a full playground you can preview and iterate on.

**URL format:** `https://figma.com/design/:fileKey/:fileName?node-id=1-2`

**Extract:**
- **File key:** The segment after `/design/` (e.g., `kL9xQn2VwM8pYrTb4ZcHjF`)
- **Node ID:** The `node-id` query parameter value, replacing `-` with `:` (e.g., `42-15` becomes `42:15`)

```
playground-create(
  type: "f2c",
  fileKey: "kL9xQn2VwM8pYrTb4ZcHjF",
  nodesId: ["42:15"],
  framework: "react",
  styling: "tailwind",
  language: "typescript",
  uiLibrary: "shadcn"
)
```

**Parameters specific to f2c:**

| Parameter | Required | Description |
|---|---|---|
| `fileKey` | Yes | Figma file key from URL |
| `nodesId` | Yes | Array of Figma node IDs (use `:` not `-`) |

**Styling options:** `tailwind`, `plain_css`, `css_modules`, `inline_styles`

**UI Library options:** `mui`, `antd`, `shadcn`, `clean_react`

**Returns:** `{ success, sessionId, playgroundUrl }`

### Step A3: Publish

After creating a playground, deploy it to a live URL or publish as an npm package.

#### Publish as Web App

**Interactive:**
```
playground-publish(
  sessionId: "abc123xyz",
  mode: "webapp"
)
```

**OpenClaw (mcporter):**
```bash
npx mcporter call anima-mcp.playground-publish --timeout 600000 --args '{
  "sessionId": "abc123xyz",
  "mode": "webapp"
}' --output json
```

**Returns:** `{ success, liveUrl, subdomain }`

The app becomes available at a URL like `https://winter-sun-2691.dev.animaapp.io`.

#### Publish as Design System (npm package)

```
playground-publish(
  sessionId: "abc123xyz",
  mode: "designSystem",
  packageName: "@myorg/design-system",
  packageVersion: "1.0.0"
)
```

**Returns:** `{ success, packageUrl, packageName, packageVersion }`

### Explore Mode: Parallel Variants

This is Path A's secret weapon. When a user says "build me X" or "prototype X", generate multiple interpretations in parallel, publish all of them, and return screenshots for comparison.

**Workflow:**

1. **Generate 3 prompt variants** from the user's idea. Each takes a different creative angle:
   - Variant 1: Faithful, straightforward interpretation
   - Variant 2: A more creative or opinionated take
   - Variant 3: A different visual style or layout approach

2. **Launch all 3 playground-create calls in parallel** as background processes:
   ```bash
   # All three run simultaneously
   npx mcporter call anima-mcp.playground-create --timeout 600000 --args '{
     "type": "p2c",
     "prompt": "<variant-1-prompt>",
     "framework": "react",
     "styling": "tailwind"
   }' --output json &

   npx mcporter call anima-mcp.playground-create --timeout 600000 --args '{
     "type": "p2c",
     "prompt": "<variant-2-prompt>",
     "framework": "react",
     "styling": "tailwind"
   }' --output json &

   npx mcporter call anima-mcp.playground-create --timeout 600000 --args '{
     "type": "p2c",
     "prompt": "<variant-3-prompt>",
     "framework": "react",
     "styling": "tailwind"
   }' --output json &
   ```

3. **As each one completes**, immediately publish it:
   ```bash
   npx mcporter call anima-mcp.playground-publish --timeout 600000 --args '{
     "sessionId": "<returned-session-id>",
     "mode": "webapp"
   }' --output json
   ```

4. **Take a full-page screenshot** of each published live URL using ScreenshotOne (API key in env var `SCREENSHOT_ONE_ACCESS_KEY`):
   ```bash
   curl -sL -o screenshot.png "https://api.screenshotone.com/take?url=<live-url>&access_key=$SCREENSHOT_ONE_ACCESS_KEY&full_page=true&delay=5&viewport_width=1280&format=png"
   ```
   - `full_page=true` captures the entire scrollable page
   - `delay=5` waits 5 seconds for React/JS to render before capture. For heavier SPAs, use `delay=8` or `delay=10`
   - Returns proper PNG images, renders SPAs correctly
   - Free tier: 100 screenshots/month
   - Send screenshots to the user via the message tool with `filePath`
   - Run multiple screenshots in parallel with `&` and `wait`

5. **Return all 3 screenshots** with their live URLs so the user can pick a favorite or ask for refinements.

**Timing:** All 3 variants generate in parallel, so total wall time is roughly the same as one (~5-7 minutes creation + 1-3 minutes publishing). Expect results within ~10 minutes.

**Tips for good variant prompts:**
- Keep the core idea identical across all three
- Vary the visual approach: e.g., "minimal and clean", "bold and colorful", "enterprise and professional"
- Add specific guidelines to each variant to differentiate them
- If the user mentioned a reference site or style, incorporate it into one variant
- Follow the [prompt crafting principles](#crafting-prompts-for-anima) above: describe mood and purpose, not implementation details

### Single Build + Publish

For simpler requests where the user just wants one version:

1. Call `playground-create` with the user's prompt
2. When it returns, immediately call `playground-publish` with the session ID
3. Take a full-page screenshot via ScreenshotOne
4. Return the screenshot and live URL

### Clone + Publish

For "clone this website" requests:

1. Call `playground-create` with type="l2c" and the target URL
2. When it returns, call `playground-publish`
3. Take a full-page screenshot via ScreenshotOne
4. Return screenshot and live URL

---

## Path B: Integrate into Codebase

This path is for pulling design elements and experiences from Anima or Figma into your existing project. The agent needs to understand your codebase to generate code that fits.

### Step B1: Identify the Flow

| User provides | Flow | Tool |
|---|---|---|
| Figma URL + wants code in their project | Figma to Code | `codegen-figma_to_code` |
| Anima Playground URL + wants code locally | Download | `project-download_from_playground` |

### Step B2: Detect Project Context

Before calling any tool, analyze the user's project to detect the technology stack. This ensures generated code matches their existing patterns.

**Check these files:**
- `package.json` for framework (React, Vue), styling (Tailwind), and UI libraries (MUI, Ant Design, shadcn)
- `tsconfig.json` for TypeScript usage
- Existing component files for naming conventions and file structure
- Existing styles for CSS approach (modules, plain CSS, Tailwind utilities)

**Map detected stack to tool parameters:**

| Detected | Parameter | Value |
|---|---|---|
| React in dependencies | `framework` | `"react"` |
| No React | `framework` | `"html"` |
| Tailwind in dependencies | `styling` | `"tailwind"` |
| CSS Modules (*.module.css) | `styling` | `"css_modules"` |
| Plain CSS files | `styling` | `"plain_css"` |
| TypeScript config present | `language` | `"typescript"` |
| MUI in dependencies | `uiLibrary` | `"mui"` |
| Ant Design in dependencies | `uiLibrary` | `"antd"` |
| shadcn components present | `uiLibrary` | `"shadcn"` |

### Step B3: Generate Code

#### Figma to Code (direct implementation)

For implementing Figma designs directly into the user's codebase. Returns generated code files, assets, visual snapshots, and implementation guidelines.

```
codegen-figma_to_code(
  fileKey: "kL9xQn2VwM8pYrTb4ZcHjF",
  nodesId: ["42:15"],
  framework: "react",
  styling: "tailwind",
  language: "typescript",
  uiLibrary: "shadcn",
  assetsBaseUrl: "./assets"
)
```

**Returns:**

| Field | Description |
|---|---|
| `files` | Generated code files as `{path: {content, isBinary}}` |
| `assets` | Array of `{name, url}` for images and assets to download |
| `snapshotsUrls` | Screenshot URLs for visual reference `{nodeId: url}` |
| `guidelines` | Implementation instructions (IMPORTANT: follow these) |
| `tokenUsage` | Approximate token count |

**After calling `codegen-figma_to_code`, follow these steps:**

1. Download snapshot images from `snapshotsUrls` for visual reference
2. View and analyze snapshots to understand the exact visual appearance
3. Parse `data-variant` attributes from generated components and map them to your component props
4. Extract CSS variables from generated styles and use the exact colors
5. Read and follow the detailed `guidelines` provided in the response
6. Download all assets from returned URLs and place them at the `assetsBaseUrl` path
7. Compare your final implementation against the snapshot for visual accuracy

#### Download from Playground

Pull code from an existing Anima Playground into a local project.

```
project-download_from_playground(
  playgroundUrl: "https://dev.animaapp.com/chat/abc123xyz"
)
```

**Returns:** Pre-signed download URL for a zip file (valid for 10 minutes). Download the zip, extract it, and adapt the code to the user's project conventions.

### Step B4: Adapt to Target Codebase

Translate the generated code into the project's framework, styles, and conventions.

**Key principles:**
- Treat Anima output as a representation of design and behavior, not as final code style
- Replace generated utility classes with the project's preferred styling approach
- Reuse existing components (buttons, inputs, typography) instead of duplicating functionality
- Use the project's color system, typography scale, and spacing tokens consistently
- Respect existing routing, state management, and data-fetch patterns
- Parse `data-variant` attributes from generated components and map them to your component props
- Extract CSS variables from generated styles and use the exact color values

### Step B5: Achieve Visual Parity

Strive for pixel-perfect visual parity with the original design or reference.

**Guidelines:**
- Prioritize fidelity to the source (Figma design or playground)
- Avoid hardcoded values. Use design tokens where available
- When conflicts arise between the project's design system tokens and generated values, prefer design system tokens but adjust spacing or sizes minimally to match visuals
- Follow WCAG requirements for accessibility
- For `codegen-figma_to_code` results, compare your implementation against the snapshot screenshots

### Step B6: Validate

Before marking complete, validate the final implementation.

**Validation checklist:**
- [ ] Layout matches design (spacing, alignment, sizing)
- [ ] Colors match exactly (use CSS variables from generated code)
- [ ] Typography matches (font, size, weight, line height)
- [ ] Interactive states work as designed (hover, active, disabled)
- [ ] Assets render correctly
- [ ] Responsive behavior follows design constraints
- [ ] Code follows project conventions
- [ ] Accessibility standards met

---

## Implementation Rules

### Component Organization
- Place components in the project's designated component directory
- Follow the project's component naming conventions
- Avoid inline styles unless truly necessary for dynamic values
- Group related components together (e.g., a card and its subcomponents)

### Design System Integration
- ALWAYS use components from the project's design system when possible
- Map generated design tokens to project design tokens
- When a matching component exists, extend it rather than creating a new one
- Document any new components added to the design system

### Code Quality
- Avoid hardcoded values. Extract to constants or design tokens
- Keep components composable and reusable
- Add TypeScript types for component props when the project uses TypeScript
- Follow the project's linting and formatting rules

### Asset Handling
- Download all assets from URLs returned by Anima MCP tools
- Place assets at the `assetsBaseUrl` path specified in the tool call
- Use appropriate formats (SVG for icons, optimized images for photos)
- Do not use placeholder images when real assets are provided

---

## Additional References

- **[Setup guide](references/setup.md):** MCP connection setup for interactive and headless environments
- **[MCP Tools Reference](references/mcp-tools.md):** Full parameter tables for all Anima MCP tools
- **[Examples](references/examples.md):** End-to-end walkthroughs for common scenarios
- **[Troubleshooting](references/troubleshooting.md):** Common issues and solutions
- [Anima MCP Documentation](https://docs.animaapp.com/docs/integrations/anima-mcp)
- [Anima Playground](https://playground.animaapp.com)
- [Enterprise Design System Setup](https://anima-forms.typeform.com/to/gDr77Woe)
