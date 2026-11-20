# Stages 8–9 — build · improve · wrap

Input: the active plan and the PROGRESS head (injected by a hook). Do nothing that is not in the plan.

## §build — one task
1. Pick the first unfinished task in the plan and read only its `file > function`.
2. State in two or three lines what will change and how it will be checked. If it differs from the plan, stop here and ask.
   - If the task touches authentication, permissions, encryption, secrets or data of class sensitive or above, read the relevant section of `docs/SECURITY_POLICY.md` and say that you will follow it.
3. (When possible) failing test → implementation → test passes.
   - Never make tests pass by disabling or deleting them or by changing expected values. If a test change outside the plan seems needed, stop, show why and ask.
4. Run the check command, and also the full test command if AGENTS.md has one; show the output as evidence. If a test from an earlier task broke, fix it before moving on.
   - Also show how long the full test run took. If it exceeds the PRD §6 baseline, do not stop; add to "open problems" in PROGRESS: `full test N s, over baseline — decide whether to run only related tests per task and the full suite at acceptance`, and say so. If that is decided, change PRD §6 through discover.md §7.
5. Tick the checkbox and propose a commit message. Commit only after approval.
   - If step 2 was security work, run a security review of the changes before proposing the commit (agents.md §6) and show the findings and how they were handled.

## §stop — when to stop
- If the same check fails twice, stop fixing and switch to the §debug procedure.
- If a check needs a real device, an external service, the screen or sound, give the items and expected results, add them to "waiting for checks" in PROGRESS, and wait. When the results come, follow §results.
- A finding that requires changing the PRD goes back to metarche `discover`. If only the plan changes, show the revised plan and get approval.
- New questions go into `docs/discovery/OPEN.md`.
- Results settled during the build with a separate interview tool are written to DECISIONS. If they touch the PRD, go through discover.md §7; if they touch the plan, revise the plan.
- If you find a security problem (an exposed secret, a permission bypass), stop the current work and follow security.md §7.

## §results — after a person reports a check
When asking for a check, give the expected results as numbered items and ask for "yes/no and what you saw" for each (form in PRD §6).

1. Verdict: it passes only if every item is "yes". Vague answers such as "mostly works" or "almost" do not pass; ask again about just those items.
2. Record: under the task's check line in the plan, add `- Result: YYYY-MM-DD pass|fail — {the user's answer, summarized if long}`. Do not leave it only in the conversation.
3. Pass: remove it from "waiting for checks" in PROGRESS, tick the checkbox, propose a commit message.
4. Fail: leave the checkbox empty. Move it from "waiting for checks" to "open problems" in PROGRESS (clue: what the user saw). If you lack what was done, what appeared or where the logs are, ask for that first, then start at §debug step 1 (reproduce). After the fix, ask again with the same check items.
5. While waiting: work only on tasks that do not depend on the pending one. Tasks that do depend on it wait for the result.
6. If acceptance (the plan's last task) fails, clear the checkbox of the task that caused it and go back to it. If a task outside the plan is needed, show the revised plan and get approval.

## §debug — no fixes by guessing
1. Reproduce: write down the command or actions that bring back the user's exact symptom. Do not reproduce a different, similar failure instead. If it does not reproduce, do not fix; find a way to reproduce it first.
2. Reduce: shrink to the smallest input and scope that still fails. If you do not know when it broke, use `git bisect`.
3. Hypothesize: show 1–3 hypotheses with a way to test each, and pick one by the results. If the user must judge, ask here.
4. Fix: write a regression test that catches the failure first, and watch it fail before fixing. Then fix.
5. Clean up: tag temporary debug output (`print` and the like) with a unique marker (e.g. `[DBG-a4f2]`). Before committing, search for the marker and show zero hits as evidence. Diagnostics that stay go through the logger only (PRD §5 logs).
6. Record: if the cause took long to find, propose an entry in the trap log (T#).

When copying logs, requests or responses into the conversation or a document, replace secrets (tokens, passwords, keys) with `<REDACTED>`.

## §wrap — end of session
1. Update only the PROGRESS head: status (plan and task number; do not write the last commit, the hook reads it from git), next step (down to file > function), open problems, waiting for checks.
2. Add this session's finished tasks to the "done log", one line each (date, what, commit hash). Past 50 lines, move it to `docs/history/YYYY-MM.md`.
3. Commit the remaining changes (`git status --short`) as `docs:` (or the project's commit format), and ask whether to push. If changes that must not be committed (code in progress, etc.) are mixed in, do not commit; list them and ask.
4. If something took long to diagnose this session, propose a trap log (T#) entry.
5. If actual behavior or an interface drifted from PRD §3 this session, show the difference and propose a PRD change (discover.md §7). If the documents lag behind the code, the next session trusts wrong documents.
6. Show the head's line count as evidence:
   `(Get-Content docs/PROGRESS.md | Select-String -Pattern 'head:end').LineNumber`
7. Say that the next session can start in a fresh context.

## §improve — where to stop the same mistake
Prevent what can be enforced with checks rather than documents. Consider the rows of this table from the top.

| Kind of mistake | Where it goes |
|---|---|
| A machine can judge it (banned imports or calls, types, formatting) | linter or type-check config and rules (ruff, semgrep, import-linter, etc.), run by the check hook on edit |
| A recurring behavior bug | a regression test that catches it |
| A recurring judgment mistake in this project (no machine can judge it) | AGENTS.md "rules for this project" (source T#) |
| The cause is an external spec or the environment | REFERENCE trap log |
| Behavior that must never happen | agent permissions or a hook (agents.md) |
| Recurs across projects | the global instructions |
| A recurring multi-step task | a project skill (`.agents/skills/`, or `.claude/skills/` for Claude Code) |

Propose as "what, where, why (T#, commit)" and apply after approval. If AGENTS.md would exceed 60 lines, move it to REFERENCE instead.
