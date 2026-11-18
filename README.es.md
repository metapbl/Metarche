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
  <a href="#instalación"><img alt="Claude Code skill" src="https://img.shields.io/badge/Claude_Code-skill-D97757?style=flat-square&logo=claude&logoColor=white"></a>
  <a href="#requisitos"><img alt="Platform: Windows, macOS, Linux" src="https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-0078D4?style=flat-square"></a>
  <a href="#requisitos"><img alt="PowerShell 7" src="https://img.shields.io/badge/PowerShell-7-5391FE?style=flat-square"></a>
  <a href="https://github.com/metapbl/Metarche/actions/workflows/hooks.yml"><img alt="Hook tests" src="https://img.shields.io/github/actions/workflow/status/metapbl/Metarche/hooks.yml?branch=main&style=flat-square&label=hook%20tests"></a>
</p>

meta + archē: una skill de Claude Code que convierte una entrevista de preguntas y respuestas en un PRD, documentos y un plan, y luego construye con puertas de aprobación.

> [!NOTE]
> Las instrucciones de la skill y las plantillas de documentos están escritas en coreano, por lo que los documentos que genera (PRD, CLAUDE.md, planes) también están en coreano.

## Qué hace
- Define el propósito, el alcance, las funciones y el enfoque mediante una entrevista y luego te pide aprobar un PRD.
- Fija un nivel y una política de seguridad (clases de datos, límites de confianza entre cliente y servidor, cifrado) y los aprueba junto con el PRD.
- Crea los documentos que necesita Claude Code (CLAUDE.md, PROGRESS, REFERENCE), además de reglas de permisos y hooks: comprobación al editar, comprobación del proyecto al final de cada turno, puerta del PRD e inyección del progreso.
- Escribe un plan de tareas y repite implementar → verificar → registrar, con una aprobación en cada paso.
- Guarda todo el estado en archivos, así el trabajo continúa después de `/clear` y de la compactación del contexto.

## Requisitos
- Windows, macOS o Linux con PowerShell 7 (`pwsh`). Los hooks son scripts de PowerShell y se comprueban en los tres sistemas con [pruebas de hooks](tests/hooks.test.ps1).
- [Claude Code](https://code.claude.com/docs)
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
Está listo cuando `metarche` aparece en `/skills` dentro de Claude Code. Para actualizar, ejecuta `git pull` en la carpeta del repositorio.

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

La skill nunca se invoca automáticamente (`disable-model-invocation: true`). Solo se ejecuta cuando la llamas.

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
└─ references/
   ├─ discover.md      pasos 0–5: entrevista, aprobación y cambios del PRD
   ├─ docs.md          paso 6: documentos
   ├─ plan.md          paso 7: plan
   ├─ execute.md       pasos 8–9: implementación y mejora, wrap
   ├─ audit.md         auditoría
   ├─ adopt.md         incorporación de un proyecto existente
   ├─ security.md      política de seguridad (nivel, clases de datos, límites de confianza, cifrado)
   ├─ upgrade.md       aplicar revisiones de la skill a proyectos existentes (registro de revisiones)
   ├─ readme.md        norma de README para repositorios públicos (línea de idiomas, insignias de Shields.io)
   └─ templates/       PRD, SECURITY_POLICY, QA_LOG, OPEN, DECISIONS, CLAUDE, PROGRESS, REFERENCE, profile, settings.json, hooks/
~~~

## Créditos
Los proyectos y artículos en los que se basa esta skill están en [`NOTICE`](NOTICE).

## Licencia
MIT
