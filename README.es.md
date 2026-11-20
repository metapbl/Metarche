<p align="center">
  <strong>Language:</strong>
  <a href="README.md">English</a> |
  <a href="README.ko.md">한국어</a> |
  <a href="README.zh-CN.md">简体中文</a> |
  <a href="README.ja.md">日本語</a> |
  <a href="README.es.md">Español</a> |
  <a href="README.ru.md">Русский</a>
</p>

<p align="center"><sub>Este documento es una traducción automática con IA de la versión en inglés. Si hay diferencias, prevalece la versión en inglés.</sub></p>

# Metarche

<p align="center">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-blue?style=flat-square"></a>
  <a href="#instalación"><img alt="Agent Skill for Claude Code and Codex" src="https://img.shields.io/badge/Agent_Skill-Claude_Code_%7C_Codex-D97757?style=flat-square"></a>
  <a href="#requisitos"><img alt="Platform: Windows, macOS, Linux" src="https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-0078D4?style=flat-square"></a>
  <a href="#requisitos"><img alt="PowerShell 7" src="https://img.shields.io/badge/PowerShell-7-5391FE?style=flat-square"></a>
  <a href="https://github.com/metapbl/Metarche/actions/workflows/hooks.yml"><img alt="Hook tests" src="https://img.shields.io/github/actions/workflow/status/metapbl/Metarche/hooks.yml?branch=main&style=flat-square&label=hook%20tests"></a>
</p>

meta + archē: una skill de agente que convierte una entrevista de preguntas y respuestas en un PRD, documentos y un plan, y luego construye con puertas de aprobación.

> [!NOTE]
> Las instrucciones de la skill están en inglés. Habla contigo y escribe los documentos del proyecto (PRD, CLAUDE.md, planes) en tu idioma.

## Qué hace
- Define el propósito, el alcance, las funciones y el enfoque mediante una entrevista y luego te pide aprobar un PRD.
- Fija un nivel y una política de seguridad (clases de datos, límites de confianza entre cliente y servidor, cifrado) y los aprueba junto con el PRD.
- Crea los documentos del proyecto (AGENTS.md, PROGRESS, REFERENCE) y conecta hooks y permisos en cada agente: comprobación al editar, comprobación del proyecto al final de cada turno, puerta del PRD e inyección del progreso. Hay adaptadores para Claude Code y Codex; otros agentes siguen AGENTS.md sin hooks.
- Escribe un plan de tareas y repite implementar → verificar → registrar, con una aprobación en cada paso.
- Guarda todo el estado en archivos, así el trabajo continúa después de `/clear` y de la compactación del contexto.

## Requisitos
- Windows, macOS o Linux con PowerShell 7 (`pwsh`). Los hooks son scripts de PowerShell y se comprueban en los tres sistemas con [pruebas de hooks](tests/hooks.test.ps1).
- Un agente de programación que lea Agent Skills y AGENTS.md: [Claude Code](https://code.claude.com/docs) (probado) o [Codex](https://learn.chatgpt.com/docs/build-skills) (adaptador escrito según su documentación, aún sin ejecutar). Otros agentes funcionan sin hooks.
- git (recomendado)

## Instalación
Windows (PowerShell 7):
~~~
git clone https://github.com/metapbl/Metarche.git "$env:USERPROFILE\My Projects\metarche"
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\skills" | Out-Null
New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\skills\metarche" -Target "$env:USERPROFILE\My Projects\metarche\skill"
~~~
macOS / Linux (instala antes [PowerShell 7](https://learn.microsoft.com/powershell/scripting/install/installing-powershell)):
~~~
git clone https://github.com/metapbl/Metarche.git ~/metarche
mkdir -p ~/.claude/skills && ln -s ~/metarche/skill ~/.claude/skills/metarche
~~~
Codex (la misma carpeta bajo `~/.agents/skills`), Windows:
~~~
New-Item -ItemType Directory -Force "$env:USERPROFILE\.agents\skills" | Out-Null
New-Item -ItemType Junction -Path "$env:USERPROFILE\.agents\skills\metarche" -Target "$env:USERPROFILE\My Projects\metarche\skill"
~~~
macOS / Linux:
~~~
mkdir -p ~/.agents/skills && ln -s ~/metarche/skill ~/.agents/skills/metarche
~~~
Está listo cuando `metarche` aparece en `/skills` dentro de Claude Code o Codex. Para actualizar, ejecuta `git pull` en la carpeta del repositorio.

## Inicio rápido
En una carpeta vacía, inicia tu agente y llama a la skill (`$metarche new` en Codex). Una primera sesión se ve así; metarche habla en tu idioma.
~~~
> /metarche new
[metarche] Empty folder, so mode new. Next: stage 0, then the first question on purpose. Go ahead?
> yes
What problem should this project solve, and how do you handle it today?
[metarche] stage 1 Purpose · 3 open · next: success scene, deadline
~~~
Las respuestas van a `docs/discovery/QA_LOG.md` y las decisiones a `DECISIONS.md`. Hasta que apruebes `docs/PRD.md` y `docs/SECURITY_POLICY.md` en el paso 5, no se escribe código.

## Uso
| Comando | Cuándo |
|---|---|
| `/metarche` | Sin argumento: detecta el estado del proyecto y va a la etapa adecuada |
| `/metarche new` | Empezar un proyecto nuevo en una carpeta vacía |
| `/metarche adopt` | Incorporar un proyecto existente a este flujo |
| `/metarche discover` | Continuar la entrevista, o cambiar un PRD o una política de seguridad aprobados |
| `/metarche docs` · `plan` · `build` | Etapas de documentos · plan · implementación |
| `/metarche wrap` | Cerrar la sesión: actualiza PROGRESS, hace commit de lo pendiente y pregunta antes de hacer push |
| `/metarche audit` | Informe sobre documentos, seguridad y README |
| `/metarche upgrade` | Aplica las revisiones de la skill a los hooks, ajustes y documentos de un proyecto existente |
| `/metarche status` | Solo informa la etapa actual y las preguntas abiertas |

La skill nunca se invoca automáticamente (`disable-model-invocation: true`). Solo se ejecuta cuando la llamas. En Codex se llama como `$metarche` (p. ej. `$metarche new`); `agents/openai.yaml` evita que Codex la cargue por su cuenta.

## Skills de lenguaje
Metarche no depende de ningún lenguaje de programación. Una skill de lenguaje añade los valores para un lenguaje concreto. Si una skill dentro de `~/.claude/skills/` tiene `references/metarche.md`, Metarche lo lee en la entrevista (paso 4) y en las etapas de documentos y plan. Sin ella, Metarche funciona igual.

`references/metarche.md` debe contener:
1. Preguntas adicionales para ese lenguaje
2. Comandos de comprobación: por archivo (recibe la ruta del archivo editado) y al final del turno (todo el proyecto)
3. Líneas para incluir en CLAUDE.md
4. La primera tarea del plan (esqueleto del proyecto) y cómo verificarla

Ejemplo: [Rustarche](https://github.com/metapbl/Rustarche) para Rust.

## Estructura
~~~
skill/
├─ SKILL.md            punto de entrada: reglas, detección de estado, mapa de etapas
├─ agents/openai.yaml  Codex: solo se ejecuta al llamarla
└─ references/
   ├─ discover.md      pasos 0–5: entrevista, aprobación y cambios del PRD
   ├─ docs.md          paso 6: documentos
   ├─ plan.md          paso 7: plan
   ├─ execute.md       pasos 8–9: implementación y mejora, wrap
   ├─ audit.md         auditoría
   ├─ adopt.md         incorporación de un proyecto existente
   ├─ agents.md        núcleo común y adaptadores por agente (Claude Code, Codex, otros)
   ├─ security.md      política de seguridad (nivel, clases de datos, límites de confianza, cifrado)
   ├─ upgrade.md       aplicar revisiones de la skill a proyectos existentes (registro de revisiones)
   ├─ readme.md        norma de README para repositorios públicos (línea de idiomas, insignias de Shields.io)
   └─ templates/       PRD, SECURITY_POLICY, QA_LOG, OPEN, DECISIONS, AGENTS, CLAUDE, PROGRESS, REFERENCE, profile, hooks/, claude/, codex/
~~~

## Estado del proyecto
- El autor la usa en varios proyectos (Windows, Claude Code).
- Las pruebas de hooks pasan en Windows, macOS y Linux en CI.
- El adaptador de Codex sigue la documentación de Codex, pero aún no se ha ejecutado en Codex.
- Sigue cambiando. Los proyectos existentes se ponen al día con `/metarche upgrade`.

## Ayuda y contribuciones
- Preguntas e informes de errores: [GitHub Issues](https://github.com/metapbl/Metarche/issues).
- Pull requests: abre primero un issue para acordar el cambio. Mantén el texto de la skill en inglés y sin nombres de herramientas personales, y que las pruebas de hooks sigan pasando: `pwsh -NoProfile -File tests/hooks.test.ps1`.

## Seguridad
Informa de vulnerabilidades en privado mediante el [informe privado de vulnerabilidades de GitHub](https://github.com/metapbl/Metarche/security/advisories/new), no en un issue público.

## Créditos
Los proyectos y artículos en los que se basa esta skill están en [`NOTICE`](NOTICE).

## Licencia
MIT
