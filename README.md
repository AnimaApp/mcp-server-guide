# Agent Grid MCP Server Guide

Agent Grid is a governed hub, by Anima, where AI agents build, host, publish, and share web apps. This repo includes two skills for selected own-code features. Install them as a Claude Code plugin or Codex skills.

Agent Grid lives at **[app.agentgrid.io](https://app.agentgrid.io/)**. For the full docs, see our [help documentation](https://docs.animaapp.com/docs/integrations/anima-mcp).

## What your agent can do

- **Build an app from a prompt, a website, or a Figma design** — describe it, clone a URL, or hand over Figma frames, and get back a running app at a live URL.
- **Host code you already have** — import a project or start an empty repo, and push to it.
- **Edit any artifact over git** — every artifact is a real git repository; clone, commit, push.
- **Publish to a live public URL** — and take it down again.
- **Generate design-aware code into your own codebase** — Figma frames to files in your repo, matched to your stack.

Everything is an **artifact**: one git repo in your team's workspace, addressed by its `sessionId`.

## Quick start: Claude Code plugin

```
/plugin marketplace add AnimaApp/mcp-server-guide
/plugin install anima@mcp-server-guide
```

This configures the MCP server and installs the skill. Authenticate when prompted. That's it.

## Installation & setup

### Requirements

- **An MCP-capable AI coding tool** — Claude Code, Codex, Cursor, VS Code, or anything speaking streamable HTTP
- **An Agent Grid account**

**Server URL:** `https://api.agentgrid.io/v1/mcp` · **Transport:** streamable HTTP

### Claude Code (manual)

1. In your terminal (not inside Claude Code):

```bash
claude mcp add --transport http anima https://api.agentgrid.io/v1/mcp
```

2. Restart Claude Code
3. Run `/mcp`, select **anima**, and authenticate in the browser
4. (Optional) Connect Figma during authentication to enable the Figma flows

Manage servers with `claude mcp list`, `claude mcp get anima`, `claude mcp remove anima`. See [Anthropic's MCP documentation](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/tutorials#set-up-model-context-protocol-mcp).

### OpenAI Codex

```bash
codex mcp add anima --url https://api.agentgrid.io/v1/mcp
```

Or in `~/.codex/config.toml`:

```toml
[mcp_servers.anima]
url = "https://api.agentgrid.io/v1/mcp"
```

Then install one skill that matches your agent:

```bash
# Full agent
codex skill install AnimaApp/mcp-server-guide/skills/agent-grid-full

# Sandboxed agent
codex skill install AnimaApp/mcp-server-guide/skills/agent-grid-sandboxed
```

Use `agent-grid-full` with a shell, network access, and Git. Use `agent-grid-sandboxed` without these capabilities.

See [OpenAI's Codex MCP documentation](https://developers.openai.com/codex/mcp).

### VS Code

1. `Cmd Shift P` / `Ctrl Shift P` → `MCP: Add Server`
2. Select **HTTP**
3. URL: `https://api.agentgrid.io/v1/mcp`
4. Server ID: `anima`
5. Choose global or workspace scope

```json
{
  "servers": {
    "anima": {
      "type": "http",
      "url": "https://api.agentgrid.io/v1/mcp"
    }
  }
}
```

> [!NOTE]
> MCP in VS Code requires [GitHub Copilot](https://github.com/features/copilot). See [VS Code's documentation](https://code.visualstudio.com/docs/copilot/chat/mcp-servers).

### Cursor

**Cursor > Settings > Cursor Settings > MCP > + Add new global MCP server**:

```json
{
  "mcpServers": {
    "anima": {
      "url": "https://api.agentgrid.io/v1/mcp"
    }
  }
}
```

Click **Connect** to authenticate. See [Cursor's documentation](https://docs.cursor.com/context/model-context-protocol).

### Any other client

```json
{
  "mcpServers": {
    "anima": {
      "url": "https://api.agentgrid.io/v1/mcp"
    }
  }
}
```

### No MCP? Use the CLI

The [Anima CLI](https://www.npmjs.com/package/@animaapp/cli) runs the same tools from a shell — no MCP server to configure:

```bash
npx @animaapp/cli@latest login
npx @animaapp/cli@latest create -t p2c -p "SaaS dashboard with sidebar and analytics"
```

## Prompting your agent

**Build something new**

> "Build me a SaaS analytics dashboard with a sidebar, KPI cards, and an activity feed."

Your agent creates an artifact, waits for the build, and hands back a live preview URL. Ask for variants and it can generate several in parallel to compare.

**Clone a site or implement a Figma design as a live app**

> "Clone stripe.com/payments into an app."
> "Turn this Figma frame into a working site: https://figma.com/design/..."

**Edit an existing artifact**

> "The header on https://app.agentgrid.io/artifacts/xyz is broken on mobile — fix it."

The full skill uses Git. The sandboxed skill uses `artifact-explore` and `artifact-edit` over MCP.

**Implement a Figma design in your own codebase**

> "Implement this Figma design in my project: https://figma.com/design/..."

The agent generates code matched to your stack and uses the returned design snapshots as visual reference.

**Publish**

> "Publish it."

Publishing makes an app public to the world — it isn't needed just to share, since the artifact URL is already viewable.

### Design system access (Enterprise)

> "Implement a login form following our design system, using this Figma URL: ..."

Design system setup is done with our team. [Contact us](https://anima-forms.typeform.com/to/gDr77Woe?utm_source=content&utm_medium=docs&utm_campaign=mcp-docs&utm_content=mcp-docs) to get it configured.

## Best practices

**Describe intent, not CSS.** Agent Grid is design-aware; hex values and pixel dimensions in a prompt override that and produce generic results. Say what it's for, who it's for, and the 3–5 features that matter.

**Be specific when implementing.** "Implement the login form using our existing Button and Input components from `src/components/ui`" beats "implement this design".

**Break down large designs.** Header first, then the card grid, then the footer. Focused requests are more accurate.

## Troubleshooting

See the troubleshooting references for [full agents](skills/agent-grid-full/references/troubleshooting.md) and [sandboxed agents](skills/agent-grid-sandboxed/references/troubleshooting.md).

**MCP not recognized:** confirm the server is configured in your tool and that authentication completed.
**Authentication issues:** remove and re-add the server, clear cookies, restart your client.

## What's in this repo

| Path | Purpose |
|---|---|
| `skills/agent-grid-full/` | Skill and references for agents with Git |
| `skills/agent-grid-sandboxed/` | Skill and references for sandboxed agents |
| `.claude-plugin/` | Claude Code plugin and marketplace manifests |
| `.mcp.json` | MCP server the plugin installs |
| `server.json` | MCP Registry entry |
| `agent-grid-full/SKILL.md` | Public mirror of the full skill |
| `agent-grid-sandboxed/SKILL.md` | Public mirror of the sandboxed skill |

## Additional resources

- [Agent Grid](https://app.agentgrid.io/)
- [Anima MCP documentation](https://docs.animaapp.com/docs/integrations/anima-mcp)
- [Anima CLI](https://www.npmjs.com/package/@animaapp/cli)
- [Contact us for Enterprise features](https://anima-forms.typeform.com/to/gDr77Woe)
