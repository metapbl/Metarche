# Runs the four hook templates in a throwaway project and checks their behavior. Exits 1 if any check fails.
# Run: pwsh -NoProfile -File tests/hooks.test.ps1   (Windows, macOS and Linux)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.Encoding]::UTF8   # hooks print UTF-8; reading with the console code page (CP949 etc.) garbles non-ASCII text
$tpl = Join-Path $PSScriptRoot '../skill/references/templates/hooks'
$root = Join-Path ([IO.Path]::GetTempPath()) ("metarche-hooks-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
$hooks = Join-Path $root '.claude/hooks'
New-Item -ItemType Directory -Force $hooks, (Join-Path $root 'docs'), (Join-Path $root 'src') | Out-Null
$env:CLAUDE_PROJECT_DIR = $root
$script:failures = 0

function Run($hook, $json) {
    $out = $json | pwsh -NoProfile -File (Join-Path $hooks $hook) 2>&1
    [pscustomobject]@{ Code = $LASTEXITCODE; Out = ($out -join "`n") }
}
function Expect($name, $cond) {
    if ($cond) { "  ok   $name" } else { "  FAIL $name"; $script:failures++ }
}
function Edit($rel) { Run 'check.ps1' (@{ tool_input = @{ file_path = $rel } } | ConvertTo-Json -Compress) }

# Test checkers: fail when the file (or the project) contains BAD. Kept inside the project so the path has no spaces.
Set-Content (Join-Path $root 'file-check.ps1') 'if ((Get-Content $args[0] -Raw) -match "BAD") { "bad file"; exit 1 }'
Set-Content (Join-Path $root 'proj-check.ps1') 'if (Get-ChildItem src -File | Where-Object { (Get-Content $_.FullName -Raw) -match "BAD" }) { "bad project"; exit 1 }'
Copy-Item (Join-Path $tpl 'gate.ps1'), (Join-Path $tpl 'progress-head.ps1') $hooks
(Get-Content (Join-Path $tpl 'check.ps1') -Raw) -replace '\$checks = @\{\r?\n\}', "`$checks = @{`n    '.txt' = @('pwsh -NoProfile -File file-check.ps1')`n}" |
    Set-Content (Join-Path $hooks 'check.ps1')
(Get-Content (Join-Path $tpl 'finish.ps1') -Raw) -replace '\$finish = @\(\r?\n\)', "`$finish = @(`n    'pwsh -NoProfile -File proj-check.ps1'`n)" |
    Set-Content (Join-Path $hooks 'finish.ps1')
$mark = Join-Path $root '.claude/.unchecked'

"gate.ps1"
Set-Content (Join-Path $root 'docs/PRD.md') "# PRD`n`nStatus: changing (2026-01-01)"
$edit = { param($p) Run 'gate.ps1' (@{ cwd = $root; tool_input = @{ file_path = $p } } | ConvertTo-Json -Compress) }
Expect 'blocks src/ while the PRD is changing' ((& $edit 'src/a.txt').Code -eq 2)
Expect 'allows docs/ while the PRD is changing' ((& $edit 'docs/notes.md').Code -eq 0)
Expect 'blocks the docs/../src escape' ((& $edit 'docs/../src/a.txt').Code -eq 2)
Expect 'blocks src/ given as an absolute path' ((& $edit (Join-Path $root 'src/a.txt')).Code -eq 2)
Expect 'blocks .claude/worktrees/' ((& $edit '.claude/worktrees/x/a.txt').Code -eq 2)
Set-Content (Join-Path $root 'docs/PRD.md') "# PRD`n`nStatus: approved (2026-01-01)"
Expect 'allows src/ once the PRD is approved' ((& $edit 'src/a.txt').Code -eq 0)
Set-Content (Join-Path $root 'docs/PRD.md') "# PRD`n`n상태: approved (2026-01-01)"
Expect 'accepts the legacy marker 상태: approved' ((& $edit 'src/a.txt').Code -eq 0)

"check.ps1"
Set-Content (Join-Path $root 'src/a.txt') 'GOOD'
$r = Edit 'src/a.txt'
Expect 'passing file exits 0' ($r.Code -eq 0)
Expect 'editing a file creates the marker' (Test-Path $mark)
Set-Content (Join-Path $root 'src/a.txt') 'BAD'
$r = Edit 'src/a.txt'
Expect 'failing file exits 2 with output' ($r.Code -eq 2 -and $r.Out -match 'bad file')
Expect 'extension without checks exits 0' ((Edit 'src/b.md').Code -eq 0)
Expect 'ignores files outside the project' ((Edit (Join-Path ([IO.Path]::GetTempPath()) 'outside.txt')).Code -eq 0)
Set-Content $mark '1'
Edit 'src/a.txt' | Out-Null
Expect 'keeps the count in an existing marker' ((Get-Content $mark -Raw).Trim() -eq '1')

"finish.ps1"
Remove-Item -Force $mark
Expect 'no marker means no check' ((Run 'finish.ps1' '{}').Code -eq 0)
New-Item -ItemType File -Force $mark | Out-Null
$r = Run 'finish.ps1' '{}'
Expect 'first failure blocks (1/2)' ($r.Code -eq 2 -and $r.Out -match '1/2' -and $r.Out -match 'bad project')
Expect 'a block tells Claude to ask the user' ($r.Out -match 'ask the user')
$r = Run 'finish.ps1' '{}'
Expect 'second failure blocks (2/2)' ($r.Code -eq 2 -and $r.Out -match '2/2')
$r = Run 'finish.ps1' '{}'
Expect 'third failure lets go and removes the marker' ($r.Code -eq 0 -and -not (Test-Path $mark))
Expect 'a following question-only turn is not blocked' ((Run 'finish.ps1' '{}').Code -eq 0)
Set-Content (Join-Path $root 'src/a.txt') 'GOOD'
New-Item -ItemType File -Force $mark | Out-Null
$r = Run 'finish.ps1' '{}'
Expect 'passing removes the marker' ($r.Code -eq 0 -and -not (Test-Path $mark))

"progress-head.ps1"
# Korean content checks that non-ASCII text survives injection.
Set-Content (Join-Path $root 'docs/PROGRESS.md') "# PROGRESS`n## 상태`n- 단계: 8`n<!-- head:end -->`n## 완료 기록`n- not injected"
git -C $root init -q 2>&1 | Out-Null
git -C $root -c user.name=t -c user.email=t@example.com commit -q --allow-empty -m 'docs: 시험 커밋' 2>&1 | Out-Null
$r = Run 'progress-head.ps1' '{}'
Expect 'injects the head' ($r.Out -match '단계: 8')
Expect 'does not inject below head:end' ($r.Out -notmatch 'not injected')
Expect 'reads the last commit from git (non-ASCII message)' ($r.Out -match 'Last commit \(git\): [0-9a-f]+ docs: 시험 커밋')

Remove-Item -Recurse -Force $root
if ($script:failures) { "$($script:failures) failed"; exit 1 }
"all passed"
