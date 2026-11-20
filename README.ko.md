<p align="center">
  <strong>Language:</strong>
  <a href="README.md">English</a> |
  <a href="README.ko.md">한국어</a> |
  <a href="README.zh-CN.md">简体中文</a> |
  <a href="README.ja.md">日本語</a> |
  <a href="README.es.md">Español</a> |
  <a href="README.ru.md">Русский</a>
</p>

<p align="center"><sub>이 문서는 영어판을 AI로 번역한 것입니다. 내용이 다르면 영어판을 따릅니다.</sub></p>

# Metarche

<p align="center">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-blue?style=flat-square"></a>
  <a href="#설치"><img alt="Agent Skill for Claude Code and Codex" src="https://img.shields.io/badge/Agent_Skill-Claude_Code_%7C_Codex-D97757?style=flat-square"></a>
  <a href="#요구-사항"><img alt="Platform: Windows, macOS, Linux" src="https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-0078D4?style=flat-square"></a>
  <a href="#요구-사항"><img alt="PowerShell 7" src="https://img.shields.io/badge/PowerShell-7-5391FE?style=flat-square"></a>
  <a href="https://github.com/metapbl/Metarche/actions/workflows/hooks.yml"><img alt="Hook tests" src="https://img.shields.io/github/actions/workflow/status/metapbl/Metarche/hooks.yml?branch=main&style=flat-square&label=hook%20tests"></a>
</p>

meta + archē(메타르케): 질의응답으로 PRD·문서·계획을 세우고, 승인 관문을 거쳐 구현까지 이어 가는 에이전트 스킬.

> [!NOTE]
> 스킬의 지시문은 영어로 쓰여 있습니다. 사용자와의 대화와 프로젝트 문서(PRD, CLAUDE.md, 계획)는 사용자의 언어로 작성합니다.

## 하는 일
- 질의응답으로 목적·범위·기능·방식을 정하고 PRD를 승인받습니다.
- 보안 수준과 정책(데이터 등급, 클라이언트·서버 신뢰 경계, 암호화)을 정해 PRD와 함께 승인받습니다.
- 프로젝트 문서(AGENTS.md, PROGRESS, REFERENCE)를 만들고, 에이전트마다 훅과 권한을 연결합니다. 훅은 편집 때 검사, 작업 끝 프로젝트 검사, PRD 관문, 진행 상황 주입입니다. Claude Code와 Codex용 어댑터가 있고, 다른 에이전트는 훅 없이 AGENTS.md를 따릅니다.
- 작업 계획을 세우고, 단계마다 승인을 거쳐 구현 → 확인 → 기록을 반복합니다.
- 모든 상태를 파일에 두어 `/clear`와 컨텍스트 압축 뒤에도 이어 갑니다.

## 요구 사항
- Windows, macOS 또는 Linux와 PowerShell 7(`pwsh`). 훅이 PowerShell 스크립트이며, 세 OS 모두에서 [훅 시험](tests/hooks.test.ps1)으로 확인합니다.
- Agent Skills와 AGENTS.md를 읽는 코딩 에이전트: [Claude Code](https://code.claude.com/docs)(시험 완료) 또는 [Codex](https://learn.chatgpt.com/docs/build-skills)(공식 문서대로 어댑터를 만들었으나 아직 실행해 보지 않음). 그 밖의 에이전트는 훅 없이 동작합니다.
- git (권장)

## 설치
Windows (PowerShell 7):
~~~
git clone https://github.com/metapbl/Metarche.git "$env:USERPROFILE\My Projects\metarche"
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\skills" | Out-Null
New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\skills\metarche" -Target "$env:USERPROFILE\My Projects\metarche\skill"
~~~
macOS / Linux ([PowerShell 7](https://learn.microsoft.com/powershell/scripting/install/installing-powershell)을 먼저 설치):
~~~
git clone https://github.com/metapbl/Metarche.git ~/metarche
mkdir -p ~/.claude/skills && ln -s ~/metarche/skill ~/.claude/skills/metarche
~~~
Codex (같은 폴더를 `~/.agents/skills` 아래에 연결), Windows:
~~~
New-Item -ItemType Directory -Force "$env:USERPROFILE\.agents\skills" | Out-Null
New-Item -ItemType Junction -Path "$env:USERPROFILE\.agents\skills\metarche" -Target "$env:USERPROFILE\My Projects\metarche\skill"
~~~
macOS / Linux:
~~~
mkdir -p ~/.agents/skills && ln -s ~/metarche/skill ~/.agents/skills/metarche
~~~
Claude Code나 Codex의 `/skills`에 `metarche`가 보이면 끝입니다. 갱신은 저장소 폴더에서 `git pull`을 실행합니다.

## 사용
| 명령 | 언제 |
|---|---|
| `/metarche` | 인자 없이: 프로젝트 상태를 판별해 알맞은 단계로 |
| `/metarche new` | 빈 폴더에서 새 프로젝트 시작 |
| `/metarche adopt` | 기존 프로젝트를 이 체계로 이관 |
| `/metarche discover` | 질의응답 이어 가기, 승인된 PRD·보안 정책 바꾸기 |
| `/metarche docs` · `plan` · `build` | 문서 · 계획 · 구현 단계 |
| `/metarche wrap` | 세션 마무리: PROGRESS 갱신, 남은 변경 커밋, push는 물음 |
| `/metarche audit` | 문서·보안·README 점검 보고서 |
| `/metarche upgrade` | 스킬 개정분을 기존 프로젝트의 훅·설정·문서에 반영 |
| `/metarche status` | 현재 단계와 미결 질문 수만 보고 |

자동으로 호출되지 않습니다(`disable-model-invocation: true`). 직접 불렀을 때만 작동합니다. Codex에서는 `$metarche`로 부릅니다(예: `$metarche new`). `agents/openai.yaml`이 Codex가 스스로 불러오지 않게 막습니다.

## 언어 스킬
Metarche 자체는 특정 언어에 묶이지 않습니다. 언어 스킬이 한 언어에 필요한 값을 더합니다. `~/.claude/skills/` 아래 스킬에 `references/metarche.md`가 있으면, Metarche는 질의응답(4단계)·문서·계획 단계에서 그 파일을 읽습니다. 없으면 Metarche만으로 그대로 진행합니다.

`references/metarche.md`에 담을 것:
1. 그 언어에 필요한 추가 질문
2. 검사 명령: 파일 단위(고친 파일 경로를 받음)와 작업 끝(프로젝트 전체)
3. CLAUDE.md에 넣을 줄
4. 계획 1번 작업(프로젝트 뼈대)과 확인 방법

예: Rust용 [Rustarche](https://github.com/metapbl/Rustarche).

## 구조
~~~
skill/
├─ SKILL.md            진입점: 철칙, 상태 판별, 단계 지도
├─ agents/openai.yaml  Codex: 직접 부를 때만 실행
└─ references/
   ├─ discover.md      0~5단계: 질의응답, PRD 확정·변경
   ├─ docs.md          6단계: 문서
   ├─ plan.md          7단계: 계획
   ├─ execute.md       8~9단계: 구현·개선, wrap
   ├─ audit.md         점검
   ├─ adopt.md         기존 프로젝트 이관
   ├─ agents.md        공통 핵심과 에이전트별 어댑터 (Claude Code, Codex, 그 밖)
   ├─ security.md      보안 정책 (수준·데이터 등급·신뢰 경계·암호화)
   ├─ upgrade.md       스킬 개정분을 기존 프로젝트에 반영 (개정 대장)
   ├─ readme.md        공개 저장소의 README 규격 (언어 줄, Shields.io 배지)
   └─ templates/       PRD·SECURITY_POLICY·QA_LOG·OPEN·DECISIONS·AGENTS·CLAUDE·PROGRESS·REFERENCE·profile, hooks/, claude/, codex/
~~~

## 출처
이 스킬이 참고한 프로젝트와 글은 [`NOTICE`](NOTICE)에 있습니다.

## 라이선스
MIT
