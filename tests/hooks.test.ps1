# Runs the four hook templates in a throwaway project and checks their behavior. Exits 1 if any check fails.
# Covers both input shapes: Claude Code (CLAUDE_PROJECT_DIR, tool_input.file_path) and Codex (no env var, cwd may be a
# subfolder, apply_patch with the paths inside tool_input.command).
# Run: pwsh -NoProfile -File tests/hooks.test.ps1   (Windows, macOS and Linux)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.Encoding]::UTF8   # hooks print UTF-8; reading with the console code page (CP949 etc.) garbles non-ASCII text
$tpl = Join-Path $PSScriptRoot '../skill/references/templates/hooks'
$root = Join-Path ([IO.Path]::GetTempPath()) ("metarche-hooks-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
$hooks = Join-Path $root '.metarche/hooks'
New-Item -ItemType Directory -Force $hooks, (Join-Path $root 'docs'), (Join-Path $root 'src/sub') | Out-Null
git -C $root init -q 2>&1 | Out-Null
$script:failures = 0

function Run($hook, $obj, [switch]$Codex) {
    # Claude Code exports CLAUDE_PROJECT_DIR; Codex does not.
    if ($Codex) { Remove-Item Env:CLAUDE_PROJECT_DIR -ErrorAction SilentlyContinue } else { $env:CLAUDE_PROJECT_DIR = $root }
    $out = ($obj | ConvertTo-Json -Compress -Depth 5) | pwsh -NoProfile -File (Join-Path $hooks $hook) 2>&1
    [pscustomobject]@{ Code = $LASTEXITCODE; Out = ($out -join "`n") }
}
function Expect($name, $cond) {
    if ($cond) { "  ok   $name" } else { "  FAIL $name"; $script:failures++ }
}
function Patch($lines) { "*** Begin Patch`n" + ($lines -join "`n") + "`n*** End Patch" }
$sub = Join-Path $root 'src/sub'   # a Codex session started in a subfolder

# Test checkers: fail when the file (or the project) contains BAD. Kept inside the project so the path has no spaces.
Set-Content (Join-Path $root 'file-check.ps1') 'if ((Get-Content $args[0] -Raw) -match "BAD") { "bad file"; exit 1 }'
Set-Content (Join-Path $root 'proj-check.ps1') 'if (Get-ChildItem src -File -Recurse | Where-Object { (Get-Content $_.FullName -Raw) -match "BAD" }) { "bad project"; exit 1 }'
Copy-Item (Join-Path $tpl 'gate.ps1'), (Join-Path $tpl 'progress-head.ps1') $hooks
(Get-Content (Join-Path $tpl 'check.ps1') -Raw) -replace '\$checks = @\{\r?\n\}', "`$checks = @{`n    '.txt' = @('pwsh -NoProfile -File file-check.ps1')`n}" |
    Set-Content (Join-Path $hooks 'check.ps1')
(Get-Content (Join-Path $tpl 'finish.ps1') -Raw) -replace '\$finish = @\(\r?\n\)', "`$finish = @(`n    'pwsh -NoProfile -File proj-check.ps1'`n)" |
    Set-Content (Join-Path $hooks 'finish.ps1')
$mark = Join-Path $root '.metarche/.unchecked'

"gate.ps1"
Set-Content (Join-Path $root 'docs/PRD.md') "# PRD`n`nStatus: changing (2026-01-01)"
$edit = { param($p) Run 'gate.ps1' @{ cwd = $root; tool_name = 'Edit'; tool_input = @{ file_path = $p } } }
$patch = { param($lines) Run 'gate.ps1' @{ cwd = $sub; tool_name = 'apply_patch'; tool_input = @{ command = (Patch $lines) } } -Codex }
Expect 'blocks src/ while the PRD is changing' ((& $edit 'src/a.txt').Code -eq 2)
Expect 'allows docs/ while the PRD is changing' ((& $edit 'docs/notes.md').Code -eq 0)
Expect 'blocks the docs/../src escape' ((& $edit 'docs/../src/a.txt').Code -eq 2)
Expect 'blocks src/ given as an absolute path' ((& $edit (Join-Path $root 'src/a.txt')).Code -eq 2)
Expect 'blocks .claude/worktrees/' ((& $edit '.claude/worktrees/x/a.txt').Code -eq 2)
Expect 'allows AGENTS.md and .metarche/' ((& $edit 'AGENTS.md').Code -eq 0 -and (& $edit '.metarche/x.txt').Code -eq 0)
Expect 'Codex: blocks a patch that updates code' ((& $patch @('*** Update File: a.txt', '@@', '-x', '+y')).Code -eq 2)
Expect 'Codex: allows a patch that only touches docs/' ((& $patch @('*** Add File: ../../docs/n.md', '+hi')).Code -eq 0)
Expect 'Codex: blocks a mixed patch' ((& $patch @('*** Add File: ../../docs/n.md', '+hi', '*** Delete File: b.txt')).Code -eq 2)
Set-Content (Join-Path $root 'docs/PRD.md') "# PRD`n`nStatus: approved (2026-01-01)"
Expect 'allows src/ once the PRD is approved' ((& $edit 'src/a.txt').Code -eq 0)
Expect 'Codex: allows code once the PRD is approved' ((& $patch @('*** Update File: a.txt')).Code -eq 0)
Set-Content (Join-Path $root 'docs/PRD.md') "# PRD`n`n상태: approved (2026-01-01)"
Expect 'accepts the legacy marker 상태: approved' ((& $edit 'src/a.txt').Code -eq 0)

"check.ps1"
$check = { param($p) Run 'check.ps1' @{ cwd = $root; tool_name = 'Write'; tool_input = @{ file_path = $p } } }
Set-Content (Join-Path $root 'src/a.txt') 'GOOD'
$r = & $check 'src/a.txt'
Expect 'passing file exits 0' ($r.Code -eq 0)
Expect 'editing a file creates the marker in .metarche/' (Test-Path $mark)
Set-Content (Join-Path $root 'src/a.txt') 'BAD'
$r = & $check 'src/a.txt'
Expect 'failing file exits 2 with output' ($r.Code -eq 2 -and $r.Out -match 'bad file')
Expect 'extension without checks exits 0' ((& $check 'src/b.md').Code -eq 0)
Expect 'ignores files outside the project' ((& $check (Join-Path ([IO.Path]::GetTempPath()) 'outside.txt')).Code -eq 0)
Set-Content $mark '1'
& $check 'src/a.txt' | Out-Null
Expect 'keeps the count in an existing marker' ((Get-Content $mark -Raw).Trim() -eq '1')
Remove-Item -Force $mark
Set-Content (Join-Path $sub 'c.txt') 'BAD'
$r = Run 'check.ps1' @{ cwd = $sub; tool_name = 'apply_patch'; tool_input = @{ command = (Patch @('*** Add File: c.txt', '+BAD')) } } -Codex
Expect 'Codex: checks the patched file and returns the failure' ($r.Code -eq 2 -and $r.Out -match 'bad file')
Expect 'Codex: the marker lands in the project root, not the subfolder' ((Test-Path $mark) -and -not (Test-Path (Join-Path $sub '.metarche')))

"finish.ps1"
Remove-Item -Force $mark
Expect 'no marker means no check' ((Run 'finish.ps1' @{ cwd = $root }).Code -eq 0)
New-Item -ItemType File -Force $mark | Out-Null
$r = Run 'finish.ps1' @{ cwd = $root }
Expect 'first failure blocks (1/2)' ($r.Code -eq 2 -and $r.Out -match '1/2' -and $r.Out -match 'bad project')
Expect 'a block tells the agent to ask the user' ($r.Out -match 'ask the user')
$r = Run 'finish.ps1' @{ cwd = $sub } -Codex
Expect 'Codex: second failure blocks (2/2) from a subfolder' ($r.Code -eq 2 -and $r.Out -match '2/2')
$r = Run 'finish.ps1' @{ cwd = $root }
Expect 'third failure lets go and removes the marker' ($r.Code -eq 0 -and -not (Test-Path $mark))
Expect 'a following question-only turn is not blocked' ((Run 'finish.ps1' @{ cwd = $root }).Code -eq 0)
Set-Content (Join-Path $root 'src/a.txt') 'GOOD'; Set-Content (Join-Path $sub 'c.txt') 'GOOD'
New-Item -ItemType File -Force $mark | Out-Null
$r = Run 'finish.ps1' @{ cwd = $root }
Expect 'passing removes the marker' ($r.Code -eq 0 -and -not (Test-Path $mark))

"progress-head.ps1"
# Korean content checks that non-ASCII text survives injection.
Set-Content (Join-Path $root 'docs/PROGRESS.md') "# PROGRESS`n## 상태`n- 단계: 8`n<!-- head:end -->`n## 완료 기록`n- not injected"
git -C $root -c user.name=t -c user.email=t@example.com commit -q --allow-empty -m 'docs: 시험 커밋' 2>&1 | Out-Null
$r = Run 'progress-head.ps1' @{ cwd = $root; source = 'startup' }
Expect 'injects the head' ($r.Out -match '단계: 8')
Expect 'does not inject below head:end' ($r.Out -notmatch 'not injected')
Expect 'reads the last commit from git (non-ASCII message)' ($r.Out -match 'Last commit \(git\): [0-9a-f]+ docs: 시험 커밋')
$r = Run 'progress-head.ps1' @{ cwd = $sub; source = 'startup' } -Codex
Expect 'Codex: finds the head from a subfolder' ($r.Out -match '단계: 8')

Remove-Item -Recurse -Force $root
if ($script:failures) { "$($script:failures) failed"; exit 1 }
"all passed"
