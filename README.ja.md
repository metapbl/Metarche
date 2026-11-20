<p align="center">
  <strong>Language:</strong>
  <a href="README.md">English</a> |
  <a href="README.ko.md">한국어</a> |
  <a href="README.zh-CN.md">简体中文</a> |
  <a href="README.ja.md">日本語</a> |
  <a href="README.es.md">Español</a> |
  <a href="README.ru.md">Русский</a>
</p>

<p align="center"><sub>この文書は英語版を AI で翻訳したものです。内容が異なる場合は英語版に従ってください。</sub></p>

# Metarche

<p align="center">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-blue?style=flat-square"></a>
  <a href="#インストール"><img alt="Agent Skill for Claude Code and Codex" src="https://img.shields.io/badge/Agent_Skill-Claude_Code_%7C_Codex-D97757?style=flat-square"></a>
  <a href="#必要環境"><img alt="Platform: Windows, macOS, Linux" src="https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-0078D4?style=flat-square"></a>
  <a href="#必要環境"><img alt="PowerShell 7" src="https://img.shields.io/badge/PowerShell-7-5391FE?style=flat-square"></a>
  <a href="https://github.com/metapbl/Metarche/actions/workflows/hooks.yml"><img alt="Hook tests" src="https://img.shields.io/github/actions/workflow/status/metapbl/Metarche/hooks.yml?branch=main&style=flat-square&label=hook%20tests"></a>
</p>

meta + archē：質疑応答で PRD・ドキュメント・計画を固め、承認ゲートを通して実装まで進めるエージェントスキル。

> [!NOTE]
> スキルの指示文は英語で書かれています。あなたとの会話とプロジェクトのドキュメント（PRD、CLAUDE.md、計画）には、あなたの言語を使います。

## できること
- 質疑応答で目的・範囲・機能・方式を決め、PRD の承認を求めます。
- セキュリティレベルとポリシー（データ分類、クライアントとサーバーの信頼境界、暗号化）を決め、PRD と一緒に承認を受けます。
- プロジェクトのドキュメント（AGENTS.md、PROGRESS、REFERENCE）を作り、エージェントごとにフックと権限を組み込みます。フックは編集時チェック、ターン終了時のプロジェクトチェック、PRD ゲート、進捗の注入です。Claude Code と Codex 用のアダプターがあり、その他のエージェントはフックなしで AGENTS.md に従います。
- 作業計画を立て、各ステップで承認を得ながら 実装 → 確認 → 記録 を繰り返します。
- すべての状態をファイルに置くので、`/clear` やコンテキスト圧縮のあとも続けられます。

## 必要環境
- Windows、macOS、Linux のいずれかと PowerShell 7（`pwsh`）。フックは PowerShell スクリプトで、3 つの OS すべてで[フックのテスト](tests/hooks.test.ps1)により確認しています。
- Agent Skills と AGENTS.md を読むコーディングエージェント：[Claude Code](https://code.claude.com/docs)（テスト済み）または [Codex](https://learn.chatgpt.com/docs/build-skills)（公式ドキュメントに沿ってアダプターを作成、実行は未確認）。その他のエージェントはフックなしで動作します。
- git（推奨）

## インストール
Windows（PowerShell 7）：
~~~
git clone https://github.com/metapbl/Metarche.git "$env:USERPROFILE\My Projects\metarche"
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\skills" | Out-Null
New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\skills\metarche" -Target "$env:USERPROFILE\My Projects\metarche\skill"
~~~
macOS / Linux（先に [PowerShell 7](https://learn.microsoft.com/powershell/scripting/install/installing-powershell) をインストール）：
~~~
git clone https://github.com/metapbl/Metarche.git ~/metarche
mkdir -p ~/.claude/skills && ln -s ~/metarche/skill ~/.claude/skills/metarche
~~~
Codex（同じフォルダーを `~/.agents/skills` の下にリンク）、Windows：
~~~
New-Item -ItemType Directory -Force "$env:USERPROFILE\.agents\skills" | Out-Null
New-Item -ItemType Junction -Path "$env:USERPROFILE\.agents\skills\metarche" -Target "$env:USERPROFILE\My Projects\metarche\skill"
~~~
macOS / Linux:
~~~
mkdir -p ~/.agents/skills && ln -s ~/metarche/skill ~/.agents/skills/metarche
~~~
Claude Code または Codex の `/skills` に `metarche` が表示されれば完了です。更新はリポジトリのフォルダーで `git pull` を実行します。

## クイックスタート
空のフォルダーでエージェントを起動し、スキルを呼び出します（Codex では `$metarche new`）。最初のセッションは次のように進み、metarche はあなたの言語で話します。
~~~
> /metarche new
[metarche] Empty folder, so mode new. Next: stage 0, then the first question on purpose. Go ahead?
> yes
What problem should this project solve, and how do you handle it today?
[metarche] stage 1 Purpose · 3 open · next: success scene, deadline
~~~
回答は `docs/discovery/QA_LOG.md` に、決定は `DECISIONS.md` に記録されます。ステップ 5 で `docs/PRD.md` と `docs/SECURITY_POLICY.md` を承認するまで、コードは書きません。

## 使い方
| コマンド | いつ使うか |
|---|---|
| `/metarche` | 引数なし：プロジェクトの状態を判定して適切な段階へ |
| `/metarche new` | 空のフォルダーで新しいプロジェクトを始める |
| `/metarche adopt` | 既存のプロジェクトをこの体系に移す |
| `/metarche discover` | 質疑応答を続ける、または承認済みの PRD やセキュリティポリシーを変更する |
| `/metarche docs` · `plan` · `build` | ドキュメント · 計画 · 実装 の段階 |
| `/metarche wrap` | セッションの締めくくり：PROGRESS を更新し、残りの変更をコミットし、push の前に確認 |
| `/metarche audit` | ドキュメント・セキュリティ・README の点検レポート |
| `/metarche upgrade` | スキルの改訂を既存プロジェクトのフック・設定・ドキュメントに反映 |
| `/metarche status` | 現在の段階と未解決の質問数だけを報告 |

このスキルは自動では呼び出されません（`disable-model-invocation: true`）。呼び出したときだけ動作します。Codex では `$metarche` で呼び出します（例：`$metarche new`）。`agents/openai.yaml` が Codex による自動呼び出しを止めます。

## 言語スキル
Metarche 自体は特定の言語に依存しません。言語スキルが、ある言語に必要な値を追加します。`~/.claude/skills/` 以下のスキルに `references/metarche.md` があれば、Metarche は質疑応答（ステップ 4）・ドキュメント・計画の段階でそれを読みます。なければ Metarche だけでそのまま進みます。

`references/metarche.md` に含めるもの：
1. その言語に必要な追加の質問
2. チェックコマンド：ファイル単位（編集したファイルのパスを受け取る）とターン終了時（プロジェクト全体）
3. CLAUDE.md に入れる行
4. 計画の最初のタスク（プロジェクトの骨組み）とその確認方法

例：Rust 用の [Rustarche](https://github.com/metapbl/Rustarche)。

## 構成
~~~
skill/
├─ SKILL.md            入口：原則、状態の判定、段階マップ
├─ agents/openai.yaml  Codex：呼び出したときだけ実行
└─ references/
   ├─ discover.md      ステップ 0–5：質疑応答、PRD の確定と変更
   ├─ docs.md          ステップ 6：ドキュメント
   ├─ plan.md          ステップ 7：計画
   ├─ execute.md       ステップ 8–9：実装と改善、wrap
   ├─ audit.md         点検
   ├─ adopt.md         既存プロジェクトの移行
   ├─ agents.md        共通の核とエージェント別アダプター（Claude Code、Codex、その他）
   ├─ security.md      セキュリティポリシー（レベル、データ分類、信頼境界、暗号化）
   ├─ upgrade.md       スキルの改訂を既存プロジェクトに反映（改訂台帳）
   ├─ readme.md        公開リポジトリの README 規格（言語行、Shields.io バッジ）
   └─ templates/       PRD・SECURITY_POLICY・QA_LOG・OPEN・DECISIONS・AGENTS・CLAUDE・PROGRESS・REFERENCE・profile、hooks/、claude/、codex/
~~~

## プロジェクトの状況
- 作者が複数のプロジェクトで使っています（Windows、Claude Code）。
- フックのテストは CI で Windows、macOS、Linux のすべてで通っています。
- Codex アダプターは Codex の公式ドキュメントに沿って作成しましたが、まだ Codex で実行していません。
- まだ変わり続けています。既存のプロジェクトは `/metarche upgrade` で追従します。

## サポートと貢献
- 質問とバグ報告：[GitHub Issues](https://github.com/metapbl/Metarche/issues)。
- Pull request：まず issue を開いて変更内容を相談してください。スキルの文章は英語で、個人のツール名を含めず、フックのテストを通してください：`pwsh -NoProfile -File tests/hooks.test.ps1`。

## セキュリティ
脆弱性は公開の issue ではなく、[GitHub の非公開脆弱性報告](https://github.com/metapbl/Metarche/security/advisories/new)で報告してください。

## クレジット
このスキルが参考にしたプロジェクトと記事は [`NOTICE`](NOTICE) にあります。

## ライセンス
MIT
