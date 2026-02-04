# Anima MCP Server Guide

The Anima MCP server connects your AI coding assistant directly to Anima Playground, Figma designs, and your team's design system. It bridges the gap between PM prototypes and production code.

For the complete set of Anima MCP server docs, see our [help documentation](https://docs.animaapp.com/docs/integrations/anima-mcp).

## Features

- **Handoff Anima playgrounds to coding agents**

  Pull code from any Anima Playground into your local environment. The AI downloads the project, reads relevant files, understands patterns, and implements an adapted version in your codebase.

- **Figma to code**

  Convert Figma designs directly to code through your AI coding agent with high fidelity. Your agent uses Anima MCP to fetch the design and generate production-ready code.

- **Design system access (Enterprise)**

  Reference your team's design system directly when implementing features. The AI pulls your design system docs and builds using your team's established components and patterns.

## Installation & Setup

### Requirements

- **MCP-compatible AI coding tool:** Claude Code, Cursor, VS Code, or other tools that support the Model Context Protocol
- **Anima account:** You need access to Anima Playground to share and download projects

### Step 1: Set up your MCP client

Different MCP clients require slightly different setups. Follow the instructions below for your specific client.

#### Claude Code

1. Open your terminal (not inside Claude Code) and run:

```bash
claude mcp add --transport http anima https://public-api.animaapp.com/v1/mcp
```

2. Restart Claude Code
3. Enter `/mcp` to open the MCP menu
4. Select Anima and authenticate. This opens a browser window to sign in with your Anima account.
5. (Optional) Connect your Figma account during authentication to enable the Figma URL flow

Use these commands to manage servers:

- List all configured servers: `claude mcp list`
- Get details for a specific server: `claude mcp get anima`
- Remove a server: `claude mcp remove anima`

For more information, see [Anthropic's official documentation](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/tutorials#set-up-model-context-protocol-mcp).

#### VS Code

1. Use the shortcut `Cmd Shift P` (Mac) or `Ctrl Shift P` (Windows) to search for `MCP:Add Server`
2. Select `HTTP`
3. Paste the server URL: `https://public-api.animaapp.com/v1/mcp`
4. When prompted for a server ID, enter `anima`
5. Select whether to add this server globally or only for the current workspace

Your `mcp.json` will look like:

```json
{
  "servers": {
    "anima": {
      "type": "http",
      "url": "https://public-api.animaapp.com/v1/mcp"
    }
  }
}
```

> [!NOTE]
> You must have [GitHub Copilot](https://github.com/features/copilot) enabled on your account to use MCP in VS Code.
>
> For more information, see [VS Code's official documentation](https://code.visualstudio.com/docs/copilot/chat/mcp-servers).

#### Cursor

1. Open **Cursor > Settings > Cursor Settings**
2. Go to the **MCP** tab
3. Click **+ Add new global MCP server**
4. Enter the following configuration and save:

```json
{
  "mcpServers": {
    "anima": {
      "url": "https://public-api.animaapp.com/v1/mcp"
    }
  }
}
```

5. After saving, you'll see "anima" appear under Installed MCP Servers with "Needs authentication"
6. Click **Connect** to authenticate. This opens a browser window to sign in with your Anima account.
7. (Optional) Connect your Figma account during authentication to enable the Figma URL flow

For more information, see [Cursor's official documentation](https://docs.cursor.com/context/model-context-protocol).

#### Other editors

Other code editors and tools that support Streamable HTTP can also connect to the Anima MCP server.

If you're using a different editor or tool, check its documentation to confirm it supports Streamable HTTP based communication. If it does, you can manually add the Anima MCP server using this configuration:

```json
{
  "mcpServers": {
    "anima": {
      "url": "https://public-api.animaapp.com/v1/mcp"
    }
  }
}
```

### Step 2: Authenticate

After adding the MCP server, authenticate with your Anima account:

1. Your MCP client will prompt you to authenticate
2. A browser window opens to sign in with your Anima account
3. (Optional) Connect your Figma account during authentication to enable the Figma URL flow

## Prompting your MCP client

Once connected, you can prompt your MCP client to access Anima Playground projects and Figma designs.

### Handoff from Anima Playground

Copy the link to an Anima Playground and prompt your agent:

> "Implement the welcome screen from this playground: https://dev.animaapp.com/chat/xyz"

**What happens:**

1. AI downloads the playground project
2. AI reads relevant files and understands patterns
3. AI implements an adapted version in your codebase

> [!TIP]
> Be specific about which feature you want. The AI will find the relevant files and adapt the code to fit your project's patterns.

### Figma to code

Copy a Figma design link and prompt your agent:

> "Implement this Figma design using Anima MCP: https://figma.com/design/..."

Your AI agent will use Anima MCP to fetch the design and generate production-ready code in your codebase.

### Design system access (Enterprise)

Reference your team's design system directly when implementing features:

> "Implement a login form following our design system, use Anima MCP and figma url: ..."

The AI pulls your design system docs and builds using your team's established components and patterns.

**Getting started:** Design system setup is done with our team. [Contact us](https://anima-forms.typeform.com/to/gDr77Woe?utm_source=content&utm_medium=docs&utm_campaign=mcp-docs&utm_content=mcp-docs) to get it configured.

## Troubleshooting

### Can't access playground

Make sure you have access to the playground. Private playgrounds require team membership or direct sharing.

### MCP not recognized

Verify that Anima MCP is properly installed and configured in your AI coding tool. Check that your Anima authentication is set up correctly.

### Authentication issues

1. Try removing and re-adding the MCP server
2. Clear your browser cookies for animaapp.com
3. Restart your MCP client

## Best practices

### Be specific in your prompts

Instead of: "Implement this playground"
Try: "Implement the login form component from this playground, using my existing Button and Input components"

### Reference existing patterns

When implementing from Anima, tell the AI about your codebase patterns:

> "Implement this design using our existing components from src/components/ui and follow our Tailwind styling patterns"

### Break down large designs

For complex playgrounds or Figma files, request specific sections:

1. "First, implement just the header component"
2. "Now implement the card grid layout"
3. "Finally, add the footer"

This helps keep implementations focused and accurate.

## Additional resources

- [Anima MCP Documentation](https://docs.animaapp.com/docs/integrations/anima-mcp)
- [Anima Playground](https://playground.animaapp.com)
- [Contact us for Enterprise features](https://anima-forms.typeform.com/to/gDr77Woe)
