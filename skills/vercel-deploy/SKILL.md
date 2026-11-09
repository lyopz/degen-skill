---
name: vercel-deploy
description: Set up Vercel for Claude Code (CLI, Vercel plugin or skills, Vercel MCP) and put lyopz's sites live on Vercel the way he likes - private GitHub repo, Vercel limited to that one repo, project name that doesn't show who made it. Use when lyopz says "put it on Vercel", "deploy this", "make it live", "set up Vercel", "onboard to Vercel", or asks for a free .vercel.app link.
---

<!-- from: vercel.com/get-started.md (Vercel's "Onboard your agent" prompt) -->

# Vercel: setup and deploy

Two jobs. **Setup** happens once per PC. **Deploy** happens per site.
lyopz's PC is Windows; run commands in normal PowerShell.

## How lyopz wants sites deployed

- **Repo:** his own GitHub (`lyopz`), set to **Private**, no README/license from GitHub, no open-source license in the code.
- **Nobody can tell who made it:** commit under the project's own name with a noreply email (e.g. `Cyber Attack <cyberattack@users.noreply.github.com>`), never his name or email. No repo link on the site. Vercel project name without `lyopz` (the name becomes the URL, e.g. `cyberattack-map.vercel.app`).
- **Vercel's GitHub app:** install with **Only select repositories** and pick just that site's repo. Add more repos later the same way, one at a time.
- **Plan:** Hobby (free). Private repos from a personal account deploy fine on Hobby.
- After the first deploy, **every push to `main` goes live by itself.** Don't redeploy by hand.
- **Check the live site yourself** after deploying (open it, call its API routes, read the console) and tell him what you saw, not just "deployed".

## Deploy a site (per project)

1. Make sure the project deploys with no build step when it can: static files in `public/`, serverless functions in `api/`, and a `vercel.json` with `"outputDirectory": "public"`. Plain HTML/JS sites need no framework preset ("Other").
2. Create the private repo (github.com/new → Private, nothing pre-filled) and push.
3. vercel.com/new → **Import Git Repository** → GitHub. If Vercel's GitHub app isn't installed yet, its install opens as a popup that the browser pane blocks: go straight to `https://github.com/apps/vercel/installations/new`, choose **Only select repositories**, pick the repo, **Install**.
4. Import the repo, set the **Project Name**, leave the rest, **Deploy**.
5. Vercel may ask lyopz to **verify his identity** with an emailed 6-digit code. That's his to do: tell him to press **Ctrl+Shift+B** in the Claude desktop app to show the browser, tap **Send Code** and type the code. Never type codes or passwords for him.
6. Open `https://<project>.vercel.app`, check it works, report.

### Deploy without an account
`vercel deploy --temporary` from the project folder gives a live production URL with no sign-up, plus a claim URL and expiry. Give lyopz the claim URL and tell him not to share it. Doesn't work in CI or in a folder already linked to a project. For a static folder he can also drag it onto https://vercel.com/drop.

## Set up Vercel for Claude Code (once per PC)

Do the steps yourself when you have terminal access. Pause only for sign-in, approval, or clicks you can't do. If a step is blocked, note why and keep going.

### 1. Vercel CLI
```powershell
vercel --version
npm install --global vercel@latest   # if missing or it says an update is available
vercel whoami                          # if not signed in: vercel login (lyopz signs in)
```
Don't create or link a project during setup. Link one only when a deploy or project task needs it.

### 2. Vercel guidance (plugin first, skills as fallback; never both)
```powershell
node --version                         # needs 18+
npx plugins add vercel/vercel-plugin
```
Check `/vercel-plugin:status` shows up. Only if plugins aren't supported or Node can't be installed:
```powershell
npx skills add vercel-labs/agent-skills --global
```

### 3. Vercel MCP (shared, all projects)
```powershell
vercel mcp --clients "Claude Code"
```
Fallback: `claude mcp add --transport http vercel --scope user https://mcp.vercel.com`. Look at existing MCP entries first and merge; never replace unrelated ones. The endpoint must be exactly `https://mcp.vercel.com`. To sign in: `/mcp` → `vercel` → authenticate (lyopz completes the browser consent).

Check it works: call `search_vercel_documentation`, then the read-only `list_teams`. Keep confirmation on for every MCP action that changes something: the MCP has lyopz's full Vercel access.

### Report when done (only what you verified)
```text
▲ Vercel agent setup is ready
CLI: <version>, signed in as <username>
Guidance: <plugin|skills|blocked: reason>
MCP: <connected|blocked: reason>, https://mcp.vercel.com
Authenticated MCP check: <list_teams worked|not requested>
```

## More from Vercel
- Reference architectures: https://vercel.com/kb/architecture
- Prompt library: https://vercel.com/kb/prompts
- Docs: https://vercel.com/docs/cli · https://vercel.com/docs/agent-resources/vercel-mcp

<!-- end: vercel.com/get-started.md -->
