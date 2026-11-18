<!-- metarche:draft -->
# {project name}

{One line: what, for whom. Details in docs/PRD.md}

## Structure
- `{folder}/` — {role}

## Commands
- Run: `{command}`
- Full test: `{command}` (run for every task)
- Per-file checks: run by `.claude/hooks/check.ps1` (`{tool}`)
- End-of-turn checks: run by `.claude/hooks/finish.ps1` (`{tool}`)
- Build and deploy: `{command}` (ask before running)

## Rules for this project
<!-- Only what has actually caused problems when broken. General principles live in ~/.claude/CLAUDE.md. -->
- {rule} (source: D### or R§n)

## Document map
- `docs/PRD.md` — what and why (approved; to change it, /metarche discover)
- `docs/SECURITY_POLICY.md` — data classes, trust boundaries, encryption (approved). Read the relevant section before work that touches authentication, permissions, encryption or sensitive data
- `docs/PROGRESS.md` — status and next step (the head is injected at session start)
- `docs/REFERENCE.md` — rationale, external specs, trap log. Search for the section you need
- `docs/plans/` — task plans (checkboxes)
- `docs/discovery/` — DECISIONS to confirm decisions; QA_LOG search only

## Work log
- When a task is done, update the plan's checkbox. At the end of a session, update the head of docs/PROGRESS.md and propose /metarche wrap.
- At wrap, commit leftover changes as `docs:` and ask whether to push.
- Before switching to unrelated work, propose /clear.
- New decisions go into `docs/discovery/DECISIONS.md`; causes of repeated mistakes go into the REFERENCE trap log.
- While the PRD is changing (`Status: changing`), do not edit outside docs/ (the hook blocks it).

## Keep on compaction
- When compacting, keep the active plan's path, the list of edited files and the check commands.
