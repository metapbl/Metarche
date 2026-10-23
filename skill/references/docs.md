# 단계 6 — 문서 (docs)

PRD가 `approved`일 때만 시작한다. 입력: `docs/PRD.md`, `docs/discovery/DECISIONS.md`, (adopt면) `docs/legacy/`.
산출물: 루트 `CLAUDE.md`, `docs/PROGRESS.md`, `docs/REFERENCE.md`, `.claude/settings.json`, `.claude/hooks/*.ps1`.
양식은 `templates/`에 있다. 그대로 복사하지 말고 PRD에 해당 없는 칸은 지운다.

## §1 무엇을 어디에 두나
| 정보 | 위치 | 이유 |
|---|---|---|
| 매 세션 필요, 거의 안 바뀜 (명령·구조·프로젝트 규칙) | CLAUDE.md | 항상 로드됨 |
| 자주 바뀜 (상태·다음 할 일·미해결) | PROGRESS 머리 | 훅이 주입 |
| 가끔 필요 (근거·외부 사양·함정) | REFERENCE | 검색해 읽음 |
| 결정과 버린 안 | DECISIONS (계속 씀) | 원장 하나 |
| 작업 단계 | docs/plans/ | 체크박스 |
| 반드시 지켜야 함 (위험 명령·관문) | settings.json 권한·훅 | Claude Code가 강제 |
| 사용자 공통 성향 | ~/.claude/CLAUDE.md | 프로젝트에 다시 쓰지 않음 |
| 서식 | 포매터·린터 설정 | 문서에 적지 않음 |

## §2 CLAUDE.md
- 첫 줄은 `<!-- metarche:draft -->`로 만들고, 관문 승인 뒤 `<!-- metarche -->`로 바꾼다 (상태 판별용). 60줄 이내, 넘치면 REFERENCE로 내린다.
- 명령은 복사해 바로 실행되는 형태로 적는다.
- 규칙은 어기면 실제로 문제가 나는 것만, 근거(D###·R§n)를 단다. 일반 원칙은 쓰지 않는다.
- 코드 위치는 줄 번호 대신 `파일 > 함수`.
- `@파일` 임포트 금지(매번 전체 로드). 경로만 적고 필요할 때 읽게 한다.
- "압축 시 보존" 절을 둔다.

## §3 PROGRESS (토큰 비용 규칙)
1. 머리(`<!-- head:end -->` 위)는 40줄 이내: 상태·다음 할 일·미해결·확인 대기.
2. 갱신은 머리만 고친다. 전체 재작성 금지.
3. 작업 단위 = 커밋 하나. 단위가 끝나면 계획 체크박스, 세션 끝에 머리를 갱신한다.
4. 완료 기록은 한 줄 + 커밋 hash. 50줄을 넘으면 `docs/history/YYYY-MM.md`로 옮긴다.

## §4 REFERENCE
- 절 번호 `R§n`으로 참조한다. 전체를 읽지 않고 검색한다.
- R§3 설계 근거는 `D### — 한 줄 요약` 색인만 둔다. 결정 내용은 DECISIONS에만 쓴다.
- 함정 대장(`T<n>`)에는 두 번 겪었거나 원인 찾기에 오래 걸린 것만 적는다.
- 외부 사양에는 버전과 출처 URL을 단다.
- 약 500줄을 넘으면 `docs/reference/` 아래 주제별로 나누고 REFERENCE는 목차만 남긴다.

## §5 settings.json·훅
- `templates/settings.json` → `.claude/settings.json`, `templates/hooks/*.ps1` → `.claude/hooks/`.
  - 이미 있는 파일은 덮어쓰지 않는다. settings.json은 기존 내용에 `permissions`·`hooks` 항목만 더하고, 같은 이름의 훅 파일은 차이를 보인다. 어느 쪽이든 전후를 보이고 승인받은 뒤 적용한다.
- PRD §6 "위험한 명령"을 ask/deny로 옮긴다. 기본: 커밋·푸시 ask, `.env` 읽기 deny.
- progress-head.ps1: 세션 시작·재개·/clear·압축 후 PROGRESS 머리 주입.
- gate.ps1: PRD 상태가 `approved`가 아니면 docs/·.claude/·CLAUDE.md 밖 Edit/Write/NotebookEdit를 막는다.
  - 훅은 PRD 승인 뒤인 이 단계에서 설치되므로 실제로 막는 때는 PRD 변경 중(`changing`)뿐이다. 승인 전(draft)은 철칙 1로 지킨다.
  - 셸 명령의 쓰기는 못 막으므로 CLAUDE.md 규칙과 함께 쓴다.
  - 프로젝트 밖 파일(예: `~/.claude/`)도 막힌다. 의도한 동작이다. 필요하면 사용자가 직접 고친다.
- 개인 설정은 `.claude/settings.local.json` (git 제외).

## §6 절차
1. PRD·DECISIONS를 읽고 §1 표에 따라 분류한 목록(파일별 절 제목, 들어갈 항목, 출처 표시)을 보여 준다.
2. 분류 승인 후 파일을 만든다. REFERENCE R§3에는 설계에 영향을 주는 확정 결정의 색인을 넣는다.
3. 각 파일 줄 수와 §7 확인 결과를 증거로 제시한다.
4. 관문.
5. 승인되면 CLAUDE.md 첫 줄을 `<!-- metarche -->`로 바꾼다.

재개할 때 CLAUDE.md 첫 줄이 `<!-- metarche:draft -->`면 파일을 다시 만들지 않고 3번부터 한다.

## §7 확인
- CLAUDE.md 60줄 이내, 첫 줄 `<!-- metarche:draft -->` (승인 후 `<!-- metarche -->`)
- PROGRESS 머리 40줄 이내
- `/hooks`에 SessionStart·PreToolUse 표시, `/clear` 직후 머리가 컨텍스트에 들어옴
- `/permissions`에 ask·deny 규칙 표시

## 관문
> [관문] 문서 구성(CLAUDE.md·PROGRESS·REFERENCE·settings·훅)을 승인하시겠습니까? 승인 전에는 작업 계획과 코드를 만들지 않습니다. 고칠 곳이 있으면 번호로 알려 주십시오.
