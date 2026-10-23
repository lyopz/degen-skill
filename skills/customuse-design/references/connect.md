# Set up Customuse (once, on the PC)

1. **Update:** in PowerShell run
   `cd $HOME\.claude\degen-skill; git pull --no-edit`
2. **Find in Customuse settings (MCP / API page):** the MCP address (starts with `https://`) and your API key (starts with `cmk`). Never paste the key in chat.
3. **Save both on the PC:** in PowerShell run
   `powershell -NoProfile -File "$HOME\.claude\degen-skill\assets\roblox-app\customuse-setup.ps1" -Url "PASTE-ADDRESS-HERE" -Key "PASTE-CMK-KEY-HERE"`
   (Saved in `~/RobloxGames/.degen/customuse-mcp.json`, not in the repo. If Customuse's example uses a header like `x-api-key`, add `-Header "x-api-key"`.)
4. **Check:** open a Lead window from the app ("Hey Claude"), type `/mcp`, and **customuse** should say connected. (No key? pick it and **Authenticate** instead.)
5. **Test:** tell the app "make a dragon pet". It should: ChatGPT picture → Customuse low-poly 3D → Studio → ask you Love it / Like it / Change something / Don't like it.

No MCP address yet? It still works by hand: the Lead opens Customuse with the picture on your clipboard; you paste it into image-to-3D, pick low poly, and export .glb; the app picks it up from Downloads.
To remove: run step 3 with `-Url ""`.
