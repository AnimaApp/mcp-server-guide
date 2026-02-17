# Setup: Anima MCP Connection

If any MCP call fails because Anima MCP is not connected, pause and set it up. There are two authentication approaches depending on your environment:

**Interactive environments** (user is present, browser available) use OAuth - the user authenticates via browser during setup. This is the standard flow for coding agents like Claude Code, Cursor, or Codex.

**Headless environments** (no browser, running autonomously) use an API token. This is the standard flow for OpenClaw, CI/CD pipelines, or any server-side agent.

## Interactive Setup (Claude Code, Cursor, Codex, etc.)

**Claude Code:**
```bash
claude mcp add --transport http anima https://public-api.animaapp.com/v1/mcp
```
Then enter `/mcp`, select Anima, and authenticate in the browser.

**OpenAI Codex:**
```bash
codex mcp add anima --url https://public-api.animaapp.com/v1/mcp
```
Then run `codex mcp login anima`.

**Cursor / other MCP clients:**
Add to your `mcp.json`:
```json
{
  "mcpServers": {
    "anima": {
      "url": "https://public-api.animaapp.com/v1/mcp"
    }
  }
}
```
Click "Connect" next to Anima in MCP settings. (Optional) Connect your Figma account during authentication to enable Figma URL flows.

## Headless Setup (OpenClaw and server-side agents)

Uses `mcporter` CLI with an API token. No browser required.

### Getting your API key

1. Go to [dev.animaapp.com](https://dev.animaapp.com)
2. Open **Settings** (gear icon)
3. Navigate to **API Keys**
4. Choose an expiration period and click **Generate API Key**
5. Copy the key and store it securely. You won't be able to see it again.

### Connecting with the API key

1. Set the Anima API key as an environment variable (e.g., `ANIMA_API_TOKEN`).
2. Add the Anima MCP server to mcporter config:
   ```bash
   npx mcporter config add anima-mcp \
     --url https://public-api.animaapp.com/v1/mcp \
     --transport http \
     --header "Authorization=Bearer $ANIMA_API_TOKEN"
   ```
3. Verify the connection:
   ```bash
   npx mcporter list anima-mcp --schema --output json
   ```

All subsequent MCP calls use mcporter:
```bash
npx mcporter call anima-mcp.<tool-name> --timeout 600000 --args '<JSON>' --output json
```

**Critical for OpenClaw:** Always pass `--timeout 600000` (10 minutes) on every mcporter call. The default 60-second timeout is too short for playground generation.
