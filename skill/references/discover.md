# discover — stages 0–5 (explore → settle the PRD) · PRD changes

## §0 Explore (before asking)

Before starting, copy `PRD.md` and `SECURITY_POLICY.md` from `templates/` to `docs/`, and `QA_LOG.md` and `DECISIONS.md` to `docs/discovery/`. Do not overwrite files that already exist. (Both new and adopt.)
Do not copy `OPEN.md` here; create it in step 4. Once OPEN exists, stage detection goes to discover, so creating it before adopt finishes would skip the adoption on resume.

1. Read the global instructions (agents.md §1) and mark the items it already answers.
2. Survey the project folder: README, existing docs, dependency files, entry points, folder structure, `git log --oneline -20`.
3. Write what you learned to `docs/discovery/QA_LOG.md` as `[X]` entries. An entry that is only an answer, with no question, still gets a Q number.
4. Create the first `docs/discovery/OPEN.md` from `templates/OPEN.md`. From the §2 question bank pick only the questions that apply, drop those exploration already answered, and order them by priority.
5. Send a summary of the exploration (10 lines at most) and the first question.

- For a new project, skip steps 2 and 3.
- For adopt, follow `adopt.md` instead of steps 1–3. When adopt is done, continue from step 4.

## §1 How to ask

- Big questions (purpose, users, success criterion, non-goals) one at a time. Shape the next question from the answer.
- Group detailed questions 3–6 at a time, numbered. Each item reads `n. question — recommended: X (reason)`.
- Do not put a question in a group if it depends on another question in that group that has not been answered yet. Move it to the next group.
- When the options are clear, make it multiple choice. Use the agent's multiple-choice question tool when it has one (agents.md §6).
- If an answer is ambiguous, offer one interpretation and ask whether it is right. Never interpret silently.
- If the user says "I don't know", fill in the recommendation as `[AI]` and leave a `re-check` mark in OPEN.
- If the user answers with a question, answer it first, then return to the original question.
- Keep each batch of questions within one screen.
- Do not show internal symbols (`[U]`, `D###`, `Q###`) to the user without explaining them.

## §2 Question bank

Pick only what is needed. Do not ask what the profile or the exploration already answered.

### 1 Purpose
- What problem are we solving? How is it handled today?
- Who uses it (just you, people you know, the public)? How many, on what devices?
- What makes it done? Describe one observable scene. (e.g. watching a whole movie without a stall)
- By when is it needed? Is it thrown away after use, or maintained?

### 2 Scope
- Must have / nice to have / not this time.
- Anti-goals: behavior that must never happen.
- Structure to prepare now for later, without implementing it.
- Legal, license, privacy and cost (paid APIs, billing) constraints.

### 3 Features (per feature)
- Normal flow: what does the user do, and what do they see?
- Exceptions: what should happen on failure, interruption, lost connection, invalid input?
- Behavior by state: what does the same action do while paused, while working, while shutting down?
- Edge values: very large input, zero items, simultaneous actions.
- Interface: which functions, commands or file formats do other features or outside parties rely on? What breaks if they change?
- Screen: what appears where, shortcuts, how notifications work.
- Acceptance criteria: turn the answers above into 2–5 examples of `Given {state} / When {action} / Then {visible result}` and confirm them. These sentences become the tests as they are.
- Security: if permissions are involved or the feature handles data of class sensitive or above (security.md §4), settle who may do it and at least one security acceptance criterion (an unauthorized user, tampered input).

### 4 Approach
- Runtime environment (OS, language version, network) and distribution form (exe, web, script).
- Language skill: if a language skill for the main language is installed (a skill installed next to this one, with a `references/metarche.md`), read that file and follow it. Otherwise use this question bank.
- Ask about key technology choices with the §4 comparison form.
- External dependencies (libraries, APIs, hardware) and alternatives.
- Where and in what format data is stored; config files.
- Log location, format and verbose mode.
- Security: ask the security.md §1 questions and recommend a security level (§2) from the answers. Record the result in `docs/SECURITY_POLICY.md`.

### 5 Verification and operations
- What is tested automatically, and what does a person check by hand? In what form are the person's results reported?
- The full test command and how long it takes. If there is no test tool, what to use. Also set a baseline time — recommended: 60 seconds (if exceeded, decide again whether to run only the related tests per task).
- Which check (linter, formatter) runs on each file when it is edited? Only commands that take the edited file's path. This becomes the check hook (docs.md §5).
- Which project-wide check runs when work ends (commands that take no file path, such as compiling or type checking)? This becomes the finish hook (docs.md §5).
- Which commands are dangerous (deploy, remote database, mass deletion)? These become ask-first rules in the agent adapters.
- Version control: commit unit, message format, branches.
- Which coding agents will work on this project (Claude Code, Codex, others)? — recommended: the one running now. Each gets its adapter in the docs stage (agents.md).
- Is the repository public? If so, who the README is for (developers or general users) and which languages — recommended: the six in readme.md §1 (English default). This becomes the README task in the plan.

## §3 Read-back form

Send one at the end of stages 1, 2 and 3, or when 5–8 decisions have piled up.
Its purpose is to let the user see at a glance whether the AI understood correctly. Write it in the user's language; the example below shows the shape.

~~~
[Read-back] stage 2 · Scope

What I understood:
A program that sends videos on a Windows PC to the living-room TV. For now it sends
one file at a time, and leaves room to add continuous playback later.

Settled:
1. Plays mkv, avi and ts files too — you said so
2. Sends one file at a time — my default (reason: you chose to postpone continuous playback)
3. Stopping closes the player app on the TV — found in the existing code (core/cast_manager.py)

Please check:
Look at "my default" and "found in the existing code".
If all are right, say "right"; otherwise give only the number and the fix (e.g. 2 → several files).
~~~

- "What I understood" is 2–4 sentences, without jargon.
- Spell out the sources: `[U]` = you said so, `[X]` = found in existing code or docs (with location), `[AI]` = my default (with reason).
- Decision numbers (D###) go only into the files, never on screen.
- On approval, update that PRD section and set those DECISIONS entries to `confirmed`. If numbers were corrected, fix them and show only those items again.

## §4 Option comparison form

Present 2–3 options for a key technology decision in a message of its own. Do not mix it with other questions.

| | Option A | Option B | Option C (chosen) |
|---|---|---|---|
| Summary | | | |
| Pros | | | |
| Cons and risks | | | |
| Cost to reverse | | | |
| Recommendation | one-line reason | | |

Record the choice in DECISIONS together with the rejected options and why. This becomes the basis of the do-not-reopen list.

## §5 Settle the PRD

1. Check that every section of `docs/PRD.md` and `docs/SECURITY_POLICY.md` is filled and every decision has a source mark. Delete security policy fields that do not apply.
2. Start a reviewer subagent (agents.md §6). Give it only PRD.md and SECURITY_POLICY.md, no conversation context. Instruction:
   > You are an engineer seeing this project for the first time. Read only the attached PRD.md and SECURITY_POLICY.md and answer. List item by item: (1) places where these documents alone are not enough to start implementing, (2) sentences that contradict each other, (3) success criteria with no way to check them, (4) features whose exception behavior is undefined, (5) features with no Given–When–Then acceptance criteria, or criteria that cannot become tests as written, (6) data or components in the PRD missing from the security policy's classification or component tables, and features that involve permissions or sensitive data but have no security acceptance criterion. Do not fill gaps with guesses; if there is nothing, say "none".
3. Show the findings and how each will be handled. Put only real gaps into OPEN and ask about them.
4. When there are no gaps, open the gate.
   > [Gate] Do you approve the PRD and the security policy? Until you do, I will not write code, scaffold or install dependencies. If something needs fixing, tell me its number.
5. On approval, set the `Status:` line at the top of both the PRD and the security policy to `approved (YYYY-MM-DD)`. If git is present, propose a `docs: approve PRD` commit and point to the next stage (docs).

## §6 Resume (new session, cleared context, after compaction)

1. Read only `OPEN.md` and the head of `PRD.md` (status, stage). If `docs/SECURITY_POLICY.md` is missing, copy it from `templates/` (projects started before the skill had it).
2. Search `QA_LOG.md` only for the Q numbers you need.
3. Report "stage N, M open, next question" and continue asking. Never ask an answered question again.

## §7 Changing the PRD after approval

Use this when the PRD or the security policy must change during the build. A change to the security policy alone follows the same steps (the status mark in step 2 goes on the PRD). Changes to the plan alone are handled in plan.md.

1. State what changes and why (the newly learned fact). If it touches a do-not-reopen decision, show that first.
2. Set the PRD's head to `Status: changing (YYYY-MM-DD)`. Meanwhile the gate hook blocks edits outside docs/.
3. Ask only the questions for the changed sections, with new Q numbers. Write decisions with new D numbers and mark the old ones `superseded → D###`.
4. §3 read-back → update the PRD sections → one line in the PRD §8 change history (date, change, source D###).
5. List the affected plan tasks. Gate:
   > [Gate] Do you approve the PRD change ({summary})? Until you do, I will not write the code for this change.
6. On approval, set it back to `Status: approved (YYYY-MM-DD)` and move on to revising the plan.
