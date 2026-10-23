# Degen Skills desktop app

A window on your PC that shows every skill in this repo. Each time you open it, it runs `git pull` and rebuilds the list from the skill files, so new skills show up by themselves.

**Set up once (PowerShell):**
```
powershell -ExecutionPolicy Bypass -File $HOME\.claude\degen-skill\assets\app\install.ps1
```
Then open **Degen Skills** from your Desktop or Start menu.

- Opens in its own app window (Edge app mode; Chrome if Edge is missing). No install, nothing running in the background.
- `skills.js` is made on your PC each launch and isn't in git.
- `index.html` (the look of the app) is rebuilt by Claude when the design changes; you get it with the same `git pull`.
