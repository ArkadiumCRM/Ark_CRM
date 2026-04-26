# PostToolUse Hook: scoped Playwright smoke-test on mockup edits
# Fires after Edit/Write on mockups/*.html. Runs CLI smoke test for that one file.
# On failure: returns systemMessage with error so Claude sees the regression immediately.

$ErrorActionPreference = 'Continue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

try {
    $raw = [Console]::In.ReadToEnd()
    if (-not $raw.Trim()) { exit 0 }
    $data = $raw | ConvertFrom-Json

    $filePath = $null
    if ($data.tool_input.file_path)      { $filePath = [string]$data.tool_input.file_path }
    elseif ($data.tool_input.path)       { $filePath = [string]$data.tool_input.path }
    if (-not $filePath) { exit 0 }

    $filePath = $filePath -replace '\\', '/'
    if ($filePath -notmatch '/mockups/.+\.html$') { exit 0 }

    # Skip archived/deprecated paths (broken on purpose, would always trigger)
    if ($filePath -match '/_archive/|/_deprecated/') { exit 0 }

    $projectRoot = 'C:/Projects/Ark_CRM'
    $mockupsRoot = "$projectRoot/mockups/"
    $idx = $filePath.IndexOf($mockupsRoot)
    if ($idx -lt 0) { exit 0 }
    $relMockup = $filePath.Substring($idx + $mockupsRoot.Length)

    Push-Location $projectRoot
    try {
        # Run scoped test via env var (avoids Windows --grep arg-quoting issues)
        $env:PW_TARGET_FILE = $relMockup
        $tmpOut = [System.IO.Path]::GetTempFileName()
        $proc = Start-Process -FilePath 'npx.cmd' `
            -ArgumentList @('playwright', 'test', 'tests/mockups-smoke.spec.ts', '--reporter=line', '--workers=1') `
            -RedirectStandardOutput $tmpOut `
            -RedirectStandardError "$tmpOut.err" `
            -NoNewWindow -PassThru -Wait
        Remove-Item Env:\PW_TARGET_FILE -ErrorAction SilentlyContinue

        $stdout = if (Test-Path $tmpOut)        { Get-Content $tmpOut -Raw -Encoding UTF8 } else { '' }
        $stderr = if (Test-Path "$tmpOut.err")  { Get-Content "$tmpOut.err" -Raw -Encoding UTF8 } else { '' }
        Remove-Item $tmpOut, "$tmpOut.err" -Force -ErrorAction SilentlyContinue

        if ($proc.ExitCode -ne 0) {
            # Extract first relevant error line(s)
            $errLines = @()
            foreach ($line in ($stdout -split "`n")) {
                if ($line -match 'pageerror|console\.error|Error:|✘|FAIL') {
                    $errLines += $line.Trim()
                }
            }
            $errSnippet = if ($errLines) { ($errLines | Select-Object -First 5) -join "`n" } else { ($stdout -split "`n" | Select-Object -Last 20) -join "`n" }

            $msg = @"
SMOKE-TEST FAIL on ``$relMockup`` after edit.

Playwright CLI scoped run (exit $($proc.ExitCode)):
$errSnippet

Investigate before continuing. Run again: ``cd "C:/Projects/Ark_CRM" && npx playwright test tests/mockups-smoke.spec.ts --grep "$relMockup"``
"@
            $output = @{
                systemMessage  = $msg
                suppressOutput = $false
            }
            $output | ConvertTo-Json -Depth 5 -Compress
            exit 0
        }

        # Success: silent
        @{ suppressOutput = $true } | ConvertTo-Json -Compress
        exit 0
    }
    finally {
        Pop-Location
    }
}
catch {
    [Console]::Error.WriteLine("mockup-smoke hook error: $_")
    exit 0
}
