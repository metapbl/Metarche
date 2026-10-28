# Metarche

meta + archē (메타르케) — 프로젝트의 첫 원리를 세우는 Claude Code 스킬.
질의응답으로 PRD와 문서 구조를 수립하고 코딩까지 이어 가는 절차를 담는다.

## 하는 일
- 질의응답으로 목적·범위·기능·방식을 정하고 PRD를 승인받는다.
- Claude Code용 문서(CLAUDE.md, PROGRESS, REFERENCE)와 권한·훅 설정을 만든다.
- 작업 계획을 세우고, 승인 관문을 거쳐 구현·확인·기록을 반복한다.
- 모든 상태를 파일에 두어 `/clear`와 압축 뒤에도 이어 간다.

## 설치 (Windows, PowerShell 7)
~~~
git clone https://github.com/metapbl/Metarche.git "$env:USERPROFILE\My Projects\metarche"
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\skills" | Out-Null
New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\skills\metarche" -Target "$env:USERPROFILE\My Projects\metarche\skill"
~~~
Claude Code에서 `/skills`에 metarche가 보이면 끝이다. 갱신은 저장소 폴더에서 `git pull`.

## 사용
| 명령 | 언제 |
|---|---|
| `/metarche` | 상태를 판별해 알맞은 단계로 (인자 없이) |
| `/metarche new` | 빈 폴더에서 새 프로젝트 착수 |
| `/metarche adopt` | 기존 프로젝트를 이 체계로 옮김 |
| `/metarche discover` | 질의응답 이어 가기, 승인된 PRD 변경 |
| `/metarche docs` · `plan` · `build` | 문서 · 계획 · 구현 단계 |
| `/metarche wrap` | 세션 마무리 (PROGRESS 갱신) |
| `/metarche audit` | 문서 점검 보고서 |
| `/metarche status` | 현재 단계와 미결 수만 보고 |

자동으로 호출되지 않는다(`disable-model-invocation: true`). 직접 불렀을 때만 작동한다.

## 구조
~~~
skill/
├─ SKILL.md            진입점: 철칙, 상태 판별, 단계 지도
└─ references/
   ├─ discover.md      0~5단계 질의응답, PRD 확정·변경
   ├─ docs.md          6단계 문서
   ├─ plan.md          7단계 계획
   ├─ execute.md       8~9단계 구현·개선, wrap
   ├─ audit.md         점검
   ├─ adopt.md         기존 프로젝트 이관
   └─ templates/       PRD·QA_LOG·OPEN·DECISIONS·CLAUDE·PROGRESS·REFERENCE·profile, settings.json, hooks/
~~~

## 라이선스
MIT, Copyright (c) 2026 META PUBLIC. 참고한 프로젝트는 `NOTICE`.
