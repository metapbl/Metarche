# adopt — bring an existing project into metarche

For a project that already has code and documents. No code changes in this stage.
Before starting, copy the templates to `docs/` as in the first paragraph of discover.md §0.
When done, continue from step 4 of discover.md §0 (create OPEN).

## §1 Read (before asking)
- Existing guidance and progress documents (CLAUDE.md, AGENTS.md, progress and worklog files, README)
- Dependency and build files (requirements.txt, pyproject.toml, package.json, etc.), entry points
- `git log --oneline -30`, folder structure (two levels deep)
- For large documents, look at the table of contents and headings first and read only the sections you need.

## §2 Extract
| Found in the existing project | Goes to | Mark |
|---|---|---|
| Purpose, audience, scope | draft of PRD §1–2 | [X] source: file > section |
| Features and actual behavior | PRD §3 | [X] |
| Technology choices and reasons | DECISIONS (D###), PRD §4 | [X] |
| Working rules | dropped if already global; only project-specific ones are candidates | [X] |
| Progress, next steps | candidates for the PROGRESS head | [X] |
| Open and known problems | OPEN or PROGRESS open problems | [X] |
| Root-cause analyses, traps | candidates for the REFERENCE trap log | [X] |
| How authentication, permissions, encryption and secrets are handled; the data stored | draft SECURITY_POLICY (components, data classification) | [X] |
| Secrets inside code or config | tell the user at once and recommend rotating them (security.md §7). Never copy the values into documents | [X] |
| Rules only for chat-based collaboration (how code is exported, etc.) | drop list | - |

- If documents and code disagree, treat the code as the truth and record the difference in QA_LOG as an [X] entry.
- Create OPEN after the adoption (discover.md §0 step 4). Move the items meant for OPEN over from QA_LOG then.
- Ask only about what you could not find. Mark guessed values [AI].

## §3 Read-back
1. Show the mapping table (section of an existing document → new place, or dropped).
2. Show the [X] items in groups and ask only for "the numbers that are wrong".
3. Show the drop list separately and get it confirmed.

## §4 Existing documents
- Do not delete them. After approval move them to `docs/legacy/` and keep them for reference until the new documents are approved.
- The root AGENTS.md (and the CLAUDE.md bridge) is created anew in the docs stage after the move.

## §5 Next
After the read-back, with a draft PRD in place, continue from step 4 of discover.md §0 and ask only about the gaps. From there it is the same as a new project.
Except: in the plan, put a characterization test before the first task that changes existing code (plan.md §2).
