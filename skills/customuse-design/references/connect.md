# Set up Customuse (once, on the PC)

1. **Update:** in PowerShell run
   `cd $HOME\.claude\degen-skill; git pull --no-edit`
2. **Find your Customuse MCP address:** customuse.com → sign in → settings (look for **MCP**, **Integrations** or **Connect to Claude**). Copy the address (starts with `https://`).
3. **Save it:** in PowerShell run
   `powershell -NoProfile -File "$HOME\.claude\degen-skill\assets\roblox-app\customuse-setup.ps1" -Url "PASTE-ADDRESS-HERE"`
4. **Sign in once:** open a Lead window from the app ("Hey Claude"), type `/mcp`, pick **customuse**, **Authenticate**, sign in to Customuse in the browser.
5. **Test:** tell the app "make a dragon pet". It should: ChatGPT picture → Customuse low-poly 3D → Studio → ask you Love it / Like it / Change something / Don't like it.

No MCP address yet? It still works by hand: the Lead opens Customuse with the picture on your clipboard; you paste it into image-to-3D, pick low poly, and export .glb; the app picks it up from Downloads.
To remove: run step 3 with `-Url ""`.
