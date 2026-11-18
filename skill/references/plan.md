# Stage 7 — plan

Start after the document set is approved. Input: `docs/PRD.md`, root `CLAUDE.md`, and only the `R§` sections you need.
Output: one `docs/plans/YYYY-MM-DD-{slug}.md`. Keep only one plan in progress (`Status: active`) at a time. A plan before approval is `Status: draft`.
Write the plan in the user's language; keep the `Status:` line and IDs as they are (SKILL.md "Language").

## §1 Plan file form
~~~
# {feature group name}
Status: draft | Started: YYYY-MM-DD | Source: PRD F1, F2 (D###)

Goal: {what is true when it is done, one or two sentences}
Structure: {files that change or appear, and their roles}
Global constraints: {rules for every task, e.g. keep public API names}
Test seam: {the public interface the acceptance tests use; one, as high as possible}

## Tasks
- [ ] 1. {what} — `file > function`
  - Check: `{command}` → {expected output} | Device: {item} → {expected result}
- [ ] 2. {what} — `file > function` (after: 1)
- [ ] n. Acceptance — run the PRD success criterion and the acceptance criteria of every F# in this plan
  - Check: full test `{command}` passes | Device: {success scene} → {expected result}
  - Spec review: the subagent result from the last line of §2

## Self-review
- PRD features missing: none | {F#}
- Acceptance criteria not turned into tests: none | {F# criterion} → {why a device check replaces it}
- Order dependencies: {n after m}
~~~

## §2 Task size
- One task = one commit. Small enough to finish in one session and be judged by one check.
- Do not write a task that has no way to be checked. Split it, or settle the check first.
- If automated testing is possible, the task's first step is "write a failing test". Otherwise write a device-check item.
- Tests come in two layers: outside, acceptance tests taken from the PRD acceptance criteria (Given–When–Then); inside, function-level tests. A feature is done only when its outer tests pass.
- If there is no test tool yet, task 1 sets one up.
- Before the first task that changes existing code (adopt), add a characterization-test task: a test that pins the current behavior of the `file > function` to be changed. Pin it even if the current behavior is a bug, and change that test when you fix it.
- If PRD §5 says the repository is public, put a "README update" task right before acceptance (readme.md; its checks are in §6 there).
- If a PRD feature has security acceptance criteria, carry them into the acceptance tests (an unauthorized user and tampered input are rejected).
- Good tests check behavior through public functions and commands. Expected values are not computed from the code; use values independent of it, such as those in the PRD acceptance criteria. Use mocks only at system boundaries such as external APIs, time and randomness.
- Do not mix a structural change (rename, extract, move) and a behavior change in one task. If both are needed, put the structural task first; the tests must pass unchanged before and after it.
- Do not split tasks by layer (database, screen). Split them so each one carries one checkable behavior all the way through.
- A wide change that cannot pass in one step (a rename, say) becomes tasks: add the new form → move callers over in batches → delete the old form. Tests pass after every task.
- If a task relies on an earlier task's result, mark it `(after: m)`. This is how the next task is picked while a check is pending (execute.md §results 5).
- The last task is always "Acceptance" (§1 form). Once at the end of the plan, give a subagent with no conversation context this plan file, the PRD's F# sections and `git diff {plan start commit}..`, and have it list what is missing, what was added without being asked and what was implemented wrongly (as in discover.md §5). Show the findings to the user and deal with them.
- Leave no blanks such as `{later}` or `TBD`. If unknown, put a question in OPEN and hold that task.

## §3 Procedure
1. Group the PRD features and propose the group for this plan (with a recommendation). If there is a language skill (discover.md §2 "4 Approach"), put the first task its `references/metarche.md` defines (skeleton, settings) as task 1.
2. Write the plan file with `Status: draft` and fill in the self-review. On resume, if a `Status: draft` plan exists, do not write a new one; reopen the gate with that file.
3. Gate.
4. On approval, set the plan's `Status:` to `active` and update "plan" and "next step" in the head of `docs/PROGRESS.md`.
5. When every checkbox is done, set `Status: done (YYYY-MM-DD)` and propose the next plan.

## Gate
> [Gate] Do you approve the plan `{file}`? Until you do, I will not write code. If something needs fixing, tell me its number.
