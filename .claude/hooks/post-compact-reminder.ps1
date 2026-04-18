# PostCompact Hook
# Fires after /compact. Reminds user that preloaded Grundlagen are gone and suggests /prime-ark.

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

try {
    # Read hook input (not strictly needed but keeps stdin clean)
    $raw = [Console]::In.ReadToEnd()

    $message = @"
⚠ Kontext wurde komprimiert. Grundlagen-Preload (~225k Tokens) ist jetzt raus.

Falls du weiter Lookup-heavy arbeitest (Lint-Skills, Stammdaten-Checks, Saga-Trace):
  → Tippe /prime-ark um Grundlagen neu zu laden.

Falls nur noch leichte Arbeit: ignorieren, Claude liest bei Bedarf on-demand.
"@

    $output = @{
        systemMessage = $message
        suppressOutput = $true
    }

    $output | ConvertTo-Json -Depth 5 -Compress
    exit 0
}
catch {
    [Console]::Error.WriteLine("post-compact-reminder error: $_")
    exit 0
}
