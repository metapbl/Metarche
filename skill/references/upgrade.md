# upgrade — apply skill revisions to an existing project

Changes to the skill's guides (references/) apply to every project at once. This mode only updates the files copied into a project (instruction files, hooks, agent adapters, PROGRESS, the policy document).
There is no version number. For each ledger item, whether it is already applied is judged from the project's own files.
When a skill change requires project files to change, add an item to the §2 ledger in the same commit.

## §1 Scope
- Only projects whose root `AGENTS.md` starts with `<!-- metarche -->`, or, before U8, whose root `CLAUDE.md` does (the docs stage is done).
- Before that stage there is nothing to upgrade yet. Say so and continue with metarche.
- Do not proceed while the PRD is `changing`. Finish the change first.
- Apply U8 before the other items: it moves the files they look at. Until U8 is applied, read `.metarche/hooks/` below as `.claude/hooks/` and `AGENTS.md` as `CLAUDE.md`.

## §2 Revision ledger
`$t` is this skill's `references/templates` path. Judging only reads; applying happens after the §3 gate.
Judge text items by meaning, in any document language (e.g. U4 also matches a Korean line).

| # | Date · source | What | Judged applied when | Apply |
|---|---|---|---|---|
| U1 | 2026-10-29 · 60df637 and later | hook bodies match the templates | the scripts in `.metarche/hooks/` equal `$t/hooks/` (ignoring line endings), apart from the `$checks = @{ … }` block in check.ps1 and the `$finish = @( … )` block in finish.ps1 | replace with the templates, putting the project's `$checks` and `$finish` blocks back in. Leave hook files that are not in the templates alone |
| U2 | 2026-10-29 · c7cd968 | secret deny rules that also cover subfolders (Claude Code) | `.claude/settings.json` `permissions.deny` has all of `Read(.env)`, `Read(.env.*)`, `Read(!.env.example)`, `Read(*.pem)`, `Read(*.key)` | remove `Read(./.env)` and `Read(./.env.*)` and add the missing rules in this order (the `!` rule after `Read(.env.*)`). Ask whether user-added `Read(./{file name})` rules should become `Read({file name})`. Skip if Claude Code is not used |
| U3 | 2026-10-29 · 60df637 | PROGRESS does not record the last commit (the hook reads it from git) | the head of `docs/PROGRESS.md` has no last-commit line (`Last commit` or the older `마지막 커밋`) | remove just that part. If it carries other information (pushed or not, tags), show it and ask whether to keep it before removing |
| U4 | 2026-10-29 · c7cd968, 60df637 | the instruction file has the security policy line and the wrap commit rule | `AGENTS.md` has a line pointing to `docs/SECURITY_POLICY.md` and a line saying wrap commits leftover changes and asks before pushing | add the two lines from `$t/AGENTS.md` to the same sections (document map, work log), in the project's document language. Report if the file then exceeds 60 lines |
| U5 | 2026-10-29 · c7cd968 | security policy | `docs/SECURITY_POLICY.md` exists and its `Status:` is `approved` | needs an interview, so this mode does not write it. Follow §3 step 6 |
| U6 | 2026-11-18 · end-of-turn hook | end-of-turn check (finish hook) | `.metarche/hooks/finish.ps1` exists, every installed adapter has a Stop entry for it, and `.gitignore` has `.metarche/.unchecked` | copy finish.ps1, add the Stop entry to each adapter, the `.gitignore` line and the "end-of-turn checks" line in the AGENTS.md commands section. Ask the user for the `$finish` commands, write the same line in PRD §6 and add a line to the §8 change history. Leave hook files that are not in the templates (the user's own) alone |
| U7 | 2026-11-19 · English skill | status markers in the fixed form `Status:` | no line in `docs/PRD.md`, `docs/SECURITY_POLICY.md` or `docs/plans/*.md` starts with `상태:` | in those lines, replace only the word `상태:` with `Status:` and keep the value (`approved (YYYY-MM-DD)`, `active`, etc.) and the rest of the line. The gate hook accepts both forms, so nothing breaks before this is applied |
| U8 | 2026-11-20 · agent-neutral layout | AGENTS.md as the instruction file and hooks in `.metarche/` | `AGENTS.md` starts with the metarche marker, `CLAUDE.md` (if Claude Code is used) is `@AGENTS.md` plus at most Claude-only notes, the four metarche hooks are in `.metarche/hooks/`, and no adapter points to `.claude/hooks/` for them | move the content of `CLAUDE.md` to `AGENTS.md` with `git mv`, then create `CLAUDE.md` with the single line `@AGENTS.md`. Move `gate.ps1`, `check.ps1`, `finish.ps1`, `progress-head.ps1` from `.claude/hooks/` to `.metarche/hooks/` and change their paths in `.claude/settings.json`. In `.gitignore` replace `.claude/.unchecked` with `.metarche/.unchecked` and delete a leftover `.claude/.unchecked`. Leave the user's own hooks and their settings entries where they are. Then apply U1 so the hooks read both agents' input |
| U9 | 2026-11-20 · Codex adapter | Codex adapter, only if Codex works on the project (PRD §6) | `.codex/hooks.json` has the four metarche hooks and `.codex/rules/metarche.rules` exists | copy both from `$t/codex/`, keeping existing entries in `.codex/hooks.json`. Add Codex to PRD §6 "agents" and a line to the §8 change history. Tell the user to trust the project and the hooks in Codex (`/hooks`), as in agents.md §4. Skip and mark "not used" if Codex is not used |

## §3 Procedure
1. Confirm the §1 scope, run every §2 judgment and show a table of applied, not applied and not used. If nothing is missing, say so and stop.
2. For each missing item (except U5), show the files that change and the before and after.
3. Show uncommitted changes with `git status --short`. If a file to upgrade already has changes, ask whether to skip it.
4. Gate.
5. Apply only the approved items (U8 first) and rerun the judgments as evidence. Commit only the changed files as `chore: metarche upgrade (U#, …)` (or the project's commit format), and ask whether to push.
6. If U5 is missing, ask whether to write the security policy now through discover.md §7 (PRD change). If yes and the file is missing, copy `$t/SECURITY_POLICY.md` to `docs/` first. Mention that the gate hook blocks edits outside docs/ meanwhile. If postponed, add to "open problems" in the PROGRESS head: `security policy not written — run metarche discover and ask to add the security policy` (in the project's document language).

## Gate
> [Gate] Do you approve applying upgrade {U#, …}? Until you do, I will not change project files. If something needs fixing, tell me its number.
