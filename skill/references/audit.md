# 점검 (audit)

문서가 실제 코드·상태와 맞는지, 비용 규칙을 지키는지 본다. 고치기 전에 보고서부터 낸다.

## §1 점검 항목
| # | 대상 | 기준 |
|---|---|---|
| 1 | CLAUDE.md | 첫 줄 `<!-- metarche -->`, 60줄 이내, `@` 임포트 없음 |
| 2 | CLAUDE.md 명령 | 적힌 명령이 실제로 실행됨 (위험 명령은 실행하지 않고 존재만 확인) |
| 3 | CLAUDE.md 구조·규칙 | 적힌 파일·함수가 실제로 있음, 규칙마다 근거 표시 |
| 4 | PROGRESS | `head:end` 표시 있음, 머리 40줄 이내, 완료 기록 50줄 이내 |
| 5 | PROGRESS 상태 | 계획·작업 번호가 진행 중 계획의 체크박스와 맞음 |
| 6 | plans | `상태: active` 하나 이하, 체크박스와 실제 커밋이 맞음 |
| 7 | REFERENCE | 500줄 이내 또는 분할됨, 함정 대장에 근거 표시 |
| 8 | discovery | DECISIONS 대체 표시 정상, OPEN에 오래 남은 질문 |
| 9 | settings·훅 | `.claude/settings.json` JSON 유효, 훅 파일 존재 |
| 10 | 중복 | 전역 CLAUDE.md와 겹치는 문장 |
| 11 | 보안 정책 | 상태 `approved`. 데이터 분류표의 저장 위치·구성요소 표가 실제 코드·스키마와 맞음, 암호화 표의 알고리즘이 코드에 쓰인 것과 같음 |
| 12 | 비밀값 | 작업 트리와 git 이력에 비밀값 없음 |
| 13 | deny 범위 | 정책 7절의 비밀값 보관 위치가 settings.json deny에 모두 있음 |
| 14 | 의존성 | 정책 8절의 취약점 검사 명령에 높음 이상이 없음 |

## §2 확인 명령 (PowerShell)
~~~
(Get-Content CLAUDE.md).Count; (Get-Content CLAUDE.md -TotalCount 1)
(Get-Content docs/PROGRESS.md | Select-String 'head:end').LineNumber
(Get-Content docs/REFERENCE.md).Count
if (Test-Path docs/plans) { Select-String -Path docs/plans/*.md -Pattern '^상태: active' } else { "plans 없음" }
Get-Content .claude/settings.json -Raw | ConvertFrom-Json | Out-Null; "settings OK"
Test-Path .claude/hooks/progress-head.ps1, .claude/hooks/gate.ps1, .claude/hooks/check.ps1
git log -1 --format='%h %s'
Get-Content docs/SECURITY_POLICY.md -TotalCount 3
if (Get-Command gitleaks -ErrorAction SilentlyContinue) { gitleaks git --redact } else { "gitleaks 없음: 작업 트리만 검사"; git grep -nIE 'AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY|sk_live_|ghp_[0-9A-Za-z]{36}' }
~~~
- 11·14는 명령 하나로 끝나지 않는다. 정책의 표를 한 줄씩 코드에서 찾아 보고, 14는 정책 8절의 명령을 실행한다.
- 비밀값이 나오면 값은 보고서에 쓰지 않고 파일 > 위치만 적는다.

## §3 보고서
항목마다 통과·주의·실패와 증거(명령 출력, 파일 > 위치)를 한 줄로 쓴다. 끝에 고칠 목록을 우선순위로 번호를 매겨 붙인다.

## §4 절차
1. §2를 실행하고 §3 보고서를 낸다. 이 단계에서는 아무것도 고치지 않는다.
2. 사용자가 고를 번호를 받으면 바뀔 부분(전후)을 보인다.
3. 승인 후 적용하고 해당 확인 명령을 다시 실행해 증거를 보인다.

## 관문
> [관문] 보고서의 {번호} 수정안을 적용하시겠습니까? 승인 전에는 문서를 고치지 않습니다.
