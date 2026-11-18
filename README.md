<p align="center">
  <strong>Language:</strong>
  <a href="README.md">English</a> |
  <a href="README.ko.md">한국어</a> |
  <a href="README.zh-CN.md">简体中文</a> |
  <a href="README.ja.md">日本語</a> |
  <a href="README.es.md">Español</a> |
  <a href="README.ru.md">Русский</a>
</p>

# Metarche

<p align="center">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-blue?style=flat-square"></a>
  <a href="#install"><img alt="Claude Code skill" src="https://img.shields.io/badge/Claude_Code-skill-D97757?style=flat-square&logo=claude&logoColor=white"></a>
  <a href="#requirements"><img alt="Platform: Windows, macOS, Linux" src="https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-0078D4?style=flat-square"></a>
  <a href="#requirements"><img alt="PowerShell 7" src="https://img.shields.io/badge/PowerShell-7-5391FE?style=flat-square"></a>
  <a href="https://github.com/metapbl/Metarche/actions/workflows/hooks.yml"><img alt="Hook tests" src="https://img.shields.io/github/actions/workflow/status/metapbl/Metarche/hooks.yml?branch=main&style=flat-square&label=hook%20tests"></a>
</p>

meta + archē: a Claude Code skill that turns a Q&A interview into a PRD, docs and a plan, then builds behind gates.

> [!NOTE]
> The skill's instructions are in English. It talks to you and writes project documents (PRD, CLAUDE.md, plans) in your language.

## What it does
- Settles purpose, scope, features and approach through a Q&A interview, then asks you to approve a PRD.
- Sets a security level and policy (data classes, client and server trust boundaries, encryption) and approves it with the PRD.
- Creates the documents Claude Code needs (CLAUDE.md, PROGRESS, REFERENCE) plus permission rules and hooks: an edit-time check, an end-of-turn project check, a PRD gate and progress injection.
- Writes a task plan, then repeats implement → verify → record with an approval gate at each step.
- Keeps all state in files, so work continues after `/clear` and context compaction.

## Requirements
- Windows, macOS or Linux with PowerShell 7 (`pwsh`). The hooks are PowerShell scripts, tested on all three by [hook tests](tests/hooks.test.ps1).
- [Claude Code](https://code.claude.com/docs)
- git (recommended)

## Install
Windows (PowerShell 7):
~~~
git clone https://github.com/metapbl/Metarche.git "$env:USERPROFILE\My Projects\metarche"
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\skills" | Out-Null
New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\skills\metarche" -Target "$env:USERPROFILE\My Projects\metarche\skill"
~~~
macOS / Linux (install [PowerShell 7](https://learn.microsoft.com/powershell/scripting/install/installing-powershell) first):
~~~
git clone https://github.com/metapbl/Metarche.git ~/metarche
mkdir -p ~/.claude/skills && ln -s ~/metarche/skill ~/.claude/skills/metarche
~~~
You are done when `metarche` appears in `/skills` in Claude Code. To update, run `git pull` in the repository folder.

## Usage
| Command | When |
|---|---|
| `/metarche` | No argument: detects the project state and goes to the right stage |
| `/metarche new` | Start a new project in an empty folder |
| `/metarche adopt` | Bring an existing project into this workflow |
| `/metarche discover` | Continue the interview, or change an approved PRD or security policy |
| `/metarche docs` · `plan` · `build` | Documents · plan · implementation stages |
| `/metarche wrap` | End a session: update PROGRESS, commit leftovers, ask before pushing |
| `/metarche audit` | Report on docs, security and README |
| `/metarche upgrade` | Apply skill revisions to an existing project's hooks, settings and docs |
| `/metarche status` | Report only the current stage and open questions |

The skill is never invoked automatically (`disable-model-invocation: true`). It runs only when you call it.

## Language skills
Metarche itself is language-neutral. A language skill adds the values for one language. If a skill under `~/.claude/skills/` has `references/metarche.md`, Metarche reads it in the interview (step 4), docs and plan stages. Without one, Metarche works as is.

`references/metarche.md` should hold:
1. Extra interview questions for that language
2. Check commands: per file (takes the edited file path) and end of turn (project-wide)
3. Lines to put into CLAUDE.md
4. The first plan task (project skeleton) and how to verify it

Example: [Rustarche](https://github.com/metapbl/Rustarche) for Rust.

## Structure
~~~
skill/
├─ SKILL.md            entry point: rules, state detection, stage map
└─ references/
   ├─ discover.md      steps 0–5: interview, PRD approval and changes
   ├─ docs.md          step 6: documents
   ├─ plan.md          step 7: plan
   ├─ execute.md       steps 8–9: build and improve, wrap
   ├─ audit.md         audit
   ├─ adopt.md         adopting an existing project
   ├─ security.md      security policy (level, data classes, trust boundaries, encryption)
   ├─ upgrade.md       applying skill revisions to existing projects (revision ledger)
   ├─ readme.md        README standard for public repositories (language line, Shields.io badges)
   └─ templates/       PRD, SECURITY_POLICY, QA_LOG, OPEN, DECISIONS, CLAUDE, PROGRESS, REFERENCE, profile, settings.json, hooks/
~~~

## Credits
Projects and articles this skill draws on are listed in [`NOTICE`](NOTICE).

## License
MIT
