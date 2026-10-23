---
name: metarche
description: "프로젝트의 첫 원리를 세우는 절차. 질의응답으로 PRD를 확정하고, Claude Code용 문서(CLAUDE.md·PROGRESS·REFERENCE)와 작업 계획을 만든 뒤, 승인 관문을 거쳐 구현·검증·기록을 반복한다. 새 프로젝트 착수(new), 기존 프로젝트 이관(adopt), 세션 마무리(wrap), 문서 점검(audit)에 쓴다. Project bootstrap: discovery interview, PRD, Claude Code docs, plan, build loop with approval gates and file-based state that survives /clear and compaction."
argument-hint: "[new|adopt|discover|docs|plan|build|wrap|audit|status]"
disable-model-invocation: true
---

# metarche — meta + archē

프로젝트마다 그 프로젝트의 첫 원리(목적·범위·규칙)를 사용자와의 질의응답으로 세우고,
그 원리에 따라 문서를 만들고 코드를 쓴다.

## 철칙

1. **관문 전 착수 금지.** PRD 승인 전에는 코드, 뼈대, 의존성 설치, 설정 파일 생성을 하지 않는다. 문서 구성과 작업 계획도 각각 승인된 뒤에만 다음 단계로 간다.
2. **상태는 파일에 둔다.** 답·결정·오류는 나온 즉시 파일에 적는다. 대화에만 있는 사실은 압축되면 사라진 것으로 본다.
3. **먼저 읽고 묻는다.** 코드·문서·전역 프로필(`~/.claude/CLAUDE.md`)에 답이 있으면 묻지 않고 확인만 받는다.
4. **출처를 표시한다.** 모든 결정에 `[U]`(사용자가 말함), `[X]`(기존 코드·문서에서 추출), `[AI]`(AI가 채운 기본값) 중 하나를 붙인다. `[X]`와 `[AI]`는 되짚기에서 반드시 보여 준다.
5. **필요한 것만 읽는다.** 단계에 해당하는 references 파일 하나만 읽는다. `QA_LOG.md`는 전체를 읽지 않고 검색한다.
6. **증거 없이 완료라 하지 않는다.** 완료는 확인 명령의 출력이나 사용자의 실기기 결과로만 선언한다.
7. **헷갈리면 멈추고 묻는다.** 가정으로 진행하지 않는다. 오타 수정 같은 사소한 작업에는 이 절차를 적용하지 않는다.

## 시작: 상태 판별

인자가 있으면 그 모드로 간다. 없으면 아래 표를 위에서부터 확인해 먼저 맞는 모드로 간다.
판별 결과와 다음 행동을 한 줄로 알리고 확인을 받는다.

| 조건 | 모드 |
|---|---|
| `docs/discovery/OPEN.md` 있음, `docs/PRD.md` 상태가 `approved` 아님 | discover (이어서) |
| PRD `approved`, 루트 `CLAUDE.md`에 `<!-- metarche -->` 표시 없음 | docs |
| metarche `CLAUDE.md` 있음, `docs/plans/`에 진행 중 계획 없음 | plan |
| `docs/PROGRESS.md`와 진행 중 계획 있음 | build |
| 코드나 문서는 있으나 위 파일이 없음 | adopt |
| 폴더가 비어 있음 | new |

`status`는 판별 결과와 현재 단계, 미결 질문 수만 보고하고 멈춘다.

## 단계 지도

| 단계 | 모드 | 읽을 파일 | 산출물 | 관문 |
|---|---|---|---|---|
| 0 탐색 | new·adopt | discover.md §0 (adopt는 adopt.md 먼저) | QA_LOG 초기 항목, OPEN | - |
| 1 목적 | discover | discover.md §1~3 | PRD §1 | 되짚기 |
| 2 범위 | discover | discover.md §1~3 | PRD §2 | 되짚기 |
| 3 기능 | discover | discover.md §1~3 | PRD §3 | 되짚기 |
| 4 방식 | discover | discover.md §4 | PRD §4 | 안 선택 |
| 5 확정 | discover | discover.md §5 | PRD `approved` | **PRD 승인** |
| 6 문서 | docs | docs.md | CLAUDE.md, PROGRESS, REFERENCE, settings | 문서 승인 |
| 7 계획 | plan | plan.md | `docs/plans/YYYY-MM-DD-*.md` | 계획 승인 |
| 8 구현 | build | execute.md | 코드, 기록 | 작업마다 |
| 9 개선 | build | execute.md §개선 | rules·스킬 제안 | 제안 승인 |
| - | wrap | execute.md §wrap | PROGRESS 갱신 | - |
| - | audit | audit.md | 점검 보고서 | 수정 승인 |

읽을 파일은 이 스킬 폴더의 `references/`에 있고, 문서 양식은 `references/templates/`에 있다.

## 질문 규칙 (요약, 상세는 discover.md)

- 목적·범위 같은 큰 질문은 한 번에 하나만 한다. 세부 선택은 번호를 붙여 3~6개씩 묶는다.
- 모든 질문에 추천안과 이유를 한 줄로 붙인다. 사용자는 "추천대로"로 답할 수 있다.
- 답이 바뀌어도 결과물이 달라지지 않는 질문은 하지 않는다. 그런 항목은 `[AI]`로 채우고 되짚기에서 보여 준다.
- 질문 수 목표는 없다. 보통 소형 15~30개, 중형 40~80개다.

## 기록 규칙 (요약, 양식은 templates/)

- 답을 받으면 즉시 `docs/discovery/QA_LOG.md`에 추가한다. 고치지 않고 추가만 한다.
- 확정된 것은 `DECISIONS.md`에 `D###`로 적고 근거 `Q###`를 단다. 뒤집히면 지우지 않고 `← D###로 대체`를 단다.
- `OPEN.md`는 우선순위 대기열이다. 해결된 질문은 지우고 해결한 Q번호를 남긴다.
- 되짚기가 승인되면 해당 결정을 `docs/PRD.md`에 반영한다.
- 구현 중 생긴 질문도 OPEN에 넣고 같은 방식으로 처리한다.

## 관문 문구

관문에서는 아래 형식으로 묻는다. "승인", "네 진행" 같은 명시적 승인이 있을 때만 넘어간다.
침묵이나 다른 주제의 답은 승인이 아니다.

> [관문] {무엇}을 승인하시겠습니까? 승인 전에는 {금지되는 일}을 하지 않습니다. 고칠 곳이 있으면 번호로 알려 주십시오.

## 응답 끝맺음

단계를 진행하는 동안 모든 응답 끝에 한 줄 상태를 붙인다.

`[metarche] 단계 3 기능 · 미결 7개 · 다음: Q041~Q045 묶음 질문`

## 출처

superpowers(brainstorming, writing-plans), ECC, andrej-karpathy-skills, planning-with-files,
claude-md-improver, Claude Code 공식 문서의 방식을 참고했다. 상세는 저장소의 `NOTICE`.
