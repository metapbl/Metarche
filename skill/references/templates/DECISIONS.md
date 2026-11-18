# DECISIONS — decision ledger

<!-- Write this document in the user's language. Keep IDs, source tags and status words exactly as they are. -->
<!-- Kept until the project ends. Never delete entries. -->
<!-- When a decision is reversed, set its status to `superseded` and end its decision cell with `superseded → D###`. -->
<!-- Status: `proposed` (during the interview) → `confirmed` (read-back approved) → `superseded` -->

| ID | Date | Stage | Decision | Source | From Q | Rejected options (why) | Status |
|---|---|---|---|---|---|---|---|

## Do-not-reopen rule
A `confirmed` decision with rejected options recorded is not proposed again unless there is a new fact.
If a new fact appears, state it first and ask again under a new Q number.

## Relation to other documents
- The content of a decision is written only here. Other documents point to it by D number.
- `docs/REFERENCE.md` R§3 lists only the decisions that shape the design, as `D### — one-line summary`.
- Decisions made during the build are appended here too (stage column: `build`).
