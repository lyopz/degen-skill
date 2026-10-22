# 21st.dev Magic MCP

[21st.dev Magic](https://21st.dev) gives Claude a UI component builder (`/ui ...`):
it searches 21st.dev's component library and writes React/Tailwind components into your project.

## The key never goes in git

The API key comes from <https://21st.dev/settings/security>. Create it there yourself.
Every config in this repo reads it from the `TWENTYFIRST_API_KEY` environment variable,
so nothing secret is committed. Do not paste the key into `.mcp.json`.
Local files with the key (`.env`, `.mcp.local.json`) are in `.gitignore`.

## Files

| File | What it is |
|:--|:--|
| `.mcp.json` (repo root) | Project MCP config for Claude Code. Loads `magic` whenever Claude Code opens this repo. It passes `${TWENTYFIRST_API_KEY}` to the server as `API_KEY`. |
| `mcp/claude_desktop_config.example.json` | The `magic` entry for the Claude desktop app, Windows form (`cmd /c npx`). The desktop app does not expand `${VAR}`, so the setup script writes the real key into your local config file, never into git. |

## Make it stay connected (every session, every folder)

A project `.mcp.json` only loads inside this repo. To have Magic everywhere, add it at **user level** too:

**Claude Code (any OS)**

```bash
claude mcp add magic --scope user --env API_KEY="$TWENTYFIRST_API_KEY" -- npx -y @21st-dev/magic@latest
```

On Windows, wrap npx: `-- cmd /c npx -y @21st-dev/magic@latest`.

**Claude desktop app (Windows)**: add the entry from `mcp/claude_desktop_config.example.json`
to `%APPDATA%\Claude\claude_desktop_config.json` under `mcpServers`, put your key in `API_KEY`,
then fully quit and reopen Claude.

## Check it

- Claude Code: `claude mcp list` should show `magic: ... ✓ Connected`.
- Desktop app: Settings → Developer should show `magic` as running.
- If it shows failed: run `npx -y @21st-dev/magic@latest` once by hand to see the error (usually a missing or wrong key).

## Rotating the key

Make a new key on the settings page, set `TWENTYFIRST_API_KEY` again, re-run the user-level add
(`claude mcp remove magic --scope user` first), update the desktop config, and restart Claude.
