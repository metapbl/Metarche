# Stop: 파일을 고친 뒤(.claude/.unchecked)면 프로젝트 단위 검사를 돌리고, 실패하면 출력을 Claude에게 돌려준다(exit 2).
$ErrorActionPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [Text.Encoding]::UTF8
# 프로젝트 단위 검사 명령. 파일 경로를 붙이지 않는다. 비어 있으면 아무것도 하지 않는다.
# docs 단계에서 PRD §6 "작업 끝 자동 검사"대로 채운다. 예: @('cargo clippy --workspace --all-targets -- -D warnings')
$finish = @(
)
$limit = 2   # 같은 실패로 막는 최대 횟수. 넘으면 표시를 지워 다음 턴(질문만 한 턴 포함)을 막지 않는다.
$data = [Console]::In.ReadToEnd() | ConvertFrom-Json
$root = if ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { $data.cwd }
$mark = Join-Path $root '.claude/.unchecked'   # macOS·Linux에서는 숨김 파일이라 지울 때 -Force가 필요하다
if (-not (Test-Path $mark)) { exit 0 }
if (-not $finish) { Remove-Item -Force $mark; exit 0 }
Set-Location $root
$failed = foreach ($cmd in $finish) {
    $exe, $rest = -split $cmd
    $args_ = @($rest | Where-Object { $_ })
    if (-not (Get-Command $exe)) { "[metarche] 검사 도구 없음: $exe. 설치하거나 .claude/hooks/finish.ps1에서 빼십시오."; continue }
    $out = & $exe @args_ 2>&1
    if ($LASTEXITCODE -ne 0) { "[metarche] 작업 끝 검사 실패: $cmd"; $out | Select-Object -Last 40 }
}
if (-not $failed) { Remove-Item -Force $mark; exit 0 }
# 표시 파일에 막은 횟수를 적는다 (check.ps1은 파일이 없을 때만 만들므로 고치는 동안 유지된다).
$n = [int](Get-Content $mark -Raw) + 1
if ($n -gt $limit) { Remove-Item -Force $mark; exit 0 }
Set-Content $mark $n
$failed = @($failed) + "[metarche] 작업 끝 검사 $n/$limit. 고칠 방법이 분명하지 않거나 사용자 요청과 부딪히면 고치지 말고 사용자에게 물으십시오. $($limit)번 넘게 실패하면 더 막지 않으니, 남은 실패는 사용자에게 알리십시오."
[Console]::Error.WriteLine(($failed -join "`n"))
exit 2
