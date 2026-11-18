# 훅 템플릿 4개를 임시 프로젝트에서 실행해 동작을 확인한다. 실패가 하나라도 있으면 exit 1.
# 실행: pwsh -NoProfile -File tests/hooks.test.ps1   (Windows·macOS·Linux 공통)
$ErrorActionPreference = 'Stop'
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

# 시험용 검사기: 파일(또는 프로젝트)에 BAD가 있으면 실패한다. 경로에 공백이 없도록 프로젝트 안에 둔다.
Set-Content (Join-Path $root 'file-check.ps1') 'if ((Get-Content $args[0] -Raw) -match "BAD") { "bad file"; exit 1 }'
Set-Content (Join-Path $root 'proj-check.ps1') 'if (Get-ChildItem src -File | Where-Object { (Get-Content $_.FullName -Raw) -match "BAD" }) { "bad project"; exit 1 }'
Copy-Item (Join-Path $tpl 'gate.ps1'), (Join-Path $tpl 'progress-head.ps1') $hooks
(Get-Content (Join-Path $tpl 'check.ps1') -Raw) -replace '\$checks = @\{\r?\n\}', "`$checks = @{`n    '.txt' = @('pwsh -NoProfile -File file-check.ps1')`n}" |
    Set-Content (Join-Path $hooks 'check.ps1')
(Get-Content (Join-Path $tpl 'finish.ps1') -Raw) -replace '\$finish = @\(\r?\n\)', "`$finish = @(`n    'pwsh -NoProfile -File proj-check.ps1'`n)" |
    Set-Content (Join-Path $hooks 'finish.ps1')
$mark = Join-Path $root '.claude/.unchecked'

"gate.ps1"
Set-Content (Join-Path $root 'docs/PRD.md') "# PRD`n`n상태: changing (2026-01-01)"
$edit = { param($p) Run 'gate.ps1' (@{ cwd = $root; tool_input = @{ file_path = $p } } | ConvertTo-Json -Compress) }
Expect 'PRD 변경 중에는 src/ 수정을 막는다' ((& $edit 'src/a.txt').Code -eq 2)
Expect 'PRD 변경 중에도 docs/ 수정은 허용한다' ((& $edit 'docs/notes.md').Code -eq 0)
Expect 'docs/../src 우회를 막는다' ((& $edit 'docs/../src/a.txt').Code -eq 2)
Expect '절대 경로로 준 src/도 막는다' ((& $edit (Join-Path $root 'src/a.txt')).Code -eq 2)
Expect '.claude/worktrees/ 수정은 막는다' ((& $edit '.claude/worktrees/x/a.txt').Code -eq 2)
Set-Content (Join-Path $root 'docs/PRD.md') "# PRD`n`n상태: approved (2026-01-01)"
Expect 'PRD 승인 뒤에는 src/ 수정을 허용한다' ((& $edit 'src/a.txt').Code -eq 0)

"check.ps1"
Set-Content (Join-Path $root 'src/a.txt') 'GOOD'
$r = Edit 'src/a.txt'
Expect '통과하는 파일은 exit 0' ($r.Code -eq 0)
Expect '파일을 고치면 표시 파일을 만든다' (Test-Path $mark)
Set-Content (Join-Path $root 'src/a.txt') 'BAD'
$r = Edit 'src/a.txt'
Expect '검사에 걸리는 파일은 exit 2와 출력' ($r.Code -eq 2 -and $r.Out -match 'bad file')
Expect '검사 표에 없는 확장자는 exit 0' ((Edit 'src/b.md').Code -eq 0)
Expect '프로젝트 밖 파일은 무시한다' ((Edit (Join-Path ([IO.Path]::GetTempPath()) 'outside.txt')).Code -eq 0)
Set-Content $mark '1'
Edit 'src/a.txt' | Out-Null
Expect '이미 있는 표시 파일의 횟수는 그대로 둔다' ((Get-Content $mark -Raw).Trim() -eq '1')

"finish.ps1"
Remove-Item $mark
Expect '표시 파일이 없으면 검사하지 않는다' ((Run 'finish.ps1' '{}').Code -eq 0)
New-Item -ItemType File -Force $mark | Out-Null
$r = Run 'finish.ps1' '{}'
Expect '첫 실패는 막는다 (1/2)' ($r.Code -eq 2 -and $r.Out -match '1/2' -and $r.Out -match 'bad project')
Expect '막을 때 사용자에게 물으라는 문구를 준다' ($r.Out -match '사용자에게 물으십시오')
$r = Run 'finish.ps1' '{}'
Expect '두 번째 실패도 막는다 (2/2)' ($r.Code -eq 2 -and $r.Out -match '2/2')
$r = Run 'finish.ps1' '{}'
Expect '세 번째 실패는 통과시키고 표시를 지운다' ($r.Code -eq 0 -and -not (Test-Path $mark))
Expect '그다음 질문만 한 턴은 막지 않는다' ((Run 'finish.ps1' '{}').Code -eq 0)
Set-Content (Join-Path $root 'src/a.txt') 'GOOD'
New-Item -ItemType File -Force $mark | Out-Null
$r = Run 'finish.ps1' '{}'
Expect '통과하면 표시 파일을 지운다' ($r.Code -eq 0 -and -not (Test-Path $mark))

"progress-head.ps1"
Set-Content (Join-Path $root 'docs/PROGRESS.md') "# PROGRESS`n## 상태`n- 단계: 8`n<!-- head:end -->`n## 완료 기록`n- 이 줄은 주입되지 않는다"
git -C $root init -q 2>&1 | Out-Null
git -C $root -c user.name=t -c user.email=t@example.com commit -q --allow-empty -m 'docs: 시험 커밋' 2>&1 | Out-Null
$r = Run 'progress-head.ps1' '{}'
Expect '머리를 주입한다' ($r.Out -match '단계: 8')
Expect 'head:end 아래는 주입하지 않는다' ($r.Out -notmatch '주입되지 않는다')
Expect '마지막 커밋을 git에서 읽는다 (한글 포함)' ($r.Out -match '마지막 커밋 \(git\): [0-9a-f]+ docs: 시험 커밋')

Remove-Item -Recurse -Force $root
if ($script:failures) { "실패 $($script:failures)개"; exit 1 }
"모두 통과"
