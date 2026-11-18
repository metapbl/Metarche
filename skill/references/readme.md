# README 규격 (readme)

PRD §5에서 공개 저장소로 정한 프로젝트만 해당한다. plan 단계에서 인수 확인 바로 앞에 "README 갱신" 작업을 두고 이 규격대로 쓴다.
근거: Standard Readme 명세, GitHub "About READMEs", Shields.io 문서. 로고·배지 줄 수·꾸밈은 규격이 없으므로 프로젝트가 정한다.

## §1 파일과 언어
- 기본 `README.md`는 영어로 쓴다. 번역본은 루트에 `README.{언어 태그}.md`로 둔다.
- 언어 목록은 PRD §5에 적는다. 추천값과 순서:

| 순서 | 언어 줄 표기 | 파일 |
|---|---|---|
| 1 | English | `README.md` |
| 2 | 한국어 | `README.ko.md` |
| 3 | 简体中文 | `README.zh-CN.md` |
| 4 | 日本語 | `README.ja.md` |
| 5 | Español | `README.es.md` |
| 6 | Русский | `README.ru.md` |

- 한 언어로만 쓰기로 했으면 언어 줄과 번역 안내 문장은 두지 않는다.
- README를 고치면 모든 번역본을 같은 커밋에서 함께 고친다. 번역본은 영어판과 절 구성·배지가 같아야 한다.

## §2 맨 위 (모든 파일에 같은 형식)
1. 언어 줄 — 가운데 정렬, 상대 링크, 언어 이름은 그 언어로 쓴다. 국기 이모지는 쓰지 않는다 (Windows에서 글자로 보인다).
   ~~~
   <p align="center">
     <strong>Language:</strong>
     <a href="README.md">English</a> |
     <a href="README.ko.md">한국어</a> |
     <a href="README.zh-CN.md">简体中文</a> |
     <a href="README.ja.md">日本語</a> |
     <a href="README.es.md">Español</a> |
     <a href="README.ru.md">Русский</a>
   </p>
   ~~~
2. 번역본이면 언어 줄 아래에 그 언어로 한 줄: "이 문서는 영어판을 AI로 번역한 것입니다. 내용이 다르면 영어판을 따릅니다." (§5에 언어별 문장)
3. 제목 — 저장소 이름과 같게 한다.
4. 배지 (§3).
5. 한 줄 소개 — 120자 미만. GitHub 저장소 설명(About)과 같은 문장으로 둔다.

## §3 Shields.io 배지
- 가운데 정렬한 줄에 둔다. 한 줄 안에서는 `style`을 하나로 통일한다 (추천: `flat-square`).
- 기본 구성은 PRD에서 가져온다: 버전, 라이선스, 주 언어·런타임, 지원 OS. 몇 줄로 나눌지와 더할 배지는 프로젝트가 정한다.
- 정적 배지 문법: `https://img.shields.io/badge/{라벨}-{메시지}-{색}?style=flat-square&logo={simple-icons 이름}` (공백은 `_`, `-`는 `--`).
- 배지마다 갈 곳을 링크하고 대체 글(alt)을 단다: 버전 → 릴리스 페이지, 라이선스 → `LICENSE`, OS → README 안의 해당 절.
  ~~~
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-blue?style=flat-square"></a>
  ~~~
- stars·다운로드·릴리스 같은 동적 배지는 공개 저장소에서만 쓴다 (비공개면 "repo not found"로 보인다).

## §4 본문
- 담을 것 (GitHub 권장): 무엇을 하는가(PRD §1) · 왜 쓰는가 · 설치와 사용(CLAUDE.md 명령, 실제로 실행되는 것만, 코드 블록) · 도움받을 곳 · 유지보수자와 라이선스.
- 저장소 안 파일은 상대 링크로 건다. 깨진 링크를 남기지 않는다.
- 라이선스 절은 맨 끝에 두고 SPDX 식별자로 적는다 (예: `MIT`, `LGPL-2.1-or-later`).
- 넣지 않는다: 비밀값, 실제 IP·호스트 이름·기기 이름, 개인정보, 내부 경로 (docs/SECURITY_POLICY.md 3·7절).

## §5 번역 안내 문장
| 파일 | 문장 |
|---|---|
| `README.ko.md` | 이 문서는 영어판을 AI로 번역한 것입니다. 내용이 다르면 영어판을 따릅니다. |
| `README.zh-CN.md` | 本文档由 AI 从英文版翻译而来。如有出入，以英文版为准。 |
| `README.ja.md` | この文書は英語版を AI で翻訳したものです。内容が異なる場合は英語版に従ってください。 |
| `README.es.md` | Este documento es una traducción automática con IA de la versión en inglés. Si hay diferencias, prevalece la versión en inglés. |
| `README.ru.md` | Этот документ переведён с английской версии с помощью ИИ. При расхождениях ориентируйтесь на английскую версию. |

## §6 확인 (README 갱신 작업과 audit 16번)
- 언어 줄의 파일이 모두 있고, 번역본마다 `##` 제목 수와 배지 수가 영어판과 같다.
- 설치·사용 명령을 실제로 실행해 본다 (위험한 명령은 존재만 확인).
- 상대 링크가 가리키는 파일이 모두 있다.
- 배지 이미지를 열어 본다. `logo=`를 준 배지는 로고가 실제로 보이는지 확인한다 (아이콘이 목록에서 빠지면 소리 없이 사라진다).
- 문서 안 링크(`#제목`)는 번역본마다 그 언어의 제목으로 바꾼다.
- §4 금지 정보를 검색해 없음을 보인다.
