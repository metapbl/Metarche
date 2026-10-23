# PreToolUse(Edit|Write): docs/PRD.md가 approved가 아니면 docs/·.claude/·CLAUDE.md 밖 수정을 막는다.
$ErrorActionPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$data = [Console]::In.ReadToEnd() | ConvertFrom-Json
$root = if ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { $data.cwd }
$prd = Join-Path $root 'docs/PRD.md'
if (-not (Test-Path $prd)) { exit 0 }
if ((Get-Content $prd -Encoding utf8 -TotalCount 5) -match '상태:\s*approved') { exit 0 }
$rel = ([string]$data.tool_input.file_path).Replace('\', '/')
if (-not $rel) { exit 0 }
$base = $root.Replace('\', '/').TrimEnd('/') + '/'
if ($rel.StartsWith($base, [StringComparison]::OrdinalIgnoreCase)) { $rel = $rel.Substring($base.Length) }
if ($rel -match '^(docs/|\.claude/|CLAUDE(\.local)?\.md$)') { exit 0 }
[Console]::Error.WriteLine("[metarche] PRD 미승인: $rel 수정 금지. docs/PRD.md 승인 전에는 문서만 고칩니다.")
exit 2
