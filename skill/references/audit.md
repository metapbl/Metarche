# audit

Check whether the documents match the actual code and state, and whether the cost rules hold. Report before fixing anything.

## §1 Audit items
| # | Target | Criterion |
|---|---|---|
| 1 | AGENTS.md | first line `<!-- metarche -->`, within 60 lines, no `@` imports; `CLAUDE.md` is only `@AGENTS.md` (plus Claude-only notes) if Claude Code is used |
| 2 | AGENTS.md commands | the listed commands actually run (dangerous commands: check they exist, do not run them) |
| 3 | AGENTS.md structure and rules | the listed files and functions exist; every rule has a source |
| 4 | PROGRESS | `head:end` marker present, head within 40 lines, done log within 50 lines |
| 5 | PROGRESS status | plan and task number match the checkboxes of the active plan |
| 6 | plans | at most one `Status: active`; checkboxes match the actual commits |
| 7 | REFERENCE | within 500 lines or split; trap log entries have sources |
| 8 | discovery | DECISIONS `superseded →` marks are consistent; questions left long in OPEN |
| 9 | hooks and adapters | the hook scripts exist in `.metarche/hooks/`; each adapter file for the agents in PRD §6 is valid (agents.md) |
| 10 | duplication | sentences that repeat the global instructions |
| 11 | security policy | `Status: approved`. The storage locations in the data classification and the component table match the actual code and schema; the algorithms in the encryption table are the ones the code uses |
| 12 | secrets | no secrets in the working tree or git history |
| 13 | deny scope | every secret storage location in policy §7 is in the agents' deny rules where they exist, and in the AGENTS.md rule |
| 14 | dependencies | the vulnerability check in policy §8 reports nothing high or above |
| 15 | wired checks | check.ps1 `$checks` and finish.ps1 `$finish` are not empty. Empty is a warning (passes if PRD §6 says there are no checks) |
| 16 | README | for a public repository, the readme.md §6 checks pass (translations match, commands run, links resolve, nothing forbidden) |

Projects created before the English version of this skill use `상태:` instead of `Status:`; treat it the same and suggest upgrade U7.

## §2 Check commands (PowerShell)
~~~
(Get-Content AGENTS.md).Count; (Get-Content AGENTS.md -TotalCount 1)
(Get-Content docs/PROGRESS.md | Select-String 'head:end').LineNumber
(Get-Content docs/REFERENCE.md).Count
if (Test-Path docs/plans) { Select-String -Path docs/plans/*.md -Pattern '^(Status|상태): active' } else { "no plans" }
foreach ($f in ".claude/settings.json", ".codex/hooks.json") { if (Test-Path $f) { Get-Content $f -Raw | ConvertFrom-Json | Out-Null; "$f OK" } }
Test-Path .metarche/hooks/progress-head.ps1, .metarche/hooks/gate.ps1, .metarche/hooks/check.ps1, .metarche/hooks/finish.ps1
git log -1 --format='%h %s'
Get-Content docs/SECURITY_POLICY.md -TotalCount 3
if (Get-Command gitleaks -ErrorAction SilentlyContinue) { gitleaks git --redact } else { "no gitleaks: working tree only"; git grep -nIE 'AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY|sk_live_|ghp_[0-9A-Za-z]{36}' }
~~~
- Items 11 and 14 take more than one command. Look up each row of the policy tables in the code; for 14, run the command in policy §8.
- If a secret turns up, do not write its value in the report; give only file > location.

## §3 Report
One line per item: pass, warning or fail, with evidence (command output, file > location). End with a numbered fix list in priority order.

## §4 Procedure
1. Run §2 and deliver the §3 report. Fix nothing at this step.
2. When the user picks numbers, show the changes (before and after).
3. Apply after approval and rerun the relevant check commands as evidence.

## Gate
> [Gate] Do you approve applying fixes {numbers} from the report? Until you do, I will not change the documents.
