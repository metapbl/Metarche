# 점검 (audit)

문서가 실제 코드·상태와 맞는지, 비용 규칙을 지키는지 본다. 고치기 전에 보고서부터 낸다.

## §1 점검 항목
| # | 대상 | 기준 |
|---|---|---|
| 1 | CLAUDE.md | 첫 줄 `<!-- metarche -->`, 60줄 이내, `@` 임포트 없음 |
| 2 | CLAUDE.md 명령 | 적힌 명령이 실제로 실행됨 (위험 명령은 실행하지 않고 존재만 확인) |
| 3 | CLAUDE.md 구조·규칙 | 적힌 파일·함수가 실제로 있음, 규칙마다 근거 표시 |
| 4 | PROGRESS | `head:end` 표시 있음, 머리 40줄 이내, 완료 기록 50줄 이내 |
| 5 | PROGRESS 상태 | 마지막 커밋 hash가 `git log -1`과 맞음 |
| 6 | plans | `상태: active` 하나 이하, 체크박스와 실제 커밋이 맞음 |
| 7 | REFERENCE | 500줄 이내 또는 분할됨, 함정 대장에 근거 표시 |
| 8 | discovery | DECISIONS 대체 표시 정상, OPEN에 오래 남은 질문 |
| 9 | settings·훅 | `.claude/settings.json` JSON 유효, 훅 파일 존재 |
| 10 | 중복 | 전역 CLAUDE.md와 겹치는 문장 |

## §2 확인 명령 (PowerShell)
~~~
(Get-Content CLAUDE.md).Count; (Get-Content CLAUDE.md -TotalCount 1)
(Get-Content docs/PROGRESS.md | Select-String 'head:end').LineNumber
(Get-Content docs/REFERENCE.md).Count
Select-String -Path docs/plans/*.md -Pattern '^상태: active'
Get-Content .claude/settings.json -Raw | ConvertFrom-Json | Out-Null; "settings OK"
Test-Path .claude/hooks/progress-head.ps1, .claude/hooks/gate.ps1
git log -1 --format='%h %s'
~~~

## §3 보고서
항목마다 통과·주의·실패와 증거(명령 출력, 파일 > 위치)를 한 줄로 쓴다. 끝에 고칠 목록을 우선순위로 번호를 매겨 붙인다.

## §4 절차
1. §2를 실행하고 §3 보고서를 낸다. 이 단계에서는 아무것도 고치지 않는다.
2. 사용자가 고를 번호를 받으면 바뀔 부분(전후)을 보인다.
3. 승인 후 적용하고 해당 확인 명령을 다시 실행해 증거를 보인다.

## 관문
> [관문] 보고서의 {번호} 수정안을 적용하시겠습니까? 승인 전에는 문서를 고치지 않습니다.
