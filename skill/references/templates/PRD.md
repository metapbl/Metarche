# PRD — {project name}

Status: draft | Stage: 1 Purpose | Updated: YYYY-MM-DD
<!-- Write this document in the user's language. Keep the `Status:` line, IDs and source tags exactly as they are. -->
<!-- No code, scaffolding or dependency installs until Status is approved (YYYY-MM-DD). -->
<!-- End every item with its source: [U] user · [X] existing code or docs · [AI] AI default. Decisions it rests on: (D###). -->

## 1. Purpose
- Problem to solve:
- Users (who, how many, which devices):
- Success criterion (one observable scene):
- Deadline and lifetime (by when; thrown away or maintained after use):

## 2. Scope
### 2.1 Must have
### 2.2 Nice to have
### 2.3 Not this time
### 2.4 Anti-goals (behavior that must never happen)
### 2.5 Structure prepared for later
### 2.6 Constraints (law, license, cost, privacy)

## 3. Features
### F1 {feature name}
- Normal flow:
- Exceptions (failure, interruption, lost connection, invalid input):
- Behavior by state (the same action while working, paused, shutting down):
- Interface (functions, commands, file formats, screen elements other parts rely on):
- Acceptance criteria (2–5 covering normal, exception and edge cases):
  - Given {state} / When {action} / Then {visible result}
- How it is checked: automated test | device (who judges, by seeing what)
- Security (when permissions or data of class sensitive or above are involved): who may do it, data classes handled, at least one security acceptance criterion
- Source: D###

## 4. Technical decisions
| Item | Choice | Rejected options (why) | Source |
|---|---|---|---|

## 5. Non-functional requirements
- Runtime environment (OS, language version, network):
- Performance (startup time, responsiveness, resources):
- Distribution form:
- Public repository or not; README audience and languages (if public, the `readme.md` standard):
- Logs (location, format, verbose mode):
- Security level and why (details in `docs/SECURITY_POLICY.md`):

## 6. Verification and operations
- What is tested automatically / what is checked on a device, and how results are reported:
- Full test command, how long it takes, baseline time (revisit when exceeded; e.g. 60 s):
- Per-file checks (commands that take the edited file's path last, per extension):
- End-of-turn checks — project-wide (commands that take no path, e.g. `cargo clippy`, `tsc --noEmit`):
- Dangerous commands (ask before running):
- Version control (commit unit, message format):

## 7. Open questions
→ `docs/discovery/OPEN.md`

## 8. Change history
| Date | Change | Source |
|---|---|---|
