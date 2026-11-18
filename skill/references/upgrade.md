# upgrade — apply skill revisions to an existing project

Changes to the skill's guides (references/) apply to every project at once. This mode only updates the files copied into a project (hooks, settings.json, CLAUDE.md, PROGRESS, the policy document).
There is no version number. For each ledger item, whether it is already applied is judged from the project's own files.
When a skill change requires project files to change, add an item to the §2 ledger in the same commit.

## §1 Scope
- Only projects whose root `CLAUDE.md` starts with `<!-- metarche -->` (the docs stage is done).
- Before that stage there is nothing to upgrade yet. Say so and continue with `/metarche`.
- Do not proceed while the PRD is `changing`. Finish the change first.

## §2 Revision ledger
`$t` is this skill's `references/templates` path. Judging only reads; applying happens after the §3 gate.
Judge text items by meaning, in any document language (e.g. U4 also matches a Korean line).

| # | Date · source | What | Judged applied when | Apply |
|---|---|---|---|---|
| U1 | 2026-10-29 · 60df637 and later | hook bodies match the templates | `progress-head.ps1` and `gate.ps1` equal the templates (ignoring line endings), and `check.ps1` and `finish.ps1` equal them apart from the `$checks = @{ … }` / `$finish = @( … )` blocks | replace with the templates, putting the project's `$checks` and `$finish` blocks back in. Leave hook files that are not in the templates alone |
| U2 | 2026-10-29 · c7cd968 | secret deny rules that also cover subfolders | `permissions.deny` has all of `Read(.env)`, `Read(.env.*)`, `Read(!.env.example)`, `Read(*.pem)`, `Read(*.key)` | remove `Read(./.env)` and `Read(./.env.*)` and add the missing rules in this order (the `!` rule after `Read(.env.*)`). Ask whether user-added `Read(./{file name})` rules should become `Read({file name})` |
| U3 | 2026-10-29 · 60df637 | PROGRESS does not record the last commit (the hook reads it from git) | the head of `docs/PROGRESS.md` has no last-commit line (`Last commit` or the older `마지막 커밋`) | remove just that part. If it carries other information (pushed or not, tags), show it and ask whether to keep it before removing |
| U4 | 2026-10-29 · c7cd968, 60df637 | CLAUDE.md has the security policy line and the wrap commit rule | there is a line pointing to `docs/SECURITY_POLICY.md` and a line saying wrap commits leftover changes and asks before pushing | add the two lines from the template CLAUDE.md to the same sections (document map, work log), in the project's document language. Report if CLAUDE.md then exceeds 60 lines |
| U5 | 2026-10-29 · c7cd968 | security policy | `docs/SECURITY_POLICY.md` exists and its `Status:` is `approved` | needs an interview, so this mode does not write it. Follow §3 step 6 |
| U6 | 2026-11-18 · end-of-turn hook | end-of-turn check (finish hook) | `.claude/hooks/finish.ps1` exists, settings.json `hooks.Stop` has a finish.ps1 entry, and `.gitignore` has `.claude/.unchecked` | copy finish.ps1 and add the Stop entry, the `.gitignore` line and the "end-of-turn checks" line in the CLAUDE.md commands section. Ask the user for the `$finish` commands, write the same line in PRD §6 and add a line to the §8 change history. The `.unchecked` lines in check.ps1 arrive with U1. Leave hook files that are not in the templates (the user's own) alone |
| U7 | 2026-11-19 · English skill | status markers in the fixed form `Status:` | no line in `docs/PRD.md`, `docs/SECURITY_POLICY.md` or `docs/plans/*.md` starts with `상태:` | in those lines, replace only the word `상태:` with `Status:` and keep the value (`approved (YYYY-MM-DD)`, `active`, etc.) and the rest of the line. The gate hook accepts both forms, so nothing breaks before this is applied |

## §3 Procedure
1. Confirm the §1 scope, run every §2 judgment and show a table of applied and not applied. If nothing is missing, say so and stop.
2. For each missing item (except U5), show the files that change and the before and after.
3. Show uncommitted changes with `git status --short`. If a file to upgrade already has changes, ask whether to skip it.
4. Gate.
5. Apply only the approved items and rerun the judgments as evidence. Commit only the changed files as `chore: metarche upgrade (U#, …)` (or the project's commit format), and ask whether to push.
6. If U5 is missing, ask whether to write the security policy now through discover.md §7 (PRD change). If yes and the file is missing, copy `$t/SECURITY_POLICY.md` to `docs/` first. Mention that the gate hook blocks edits outside docs/ meanwhile. If postponed, add to "open problems" in the PROGRESS head: `security policy not written — run /metarche discover and ask to add the security policy` (in the project's document language).

## Gate
> [Gate] Do you approve applying upgrade {U#, …}? Until you do, I will not change project files. If something needs fixing, tell me its number.
