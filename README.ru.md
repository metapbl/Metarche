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
  <a href="#установка"><img alt="Claude Code skill" src="https://img.shields.io/badge/Claude_Code-skill-D97757?style=flat-square&logo=claude&logoColor=white"></a>
  <a href="#требования"><img alt="Platform: Windows, macOS, Linux" src="https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-0078D4?style=flat-square"></a>
  <a href="#требования"><img alt="PowerShell 7" src="https://img.shields.io/badge/PowerShell-7-5391FE?style=flat-square"></a>
  <a href="https://github.com/metapbl/Metarche/actions/workflows/hooks.yml"><img alt="Hook tests" src="https://img.shields.io/github/actions/workflow/status/metapbl/Metarche/hooks.yml?branch=main&style=flat-square&label=hook%20tests"></a>
</p>

meta + archē: навык Claude Code, который превращает интервью в формате вопросов и ответов в PRD, документацию и план, а затем ведёт реализацию через этапы одобрения.

> [!NOTE]
> Инструкции навыка и шаблоны документов написаны на корейском языке, поэтому документы, которые он создаёт (PRD, CLAUDE.md, планы), тоже будут на корейском.

## Что делает
- Через интервью определяет цель, объём, функции и подход, затем просит вас одобрить PRD.
- Задаёт уровень и политику безопасности (классы данных, границы доверия между клиентом и сервером, шифрование) и утверждает их вместе с PRD.
- Создаёт документы, нужные Claude Code (CLAUDE.md, PROGRESS, REFERENCE), а также правила разрешений и хуки: проверку при редактировании, проверку проекта в конце хода, шлюз PRD и подстановку прогресса.
- Составляет план задач и повторяет цикл реализация → проверка → запись с одобрением на каждом шаге.
- Хранит всё состояние в файлах, поэтому работа продолжается после `/clear` и сжатия контекста.

## Требования
- Windows, macOS или Linux с PowerShell 7 (`pwsh`). Хуки — это скрипты PowerShell; они проверяются на всех трёх системах [тестами хуков](tests/hooks.test.ps1).
- [Claude Code](https://code.claude.com/docs)
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
Готово, когда `metarche` появится в `/skills` в Claude Code. Для обновления выполните `git pull` в папке репозитория.

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

Навык никогда не вызывается автоматически (`disable-model-invocation: true`). Он работает, только когда вы его вызываете.

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
└─ references/
   ├─ discover.md      шаги 0–5: интервью, утверждение и изменение PRD
   ├─ docs.md          шаг 6: документация
   ├─ plan.md          шаг 7: план
   ├─ execute.md       шаги 8–9: реализация и улучшения, wrap
   ├─ audit.md         аудит
   ├─ adopt.md         перевод существующего проекта
   ├─ security.md      политика безопасности (уровень, классы данных, границы доверия, шифрование)
   ├─ upgrade.md       применение изменений навыка к существующим проектам (журнал изменений)
   ├─ readme.md        стандарт README для публичных репозиториев (строка языков, значки Shields.io)
   └─ templates/       PRD, SECURITY_POLICY, QA_LOG, OPEN, DECISIONS, CLAUDE, PROGRESS, REFERENCE, profile, settings.json, hooks/
~~~

## Благодарности
Проекты и статьи, на которые опирается этот навык, перечислены в [`NOTICE`](NOTICE).

## Лицензия
MIT
