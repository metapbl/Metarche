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
  <a href="#インストール"><img alt="Claude Code skill" src="https://img.shields.io/badge/Claude_Code-skill-D97757?style=flat-square&logo=claude&logoColor=white"></a>
  <a href="#必要環境"><img alt="Platform: Windows" src="https://img.shields.io/badge/platform-Windows-0078D4?style=flat-square"></a>
  <a href="#必要環境"><img alt="PowerShell 7" src="https://img.shields.io/badge/PowerShell-7-5391FE?style=flat-square"></a>
</p>

meta + archē：質疑応答で PRD・ドキュメント・計画を固め、承認ゲートを通して実装まで進める Claude Code スキル。

> [!NOTE]
> スキルの指示文とドキュメントのテンプレートは韓国語で書かれているため、このスキルが作るドキュメント（PRD、CLAUDE.md、計画）も韓国語になります。

## できること
- 質疑応答で目的・範囲・機能・方式を決め、PRD の承認を求めます。
- セキュリティレベルとポリシー（データ分類、クライアントとサーバーの信頼境界、暗号化）を決め、PRD と一緒に承認を受けます。
- Claude Code に必要なドキュメント（CLAUDE.md、PROGRESS、REFERENCE）と権限ルール・フックを作ります。フックは編集時チェック、ターン終了時のプロジェクトチェック、PRD ゲート、進捗の注入です。
- 作業計画を立て、各ステップで承認を得ながら 実装 → 確認 → 記録 を繰り返します。
- すべての状態をファイルに置くので、`/clear` やコンテキスト圧縮のあとも続けられます。

## 必要環境
- Windows と PowerShell 7（`pwsh`）。フックは PowerShell スクリプトです。
- [Claude Code](https://code.claude.com/docs)
- git（推奨）

## インストール
~~~
git clone https://github.com/metapbl/Metarche.git "$env:USERPROFILE\My Projects\metarche"
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\skills" | Out-Null
New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\skills\metarche" -Target "$env:USERPROFILE\My Projects\metarche\skill"
~~~
Claude Code の `/skills` に `metarche` が表示されれば完了です。更新はリポジトリのフォルダーで `git pull` を実行します。

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

このスキルは自動では呼び出されません（`disable-model-invocation: true`）。呼び出したときだけ動作します。

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
└─ references/
   ├─ discover.md      ステップ 0–5：質疑応答、PRD の確定と変更
   ├─ docs.md          ステップ 6：ドキュメント
   ├─ plan.md          ステップ 7：計画
   ├─ execute.md       ステップ 8–9：実装と改善、wrap
   ├─ audit.md         点検
   ├─ adopt.md         既存プロジェクトの移行
   ├─ security.md      セキュリティポリシー（レベル、データ分類、信頼境界、暗号化）
   ├─ upgrade.md       スキルの改訂を既存プロジェクトに反映（改訂台帳）
   ├─ readme.md        公開リポジトリの README 規格（言語行、Shields.io バッジ）
   └─ templates/       PRD・SECURITY_POLICY・QA_LOG・OPEN・DECISIONS・CLAUDE・PROGRESS・REFERENCE・profile、settings.json、hooks/
~~~

## クレジット
このスキルが参考にしたプロジェクトと記事は [`NOTICE`](NOTICE) にあります。

## ライセンス
MIT
