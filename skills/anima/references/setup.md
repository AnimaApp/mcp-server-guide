# Setup and authentication

Agent Grid is reachable two ways — the MCP server or the Anima CLI. Both hit the same governed endpoint, so pick whichever your environment already supports.

**MCP endpoint:** `https://api.agentgrid.io/v1/mcp`
**Transport:** streamable HTTP

## Claude Code (plugin — recommended)

```
/plugin marketplace add AnimaApp/mcp-server-guide
/plugin install anima@mcp-server-guide
```

This configures the MCP server and installs this skill in one step. Authenticate when prompted.

## Other MCP clients

Add the server manually:

```bash
claude mcp add --transport http anima https://api.agentgrid.io/v1/mcp
```

For Cursor, VS Code, and others, use your client's MCP configuration pointing at the same URL and transport. Or let the CLI print the config for you:

```bash
npx @animaapp/cli@latest mcp-config
```

Your client handles authorization itself on first use — no credentials to paste.

## Anima CLI

```bash
npx @animaapp/cli@latest login
```

Every command runs as a **scoped agent identity**: it acts only within the workspaces and capabilities a human approved, your team can see and revoke it, and the CLI renews it in the background.

- **Default:** OAuth device flow. The command prints a short code and a verification URL; a human approves on any device.
- **`--invite <url-or-code>`:** redeem a pre-approved invite (`https://api.agentgrid.io/invite/<code>.md`) — no approval step.

Installing globally (`npm i -g @animaapp/cli`) gives you `anima <command>` instead of the `npx` prefix.

## Headless environments

No browser means no device approval, so supply a token directly:

| Variable | Purpose |
|---|---|
| `ANIMA_API_TOKEN` | Agent Grid access token — the credential. Takes precedence over stored credentials |
| `ANIMA_TEAM_ID` | Act within a specific team. **Only read alongside `ANIMA_API_TOKEN`** — after `anima login`, the team comes from the stored credential and this is ignored |
| `FIGMA_TOKEN` | Figma personal access token, for `f2c` and codegen |

For MCP clients, the same token goes in an `Authorization: Bearer <token>` header against `https://api.agentgrid.io/v1/mcp`.

## Figma access

Figma flows (`artifact-create` type `f2c`, and `codegen-figma_to_code`) need a Figma personal access token. Over MCP it travels as the **`X-Figma-Token` header**, not as a tool argument. For the CLI, set `FIGMA_TOKEN` or pass `--figma-token`.
