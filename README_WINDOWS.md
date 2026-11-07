# Windows installation - Saeid LinkedIn Skills

This repository contains 12 LinkedIn skills. The installer copies each skill folder into the standard user-level skills directories for Codex and Claude Code.

## Quick install
1. Download this repository using Code -> Download ZIP, then extract it.
2. Open the extracted linkedin-skills folder.
3. Double-click install_windows.bat.
4. Restart Codex and/or Claude Code.

No administrator rights, symlinks, or Windows Developer Mode are required.

## PowerShell options
Run PowerShell in the repository folder:

Install for both agents: .\install_windows.ps1

Also install Python requirements: .\install_windows.ps1 -InstallPythonDependencies

Replace existing copies: .\install_windows.ps1 -Force

Only Codex: .\install_windows.ps1 -SkipClaudeCode
Only Claude Code: .\install_windows.ps1 -SkipCodex

## Installation locations
- Codex: %USERPROFILE%\.agents\skills
- Claude Code: %USERPROFILE%\.claude\skills

Each skill is copied into its own folder and checked for SKILL.md.

## Safety and optional services
- The installer does not sign in to LinkedIn or publish content.
- It does not create, request, or store API keys.
- Apify, Publora, and Pixfaro remain optional and may require separate credentials.
- The installer never runs selftest with --live. Live tests can consume credits or create external drafts.
- Most skills can draft content without API credentials; some data-reading or publishing features require optional integrations.

## Optional Python setup
Python 3.10+ is recommended for helper scripts. Install dependencies with the PowerShell option above. Then run the non-live check:

python scripts/selftest.py --offline

Do not use --live unless you have reviewed the actions and explicitly want to test connected services.

## Troubleshooting
- Restart the relevant application if a skill does not appear.
- Confirm each installed folder contains SKILL.md.
- To update, download the latest ZIP and rerun with -Force.
- The BAT launcher uses a process-scoped PowerShell execution-policy bypass; it does not change your Windows policy.