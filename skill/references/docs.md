# Stage 6 — docs

Start only when the PRD is `approved`. Input: `docs/PRD.md`, `docs/SECURITY_POLICY.md`, `docs/discovery/DECISIONS.md`, and `docs/legacy/` for adopt.
Output: root `AGENTS.md` (+ `CLAUDE.md` bridge), `docs/PROGRESS.md`, `docs/REFERENCE.md`, `.metarche/hooks/*.ps1`, and the adapter files for each agent in PRD §6 (agents.md).
Templates are in `templates/`. Do not copy them verbatim; delete fields the PRD does not need, and write the documents in the user's language (SKILL.md "Language").

## §1 What goes where
| Information | Place | Why |
|---|---|---|
| Needed every session, rarely changes (commands, structure, project rules) | AGENTS.md | always loaded by the agent |
| Changes often (status, next step, open problems) | head of PROGRESS | injected by a hook |
| Needed now and then (rationale, external specs, traps) | REFERENCE | searched, not read whole |
| Decisions and rejected options | DECISIONS (kept growing) | one ledger |
| Task steps | docs/plans/ | checkboxes |
| Must always hold (dangerous commands, gates, secrets) | agent permissions and hooks (agents.md) | enforced by the agent where it can |
| Security policy (classes, boundaries, encryption) | docs/SECURITY_POLICY.md (approved copy) | read only the relevant section while working |
| The user's general preferences | the global instructions (agents.md §1) | not repeated in the project |
| Formatting | formatter and linter config | not written in documents |

## §2 AGENTS.md
- Create it with `<!-- metarche:draft -->` as the first line and change it to `<!-- metarche -->` after the gate (used by stage detection). At most 60 lines; move the overflow to REFERENCE.
- If Claude Code is one of the agents, also create `CLAUDE.md` from `templates/CLAUDE.md`: the single line `@AGENTS.md`. Claude-only notes may go below that line; nothing else is duplicated.
- Write commands so they can be copied and run as they are.
- Rules: only those whose violation causes real problems, each with its source (D###, R§n). No general principles.
- Point to code as `file > function`, not line numbers.
- No other `@file` imports (they load the whole file every time). Write the path and let it be read when needed.
- Include a "keep on compaction" section.

## §3 PROGRESS (token cost rules)
1. The head (above `<!-- head:end -->`) stays within 40 lines: status, next step, open problems, waiting for checks.
2. Update only the head. Never rewrite the whole file.
3. Unit of work = one commit. Tick the plan checkbox when a unit is done; update the head at the end of the session.
4. Done log: one line plus the commit hash. Past 50 lines, move it to `docs/history/YYYY-MM.md`.

## §4 REFERENCE
- Refer to sections as `R§n`. Search it; never read it whole.
- R§3 design rationale holds only an index of `D### — one-line summary`. The decisions themselves live only in DECISIONS.
- The trap log (`T<n>`) records only what happened twice or took long to diagnose.
- External specs carry a version and a source URL.
- Past about 500 lines, split by topic under `docs/reference/` and leave only a table of contents in REFERENCE.

## §5 Hooks and adapters
- Copy `templates/hooks/*.ps1` → `.metarche/hooks/`, then install the adapter for each agent in PRD §6 as in agents.md §3–§5. Add `.metarche/.unchecked` to `.gitignore`.
  - Do not overwrite existing files. For an existing settings or hooks file, add only metarche's entries; for a hook script with the same name, show the difference. Either way, show before and after and apply only after approval.
- The hooks need PowerShell 7 (`pwsh`). If it is missing, say so and offer to install it, or continue without hooks (agents.md §5).
- Move PRD §6 "dangerous commands" into the agents' ask rules. Defaults: ask before commit and push; deny reading `.env`, `.env.*`, `*.pem`, `*.key` (subfolders too; `.env.example` allowed) where the agent can deny reads, and the AGENTS.md rule everywhere.
- Carry the security policy over as in security.md §8, and record the result in policy §10.
- progress-head.ps1: injects the PROGRESS head at session start, resume, after clearing and after compaction.
- gate.ps1: while the PRD `Status:` is not `approved`, blocks file edits outside docs/, the agent folders (`.metarche/`, `.claude/`, `.codex/`, `.agents/`) and `AGENTS.md`/`CLAUDE.md`.
  - The hook is installed in this stage, after the PRD is approved, so it only actually blocks while the PRD is `changing`. Before approval (draft), rule 1 covers it.
  - It cannot block writes made by shell commands, so it works together with the AGENTS.md rules.
  - Files outside the project and under `.claude/worktrees/` are blocked too. This is intended; the user edits them by hand if needed.
- check.ps1: runs per-extension checks (linters, type checks) on every edited file and returns failures to the agent so it fixes them at once.
  - Fill the `$checks` table at the top from PRD §6 "per-file checks". Only commands that take the edited file's path last. Commands that take no path, such as `cargo check`, go to finish; the full test suite goes nowhere here.
  - Tools that cannot read project settings when given a single file get those settings in the command itself (e.g. `rustfmt --check --edition 2024`).
  - The check tools must be installed. Otherwise the hook reports "check tool not found" every time.
- finish.ps1: when a reply ends (Stop), runs the project-wide checks and returns failures so the agent keeps fixing.
  - Fill the `$finish` list at the top from PRD §6 "end-of-turn checks". Empty means it does nothing.
  - It runs only when `.metarche/.unchecked`, created by check.ps1 on an edit, exists (so not on turns that only answered a question). It removes the marker on success. Turns that changed files only through shell commands are not caught.
  - The same failure blocks at most twice (`$limit`). Past that the marker is removed so the next turn is not blocked. Every block also says: if the fix is unclear or would contradict the request, do not fix it; ask the user.
- Personal, uncommitted settings stay in the agent's local settings file (e.g. `.claude/settings.local.json`).

## §6 Procedure
If there is a language skill (discover.md §2 "4 Approach"), read its `references/metarche.md` and take the check commands and AGENTS.md rule values from it.

1. Read the PRD and DECISIONS and show the classification per the §1 table (per file: section titles, items, source marks) and the adapters to install.
2. After the classification is approved, create the files. Put an index of the settled decisions that shape the design into REFERENCE R§3.
3. Show each file's line count and the §7 results as evidence.
4. Gate.
5. On approval, change the first line of AGENTS.md to `<!-- metarche -->`.

On resume, if AGENTS.md starts with `<!-- metarche:draft -->`, do not recreate the files; continue from step 3.

## §7 Checks
- AGENTS.md within 60 lines, first line `<!-- metarche:draft -->` (after approval `<!-- metarche -->`); `CLAUDE.md` is `@AGENTS.md` if Claude Code is used
- PROGRESS head within 40 lines
- The adapter checks in agents.md for each installed agent (hooks listed, ask and deny rules shown)
- check hook: `Get-Command {tool}` succeeds for every tool in `$checks`; write a file that fails a check, see the error come back, then delete the file
- finish hook: plant a compile or type error and end a reply; the error comes back. A turn that only answers a question runs no check. Revert the error afterwards
- With the security-guidance plugin (Claude Code): `(Get-Item .claude/claude-security-guidance.md).Length` is 8192 or less

## Gate
> [Gate] Do you approve the document set (AGENTS.md, PROGRESS, REFERENCE, hooks and agent adapters)? Until you do, I will not create the plan or code. If something needs fixing, tell me its number.
