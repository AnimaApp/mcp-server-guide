# Common Issues and Solutions

## Issue: Timeout on playground-create
**Cause:** Default MCP client or mcporter timeout is too short (often 60s).
**Solution:** Always use `--timeout 600000` (10 minutes) for mcporter calls. For other MCP clients, check their timeout configuration. Playground generation builds a full application and typically takes 3-7 minutes.

## Issue: Node ID format error
**Cause:** Using `-` instead of `:` in node IDs when calling Figma-related tools.
**Solution:** Convert `42-15` from the Figma URL to `42:15` for the API call.

## Issue: Wrong styling options for type
**Cause:** Each type (p2c, l2c, f2c) supports different styling and UI library options.
**Solution:** Check the styling and UI library options tables in [mcp-tools.md](mcp-tools.md). For example, `css_modules` is only available for f2c, and `uiLibrary` is not supported for p2c.

## Issue: mcporter tries OAuth instead of using token
**Cause:** Header not configured correctly in mcporter config.
**Solution:** Use `--header "Authorization=Bearer $ANIMA_API_TOKEN"` (note: `=` not `:` between key and value) when adding the server config.

## Issue: Can't access playground
**Cause:** Private playground or expired session.
**Solution:** Verify authentication is set up correctly. Private playgrounds require team membership or direct sharing.

## Issue: Download URL expired
**Cause:** Pre-signed download URL from `project-download_from_playground` is only valid for 10 minutes.
**Solution:** Call `project-download_from_playground` again to get a fresh link.

## Issue: Generated code doesn't match project style
**Cause:** Tool parameters didn't match the project's actual technology stack.
**Solution:** Always detect the project stack first (Path B, Step B2). Pass accurate `framework`, `styling`, `language`, and `uiLibrary` parameters.

## Issue: Visual mismatch after implementation
**Cause:** Generated code was adapted without following the `guidelines` or comparing against snapshots.
**Solution:** For `codegen-figma_to_code`, always download and review snapshots. Follow the `guidelines` field carefully.
