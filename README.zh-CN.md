<p align="center">
  <strong>Language:</strong>
  <a href="README.md">English</a> |
  <a href="README.ko.md">한국어</a> |
  <a href="README.zh-CN.md">简体中文</a> |
  <a href="README.ja.md">日本語</a> |
  <a href="README.es.md">Español</a> |
  <a href="README.ru.md">Русский</a>
</p>

<p align="center"><sub>本文档由 AI 从英文版翻译而来。如有出入，以英文版为准。</sub></p>

# Metarche

<p align="center">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-blue?style=flat-square"></a>
  <a href="#安装"><img alt="Agent Skill for Claude Code and Codex" src="https://img.shields.io/badge/Agent_Skill-Claude_Code_%7C_Codex-D97757?style=flat-square"></a>
  <a href="#环境要求"><img alt="Platform: Windows, macOS, Linux" src="https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-0078D4?style=flat-square"></a>
  <a href="#环境要求"><img alt="PowerShell 7" src="https://img.shields.io/badge/PowerShell-7-5391FE?style=flat-square"></a>
  <a href="https://github.com/metapbl/Metarche/actions/workflows/hooks.yml"><img alt="Hook tests" src="https://img.shields.io/github/actions/workflow/status/metapbl/Metarche/hooks.yml?branch=main&style=flat-square&label=hook%20tests"></a>
</p>

meta + archē：通过问答确定 PRD、文档和计划，再经过审批关卡完成实现的智能体技能。

> [!NOTE]
> 本技能的指令以英语编写。它会用你的语言与你交流，并用你的语言编写项目文档（PRD、CLAUDE.md、计划）。

## 功能
- 通过问答确定目的、范围、功能和实现方式，然后请你批准 PRD。
- 确定安全级别和安全策略（数据分级、客户端与服务器的信任边界、加密），与 PRD 一同批准。
- 生成项目文档（AGENTS.md、PROGRESS、REFERENCE），并为每个智能体接入钩子和权限：编辑时检查、回合结束时的项目检查、PRD 关卡、进度注入。提供 Claude Code 和 Codex 的适配器；其他智能体不使用钩子，按 AGENTS.md 执行。
- 制定任务计划，然后在每一步审批后循环执行 实现 → 验证 → 记录。
- 所有状态都保存在文件中，因此在 `/clear` 和上下文压缩之后也能继续。

## 环境要求
- Windows、macOS 或 Linux，以及 PowerShell 7（`pwsh`）。钩子是 PowerShell 脚本，并通过[钩子测试](tests/hooks.test.ps1)在这三个系统上验证。
- 能读取 Agent Skills 和 AGENTS.md 的编程智能体：[Claude Code](https://code.claude.com/docs)（已测试）或 [Codex](https://learn.chatgpt.com/docs/build-skills)（按官方文档编写了适配器，尚未实际运行）。其他智能体在没有钩子的情况下运行。
- git（推荐）

## 安装
Windows（PowerShell 7）：
~~~
git clone https://github.com/metapbl/Metarche.git "$env:USERPROFILE\My Projects\metarche"
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\skills" | Out-Null
New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\skills\metarche" -Target "$env:USERPROFILE\My Projects\metarche\skill"
~~~
macOS / Linux（请先安装 [PowerShell 7](https://learn.microsoft.com/powershell/scripting/install/installing-powershell)）：
~~~
git clone https://github.com/metapbl/Metarche.git ~/metarche
mkdir -p ~/.claude/skills && ln -s ~/metarche/skill ~/.claude/skills/metarche
~~~
Codex（把同一文件夹链接到 `~/.agents/skills` 下），Windows：
~~~
New-Item -ItemType Directory -Force "$env:USERPROFILE\.agents\skills" | Out-Null
New-Item -ItemType Junction -Path "$env:USERPROFILE\.agents\skills\metarche" -Target "$env:USERPROFILE\My Projects\metarche\skill"
~~~
macOS / Linux:
~~~
mkdir -p ~/.agents/skills && ln -s ~/metarche/skill ~/.agents/skills/metarche
~~~
在 Claude Code 或 Codex 的 `/skills` 中看到 `metarche` 即安装完成。更新时在仓库文件夹中运行 `git pull`。

## 使用
| 命令 | 何时使用 |
|---|---|
| `/metarche` | 不带参数：判断项目状态并进入相应阶段 |
| `/metarche new` | 在空文件夹中开始新项目 |
| `/metarche adopt` | 将现有项目迁入本流程 |
| `/metarche discover` | 继续问答，或修改已批准的 PRD 或安全策略 |
| `/metarche docs` · `plan` · `build` | 文档 · 计划 · 实现 阶段 |
| `/metarche wrap` | 结束会话：更新 PROGRESS，提交剩余改动，推送前先询问 |
| `/metarche audit` | 文档、安全和 README 的检查报告 |
| `/metarche upgrade` | 把技能的修订应用到现有项目的钩子、设置和文档 |
| `/metarche status` | 只报告当前阶段和未决问题数 |

本技能不会被自动调用（`disable-model-invocation: true`），只有你主动调用时才运行。在 Codex 中用 `$metarche` 调用（例如 `$metarche new`）；`agents/openai.yaml` 防止 Codex 自行调用。

## 语言技能
Metarche 本身与编程语言无关。语言技能为某一种语言补充所需的值。如果 `~/.claude/skills/` 下的某个技能包含 `references/metarche.md`，Metarche 会在问答（第 4 步）、文档和计划阶段读取它；没有时 Metarche 照常运行。

`references/metarche.md` 应包含：
1. 该语言需要的额外问题
2. 检查命令：按文件（接收被编辑文件的路径）和回合结束时（整个项目）
3. 要写入 CLAUDE.md 的内容
4. 计划的第一个任务（项目骨架）及其验证方法

示例：用于 Rust 的 [Rustarche](https://github.com/metapbl/Rustarche)。

## 结构
~~~
skill/
├─ SKILL.md            入口：规则、状态判断、阶段图
├─ agents/openai.yaml  Codex：仅在调用时运行
└─ references/
   ├─ discover.md      第 0–5 步：问答，PRD 批准与变更
   ├─ docs.md          第 6 步：文档
   ├─ plan.md          第 7 步：计划
   ├─ execute.md       第 8–9 步：实现与改进，wrap
   ├─ audit.md         检查
   ├─ adopt.md         迁入现有项目
   ├─ agents.md        通用核心与各智能体适配器（Claude Code、Codex、其他）
   ├─ security.md      安全策略（级别、数据分级、信任边界、加密）
   ├─ upgrade.md       把技能修订应用到现有项目（修订台账）
   ├─ readme.md        公开仓库的 README 规范（语言行、Shields.io 徽章）
   └─ templates/       PRD、SECURITY_POLICY、QA_LOG、OPEN、DECISIONS、AGENTS、CLAUDE、PROGRESS、REFERENCE、profile、hooks/、claude/、codex/
~~~

## 致谢
本技能参考的项目和文章列在 [`NOTICE`](NOTICE) 中。

## 许可证
MIT
