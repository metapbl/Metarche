<p align="center">
  <strong>Language:</strong>
  <a href="README.md">English</a> |
  <a href="README.ko.md">한국어</a> |
  <a href="README.zh-CN.md">简体中文</a> |
  <a href="README.ja.md">日本語</a> |
  <a href="README.es.md">Español</a> |
  <a href="README.ru.md">Русский</a>
</p>

<p align="center"><sub>Этот документ переведён с английской версии с помощью ИИ. При расхождениях ориентируйтесь на английскую версию.</sub></p>

# Metarche

<p align="center">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-blue?style=flat-square"></a>
  <a href="#установка"><img alt="Agent Skill for Claude Code and Codex" src="https://img.shields.io/badge/Agent_Skill-Claude_Code_%7C_Codex-D97757?style=flat-square"></a>
  <a href="#требования"><img alt="Platform: Windows, macOS, Linux" src="https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-0078D4?style=flat-square"></a>
  <a href="#требования"><img alt="PowerShell 7" src="https://img.shields.io/badge/PowerShell-7-5391FE?style=flat-square"></a>
  <a href="https://github.com/metapbl/Metarche/actions/workflows/hooks.yml"><img alt="Hook tests" src="https://img.shields.io/github/actions/workflow/status/metapbl/Metarche/hooks.yml?branch=main&style=flat-square&label=hook%20tests"></a>
</p>

meta + archē: навык для агентов, который превращает интервью в формате вопросов и ответов в PRD, документацию и план, а затем ведёт реализацию через этапы одобрения.

> [!NOTE]
> Инструкции навыка написаны на английском. Он общается с вами и пишет документы проекта (PRD, CLAUDE.md, планы) на вашем языке.

## Что делает
- Через интервью определяет цель, объём, функции и подход, затем просит вас одобрить PRD.
- Задаёт уровень и политику безопасности (классы данных, границы доверия между клиентом и сервером, шифрование) и утверждает их вместе с PRD.
- Создаёт документы проекта (AGENTS.md, PROGRESS, REFERENCE) и подключает хуки и разрешения для каждого агента: проверку при редактировании, проверку проекта в конце хода, шлюз PRD и подстановку прогресса. Есть адаптеры для Claude Code и Codex; другие агенты следуют AGENTS.md без хуков.
- Составляет план задач и повторяет цикл реализация → проверка → запись с одобрением на каждом шаге.
- Хранит всё состояние в файлах, поэтому работа продолжается после `/clear` и сжатия контекста.

## Требования
- Windows, macOS или Linux с PowerShell 7 (`pwsh`). Хуки — это скрипты PowerShell; они проверяются на всех трёх системах [тестами хуков](tests/hooks.test.ps1).
- Агент для программирования, который читает Agent Skills и AGENTS.md: [Claude Code](https://code.claude.com/docs) (проверено) или [Codex](https://learn.chatgpt.com/docs/build-skills) (адаптер написан по документации, ещё не запускался). Другие агенты работают без хуков.
- git (рекомендуется)

## Установка
Windows (PowerShell 7):
~~~
git clone https://github.com/metapbl/Metarche.git "$env:USERPROFILE\My Projects\metarche"
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\skills" | Out-Null
New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\skills\metarche" -Target "$env:USERPROFILE\My Projects\metarche\skill"
~~~
macOS / Linux (сначала установите [PowerShell 7](https://learn.microsoft.com/powershell/scripting/install/installing-powershell)):
~~~
git clone https://github.com/metapbl/Metarche.git ~/metarche
mkdir -p ~/.claude/skills && ln -s ~/metarche/skill ~/.claude/skills/metarche
~~~
Codex (та же папка в `~/.agents/skills`), Windows:
~~~
New-Item -ItemType Directory -Force "$env:USERPROFILE\.agents\skills" | Out-Null
New-Item -ItemType Junction -Path "$env:USERPROFILE\.agents\skills\metarche" -Target "$env:USERPROFILE\My Projects\metarche\skill"
~~~
macOS / Linux:
~~~
mkdir -p ~/.agents/skills && ln -s ~/metarche/skill ~/.agents/skills/metarche
~~~
Готово, когда `metarche` появится в `/skills` в Claude Code или Codex. Для обновления выполните `git pull` в папке репозитория.

## Быстрый старт
В пустой папке запустите агента и вызовите навык (`$metarche new` в Codex). Первая сессия выглядит так; metarche общается на вашем языке.
~~~
> /metarche new
[metarche] Empty folder, so mode new. Next: stage 0, then the first question on purpose. Go ahead?
> yes
What problem should this project solve, and how do you handle it today?
[metarche] stage 1 Purpose · 3 open · next: success scene, deadline
~~~
Ответы записываются в `docs/discovery/QA_LOG.md`, решения — в `DECISIONS.md`. Пока на шаге 5 вы не утвердите `docs/PRD.md` и `docs/SECURITY_POLICY.md`, код не пишется.

## Использование
| Команда | Когда |
|---|---|
| `/metarche` | Без аргумента: определяет состояние проекта и переходит к нужному этапу |
| `/metarche new` | Начать новый проект в пустой папке |
| `/metarche adopt` | Перевести существующий проект на этот процесс |
| `/metarche discover` | Продолжить интервью или изменить одобренный PRD или политику безопасности |
| `/metarche docs` · `plan` · `build` | Этапы документации · плана · реализации |
| `/metarche wrap` | Завершить сессию: обновить PROGRESS, закоммитить оставшиеся изменения, спросить перед push |
| `/metarche audit` | Отчёт по документации, безопасности и README |
| `/metarche upgrade` | Применить изменения навыка к хукам, настройкам и документам существующего проекта |
| `/metarche status` | Сообщить только текущий этап и число открытых вопросов |

Навык никогда не вызывается автоматически (`disable-model-invocation: true`). Он работает, только когда вы его вызываете. В Codex навык вызывается как `$metarche` (например, `$metarche new`); `agents/openai.yaml` не даёт Codex загружать его самостоятельно.

## Языковые навыки
Сам Metarche не привязан к языку программирования. Языковой навык добавляет значения для конкретного языка. Если у навыка в `~/.claude/skills/` есть `references/metarche.md`, Metarche читает его на этапах интервью (шаг 4), документации и плана. Без него Metarche работает как обычно.

В `references/metarche.md` должны быть:
1. Дополнительные вопросы для этого языка
2. Команды проверки: для файла (получает путь к изменённому файлу) и в конце хода (весь проект)
3. Строки для CLAUDE.md
4. Первая задача плана (каркас проекта) и способ её проверки

Пример: [Rustarche](https://github.com/metapbl/Rustarche) для Rust.

## Структура
~~~
skill/
├─ SKILL.md            точка входа: правила, определение состояния, карта этапов
├─ agents/openai.yaml  Codex: запуск только по вызову
└─ references/
   ├─ discover.md      шаги 0–5: интервью, утверждение и изменение PRD
   ├─ docs.md          шаг 6: документация
   ├─ plan.md          шаг 7: план
   ├─ execute.md       шаги 8–9: реализация и улучшения, wrap
   ├─ audit.md         аудит
   ├─ adopt.md         перевод существующего проекта
   ├─ agents.md        общее ядро и адаптеры для агентов (Claude Code, Codex, другие)
   ├─ security.md      политика безопасности (уровень, классы данных, границы доверия, шифрование)
   ├─ upgrade.md       применение изменений навыка к существующим проектам (журнал изменений)
   ├─ readme.md        стандарт README для публичных репозиториев (строка языков, значки Shields.io)
   └─ templates/       PRD, SECURITY_POLICY, QA_LOG, OPEN, DECISIONS, AGENTS, CLAUDE, PROGRESS, REFERENCE, profile, hooks/, claude/, codex/
~~~

## Состояние проекта
- Автор использует навык в нескольких проектах (Windows, Claude Code).
- Тесты хуков проходят в CI на Windows, macOS и Linux.
- Адаптер для Codex написан по документации Codex, но в Codex ещё не запускался.
- Навык ещё меняется. Существующие проекты догоняют изменения через `/metarche upgrade`.

## Помощь и участие
- Вопросы и сообщения об ошибках: [GitHub Issues](https://github.com/metapbl/Metarche/issues).
- Pull request: сначала откройте issue и согласуйте изменение. Текст навыка — на английском и без названий личных инструментов; тесты хуков должны проходить: `pwsh -NoProfile -File tests/hooks.test.ps1`.

## Безопасность
Сообщайте об уязвимостях приватно через [приватные отчёты об уязвимостях GitHub](https://github.com/metapbl/Metarche/security/advisories/new), а не в публичном issue.

## Благодарности
Проекты и статьи, на которые опирается этот навык, перечислены в [`NOTICE`](NOTICE).

## Лицензия
MIT
