<!-- metarche -->
# {프로젝트명}

{한 줄: 무엇을, 누구를 위해. 상세는 docs/PRD.md}

## 구조
- `{폴더}/` — {역할}

## 명령
- 실행: `{명령}`
- 테스트: `{명령}`
- 빌드·배포: `{명령}` (실행 전 확인)

## 이 프로젝트의 규칙
<!-- 어기면 실제로 문제가 난 것만. 일반 원칙은 ~/.claude/CLAUDE.md에 있다. -->
- {규칙} (근거: D### 또는 R§n)

## 문서 지도
- `docs/PRD.md` — 무엇을 왜 (승인본. 바꾸려면 /metarche discover)
- `docs/PROGRESS.md` — 상태·다음 할 일 (머리는 세션 시작 때 자동 주입)
- `docs/REFERENCE.md` — 근거·외부 사양·함정 대장. 필요한 절만 검색해 읽는다
- `docs/plans/` — 작업 계획 (체크박스)
- `docs/discovery/` — DECISIONS는 결정 확인용, QA_LOG는 검색만

## 작업 기록
- 작업을 끝내면 계획 파일의 체크박스를 갱신한다. 세션을 마칠 때 docs/PROGRESS.md 머리 부분을 갱신하고 /metarche wrap을 제안한다.
- 관련 없는 작업으로 넘어갈 때는 /clear를 제안한다.
- 새 결정은 `docs/discovery/DECISIONS.md`에, 반복된 실수의 원인은 REFERENCE 함정 대장에 적는다.
- PRD 승인 전에는 docs/ 밖을 수정하지 않는다 (훅이 막는다).

## 압축 시 보존
- 압축할 때는 진행 중인 계획 파일 경로, 수정한 파일 목록, 확인 명령을 보존한다.
