# readme — README standard

Only for projects that PRD §5 marks as a public repository. In the plan stage, put a "README update" task right before acceptance and write it to this standard.
Sources: the Standard Readme spec, GitHub "About READMEs", the Shields.io docs. Logos, the number of badge rows and decoration have no standard, so the project decides.
The README languages are set by the project (PRD §5), independent of the language the documents are written in.

## §1 Files and languages
- The default `README.md` is in English. Translations live in the root as `README.{language tag}.md`.
- Record the language list in PRD §5. Recommended set and order:

| Order | Shown in the language line as | File |
|---|---|---|
| 1 | English | `README.md` |
| 2 | 한국어 | `README.ko.md` |
| 3 | 简体中文 | `README.zh-CN.md` |
| 4 | 日本語 | `README.ja.md` |
| 5 | Español | `README.es.md` |
| 6 | Русский | `README.ru.md` |

- If only one language is used, there is no language line and no translation notice.
- When the README changes, change every translation in the same commit. Translations match the English version in sections and badges.

## §2 The top (same shape in every file)
1. Language line — centered, relative links, each language named in that language. No flag emoji (Windows shows them as letters).
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
2. In a translation, one line under the language line, in that language, saying it is an AI translation of the English version and the English version prevails (sentences per language in §5).
3. Title — the same as the repository name.
4. Badges (§3).
5. One-line description — under 120 characters, the same sentence as the GitHub repository description (About).

## §3 Shields.io badges
- Put them on a centered line. Use one `style` per line (recommended: `flat-square`).
- Take the default set from the PRD: version, license, main language or runtime, supported OS. How many lines and which extra badges is the project's choice.
- Static badge syntax: `https://img.shields.io/badge/{label}-{message}-{color}?style=flat-square&logo={simple-icons name}` (space is `_`, `-` is `--`).
- Link every badge to where it belongs and give it alt text: version → releases page, license → `LICENSE`, OS → the matching README section.
  ~~~
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-blue?style=flat-square"></a>
  ~~~
- Dynamic badges such as stars, downloads and releases only for public repositories (a private one shows "repo not found").

## §4 Body
- Contents (GitHub's recommendation): what it does (PRD §1) · why it is useful · install and usage (CLAUDE.md commands, only ones that actually run, in code blocks) · where to get help · maintainers and license.
- Link files inside the repository with relative links. Leave no broken links.
- Put the license section last and give it as an SPDX identifier (e.g. `MIT`, `LGPL-2.1-or-later`).
- Never include: secrets, real IP addresses, host or device names, personal data, internal paths (docs/SECURITY_POLICY.md §3 and §7).

## §5 Translation notice sentences
| File | Sentence |
|---|---|
| `README.ko.md` | 이 문서는 영어판을 AI로 번역한 것입니다. 내용이 다르면 영어판을 따릅니다. |
| `README.zh-CN.md` | 本文档由 AI 从英文版翻译而来。如有出入，以英文版为准。 |
| `README.ja.md` | この文書は英語版を AI で翻訳したものです。内容が異なる場合は英語版に従ってください。 |
| `README.es.md` | Este documento es una traducción automática con IA de la versión en inglés. Si hay diferencias, prevalece la versión en inglés. |
| `README.ru.md` | Этот документ переведён с английской версии с помощью ИИ. При расхождениях ориентируйтесь на английскую версию. |

## §6 Checks (the README update task and audit item 16)
- Every file in the language line exists, and each translation has as many `##` headings and badges as the English version.
- Actually run the install and usage commands (dangerous commands: check they exist only).
- Every file a relative link points to exists.
- Open the badge images. For badges with `logo=`, confirm the logo actually shows (an icon dropped from the set disappears silently).
- In-page links (`#heading`) use each translation's own headings.
- Search for the §4 forbidden information and show there is none.
