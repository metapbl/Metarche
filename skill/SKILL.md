---
name: metarche
description: "Sets a project's first principles. A Q&A interview settles an approved PRD, then the skill writes Claude Code docs (CLAUDE.md, PROGRESS, REFERENCE) and a plan, and repeats build, verify and record behind approval gates. For starting a project (new), adopting an existing one (adopt), ending a session (wrap), auditing docs (audit) and applying skill revisions (upgrade). State lives in files, so it survives /clear and compaction."
argument-hint: "[new|adopt|discover|docs|plan|build|wrap|audit|upgrade|status]"
disable-model-invocation: true
---

# metarche — meta + archē

For each project, set its first principles (purpose, scope, rules) through an interview with the user,
then write the documents and the code by those principles.

## Language
- These instructions are in English. Speak to the user, and write every project document (PRD, SECURITY_POLICY, CLAUDE.md, PROGRESS, REFERENCE, plans, discovery files), in the user's language: the language of `~/.claude/CLAUDE.md`, otherwise the language the user writes in. Translate template headings and labels when you create the files.
- Keep these markers exactly as written, in any document language, because hooks and stage detection read them: `Status: …` lines, `<!-- metarche -->`, `<!-- metarche:draft -->`, `<!-- head:end -->`, the IDs `Q###` `D###` `F#` `T#` `R§n` `U#`, and the source tags `[U]` `[X]` `[AI]`.
- Projects created before the English version of this skill use `상태:` instead of `Status:`. Read it the same way; upgrade U7 migrates it.

## Rules
1. **Nothing starts before its gate.** Before the PRD is approved: no code, no scaffolding, no dependency installs, no config files. The document set and the plan each move on only after their own approval.
2. **State lives in files.** Write answers, decisions and errors to files as soon as they come up. A fact that exists only in the conversation is lost after compaction.
3. **Read first, then ask.** If the code, the docs or the global profile (`~/.claude/CLAUDE.md`) already answers a question, do not ask it; only confirm.
4. **Mark the source.** Every decision carries `[U]` (the user said it), `[X]` (taken from existing code or docs) or `[AI]` (a default the AI filled in). Always show `[X]` and `[AI]` items in the read-back.
5. **Read only what you need.** Read only the references files the current stage needs. Search `QA_LOG.md`; never read it whole.
6. **No "done" without evidence.** Declare completion only from a check command's output or the user's result on the real device.
7. **When unsure, stop and ask.** Do not proceed on assumptions. Trivial work such as fixing a typo does not go through this procedure.

## Start: detect the state
With an argument, go to that mode. Without one, check the table top to bottom and take the first match.
If `new` or `adopt` does not fit the folder (`new` in a non-empty folder, `adopt` in an empty one), do not proceed; show the mismatch and ask which mode to use.
Report the detected state and the next action in one line and get confirmation.

| Condition | Mode |
|---|---|
| `docs/discovery/OPEN.md` exists and the `Status:` of `docs/PRD.md` is not `approved` | discover (resume) |
| PRD `approved`, and the first line of the root `CLAUDE.md` is not `<!-- metarche -->` (no file, or `<!-- metarche:draft -->`) | docs |
| `CLAUDE.md` starts with `<!-- metarche -->` and no plan in `docs/plans/` has `Status: active` | plan |
| `docs/PROGRESS.md` and a plan with `Status: active` exist | build |
| Code or docs exist but none of the files above | adopt |
| The folder is empty (nothing but `.git` and `.claude`) | new |

`status` reports only the detected state, the current stage and the number of open questions, then stops.

## Stage map

| Stage | Mode | Read | Output | Gate |
|---|---|---|---|---|
| 0 Explore | new, adopt | discover.md §0 (adopt reads adopt.md first) | first QA_LOG entries, OPEN | - |
| 1 Purpose | discover | discover.md §1–3 | PRD §1 | read-back |
| 2 Scope | discover | discover.md §1–3 | PRD §2 | read-back |
| 3 Features | discover | discover.md §1–3 | PRD §3 | read-back |
| 4 Approach | discover | discover.md §4, security.md §1–6 | PRD §4–5, SECURITY_POLICY | option choice |
| 5 Settle | discover | discover.md §5 | PRD and SECURITY_POLICY `approved` | **PRD and security policy approval** |
| 6 Docs | docs | docs.md, security.md §8 | CLAUDE.md, PROGRESS, REFERENCE, settings | docs approval |
| 7 Plan | plan | plan.md (readme.md if the repository is public) | `docs/plans/YYYY-MM-DD-*.md` | plan approval |
| 8 Build | build | execute.md | code, records | per task |
| 9 Improve | build | execute.md §improve | rule and skill proposals | proposal approval |
| - | wrap | execute.md §wrap | PROGRESS update | - |
| - | audit | audit.md | audit report | fix approval |
| - | upgrade | upgrade.md | hooks, settings and docs updated | apply approval |

The files to read are in this skill's `references/`; document templates are in `references/templates/`.

## Question rules (summary; details in discover.md)
- Big questions (purpose, scope) one at a time. Detailed choices are numbered and grouped 3–6 at a time.
- Every question carries a recommendation and a one-line reason. The user can answer "as recommended".
- Do not ask questions whose answer would not change the result. Fill those with `[AI]` and show them in the read-back.
- There is no target number of questions. Typically 15–30 for a small project, 40–80 for a medium one.

## Record rules (summary; formats in templates/)
- Append each answer to `docs/discovery/QA_LOG.md` at once. Append only; never edit.
- Write settled items to `DECISIONS.md` as `D###` with their source `Q###`. When one is reversed, do not delete it; mark it `superseded → D###`.
- `OPEN.md` is a priority queue. Remove a question once answered and keep the Q number that answered it.
- When a read-back is approved, carry those decisions into `docs/PRD.md`.
- Questions that come up during the build also go into OPEN and are handled the same way.

## Gate wording
At a gate, ask in this form (in the user's language). Move on only on an explicit approval such as "approve" or "yes, go ahead".
Silence or an answer about something else is not approval.

> [Gate] Do you approve {what}? Until you do, I will not {what is blocked}. If something needs fixing, tell me its number.

## Ending each reply
While a stage is in progress, end every reply with a one-line status (in the user's language):

`[metarche] stage 3 Features · 7 open · next: 5 questions on screens and shortcuts`

## Credits
Draws on superpowers (brainstorming, writing-plans), ECC, andrej-karpathy-skills, planning-with-files,
claude-md-improver and the Claude Code documentation. Details are in the repository's `NOTICE`.
