# Connect Customuse to Claude

Customuse has an MCP server ("Customuse MCP is live", Oct 2026). Its address is shown in your Customuse account (look for **MCP**, **Integrations** or **Connect to Claude** in settings).

1. Copy the MCP address from Customuse.
2. Send it to Claude in the project chat; it gets added to `assets/roblox-app/roblox-mcp.json` as `customuse` so the Lead window loads it.
3. First time the Lead uses it, type `/mcp` → **customuse** → **Authenticate** and sign in to Customuse.

Until it's connected, designs fall back to the ChatGPT route and still get rated and logged.
