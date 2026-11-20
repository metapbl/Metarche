# Security policy — {project name}

Status: draft | Level: basic | L1 | L2 | L3 | Updated: YYYY-MM-DD
<!-- Write this document in the user's language. Keep the `Status:` line, IDs and source tags exactly as they are. -->
<!-- Approved together with the PRD. To change it, follow the PRD change procedure (discover.md §7). -->
<!-- Written per metarche references/security.md. Delete fields that do not apply. End items with the source [U] [X] [AI] and D###. -->

## 1. Scope
- Level and why:
- Service regions and applicable regulations (only those the user named; if unknown, OPEN):
- What this policy does not cover:

## 2. Components and trust boundaries
| Component | Runs where | Internet-facing | Incoming input | Control at this boundary |
|---|---|---|---|---|
| {web front end} | user's browser | yes | user actions | none (untrusted) |
| {API server} | | | | authentication, authorization, input validation |

## 3. Data classification
| Data | Class | Stored where | Protection at rest | In transit | Logs and screen | Retention | Regulation |
|---|---|---|---|---|---|---|---|
| | public, internal, sensitive, credentials, high-risk | | | | | | |

## 4. Client rules
- 

## 5. Server rules
- Authentication:
- Authorization (who may do what):
- Input validation:
- Errors and logs:

## 6. Encryption
| Purpose | Algorithm or library | Key location | Protects | Rotation |
|---|---|---|---|---|

## 7. Secrets
| Name | Used by | Stored (development / production) | How to rotate if exposed |
|---|---|---|---|

## 8. Dependencies
- Vulnerability check command:
- Lock files:

## 9. Incident response
- Who to contact and who decides:
- Procedure: follow the default in security.md §7 | {what differs}

## 10. Applied in the agents (filled in the docs stage)
- Deny rules:
- security-guidance plugin (Claude Code): used | not used (why)
- Per-file security checks:
