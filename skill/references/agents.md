# agents — common core and per-agent adapters

metarche follows the Agent Skills specification (agentskills.io) and does not depend on one agent. The procedure, the documents and the hook scripts are shared; each agent gets a small adapter that wires them in.
Read this in the docs stage (docs.md §5), in upgrade, and whenever an instruction names an agent-specific feature.

## §1 Common to every agent
| Piece | Where | Note |
|---|---|---|
| Project instructions | `AGENTS.md` (first line `<!-- metarche -->`) | the single source. Codex and most agents read it directly |
| Claude Code bridge | `CLAUDE.md` containing only `@AGENTS.md` | Claude Code imports AGENTS.md through it; add nothing else unless it is Claude-only |
| Hook scripts | `.metarche/hooks/gate.ps1`, `check.ps1`, `finish.ps1`, `progress-head.ps1` | PowerShell 7 (`pwsh`), tested on Windows, macOS and Linux. They read both agents' hook input |
| Edit marker | `.metarche/.unchecked` | add to `.gitignore` |
| Rules that hooks cannot enforce | AGENTS.md "Rules" and "Work log" | e.g. do not read secret files; ask before committing |

The global instructions are `~/.claude/CLAUDE.md` for Claude Code and `~/.codex/AGENTS.md` for Codex. Read whichever exists.

## §2 Which agent is running
- Claude Code: the session has Claude Code tools and `CLAUDE_PROJECT_DIR`; skills are called as `/metarche`.
- Codex: skills are called as `$metarche` (or picked from `/skills`); file edits go through `apply_patch`.
- If unsure, ask. In discover (PRD §6 "agents"), record every agent that will work on the project and install each adapter.

## §3 Claude Code adapter
| File | From the template |
|---|---|
| `.claude/settings.json` | `templates/claude/settings.json` — permissions (ask before commit and push, deny reading secret files) and the four hooks |
- Hook events: SessionStart → progress-head, PreToolUse (`Edit|Write|NotebookEdit`) → gate, PostToolUse (same) → check, Stop → finish. Paths use `${CLAUDE_PROJECT_DIR}/.metarche/hooks/`.
- Extras: the AskUserQuestion tool for multiple choice, `/security-review` before committing security work, the official security-guidance plugin (security.md §8).
- Check: `/hooks` lists the four events, `/permissions` shows the ask and deny rules, reading a denied secret file is refused.

## §4 Codex adapter
| File | From the template |
|---|---|
| `.codex/hooks.json` | `templates/codex/hooks.json` — the same four hooks; edit matcher `^(apply_patch\|Edit\|Write)$` |
| `.codex/rules/metarche.rules` | `templates/codex/rules/metarche.rules` — prompt before `git commit` and `git push` |
- Project `.codex/` files load only when the project is trusted, and each hook must be reviewed and trusted in `/hooks` (again after it changes). Tell the user both steps.
- Hook commands run in the session folder, so start Codex at the project root (the scripts find the root themselves, but the command path `.metarche/hooks/...` is relative).
- Codex rules are experimental and govern commands outside the sandbox. Codex has no rule that denies reading a file the way Claude Code does; the AGENTS.md rule on secret files is the guard.
- No `/security-review` or security-guidance plugin; ask for a security review in the conversation instead.
- Check: `codex execpolicy check --rules .codex/rules/metarche.rules -- git push` prompts; `/hooks` lists the hooks as trusted; a planted check failure comes back after an edit.

## §5 Other agents
- Install nothing agent-specific. AGENTS.md carries the procedure; the hook scripts stay in `.metarche/hooks/` and can be run by hand.
- Tell the user what is lost without hooks: no PRD gate, no automatic checks, no PROGRESS injection. The agent must read the PROGRESS head first and run the per-file and end-of-turn checks itself before calling a task done.

## §6 Mapping of agent-specific features
| In these instructions | Claude Code | Codex | Other |
|---|---|---|---|
| multiple-choice question tool | AskUserQuestion | ask in text | ask in text |
| fresh context | `/clear` | `/new` or a new session | a new session |
| security review of changes | `/security-review` | ask in the conversation | ask in the conversation |
| list hooks / permissions | `/hooks`, `/permissions` | `/hooks`, `codex execpolicy check` | - |
| reviewer subagent | a subagent | a subagent | a new session given only the files |
