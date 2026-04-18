# Load-Grundlagen Hook
# Auto-loads ARK Grundlagen DIGEST files as SessionStart context.
# Digest mode: ~42k tokens per session (lossless enums + catalogs, lossy prose).
# For precision work (exact columns, endpoints) assistant asks before reading full Grundlagen MD.
# Deactivate by removing SessionStart hook entry from .claude/settings.json.

$ErrorActionPreference = 'Stop'

try {
    $digestDir = 'C:/ARK CRM/wiki/meta/digests'

    if (-not (Test-Path $digestDir)) {
        exit 0
    }

    $files = Get-ChildItem $digestDir -Filter '*-digest.md' | Sort-Object Name
    if ($files.Count -eq 0) {
        exit 0
    }

    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine('# ARK Grundlagen Digests (auto-loaded via SessionStart hook)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine("Files: $($files.Count) Digests | Kontext-Kosten: ~42k Tokens")
    [void]$sb.AppendLine('Digests enthalten: alle Enums/Kataloge lossless, Prosa/Beispiele lossy.')
    [void]$sb.AppendLine('Volltext: `C:/ARK CRM/Grundlagen MD/ARK_*.md` — Assistant fragt vor Read fuer Praezisions-Arbeit.')
    [void]$sb.AppendLine('Deaktivieren: SessionStart-Hook `load-grundlagen.ps1` aus `.claude/settings.json` entfernen.')
    [void]$sb.AppendLine('')

    foreach ($f in $files) {
        [void]$sb.AppendLine('---')
        [void]$sb.AppendLine("## DIGEST: $($f.Name)")
        [void]$sb.AppendLine('')
        $content = Get-Content $f.FullName -Raw -Encoding UTF8
        [void]$sb.AppendLine($content)
        [void]$sb.AppendLine('')
    }

    # --- Extra-Context: Anti-Patterns + Decisions + Mockup-Baseline ---
    $extraFiles = @(
        @{ Path = 'C:/ARK CRM/wiki/meta/anti-patterns.md';    Label = 'ANTI-PATTERNS' },
        @{ Path = 'C:/ARK CRM/wiki/meta/decisions.md';        Label = 'DECISION-LOG' },
        @{ Path = 'C:/ARK CRM/wiki/meta/mockup-baseline.md';  Label = 'MOCKUP-BASELINE' }
    )
    foreach ($ef in $extraFiles) {
        if (Test-Path $ef.Path) {
            [void]$sb.AppendLine('---')
            [void]$sb.AppendLine("## $($ef.Label): $(Split-Path -Leaf $ef.Path)")
            [void]$sb.AppendLine('')
            $c = Get-Content $ef.Path -Raw -Encoding UTF8
            [void]$sb.AppendLine($c)
            [void]$sb.AppendLine('')
        }
    }

    # --- Stale-Digest-Warning ---
    $stalePath = 'C:/ARK CRM/wiki/meta/digests/STALE.md'
    if (Test-Path $stalePath) {
        $staleContent = Get-Content $stalePath -Raw -Encoding UTF8
        if ($staleContent -match '- \[') {
            [void]$sb.AppendLine('---')
            [void]$sb.AppendLine('## DIGEST-STALE-WARNING')
            [void]$sb.AppendLine('')
            [void]$sb.AppendLine('Einige Digests sind stale (Quelle wurde editiert). Regeneration empfohlen vor Praezisions-Arbeit:')
            [void]$sb.AppendLine('')
            [void]$sb.AppendLine($staleContent)
            [void]$sb.AppendLine('')
        }
    }

    # --- Recent Lint-Violations (letzte 20) ---
    $lintPath = 'C:/ARK CRM/wiki/meta/lint-violations.md'
    if (Test-Path $lintPath) {
        $lintContent = Get-Content $lintPath -Raw -Encoding UTF8
        # Count sessions (## headers)
        $sessionCount = ([regex]::Matches($lintContent, '(?m)^## \[')).Count
        if ($sessionCount -gt 0) {
            [void]$sb.AppendLine('---')
            [void]$sb.AppendLine('## RECENT LINT-VIOLATIONS')
            [void]$sb.AppendLine('')
            [void]$sb.AppendLine("Total Sessions mit Violations: $sessionCount. Vollstaendig: ``wiki/meta/lint-violations.md``.")
            [void]$sb.AppendLine('')
            # Tail: last ~50 lines
            $lintLines = $lintContent -split "`n"
            $tailStart = [Math]::Max(0, $lintLines.Count - 50)
            [void]$sb.AppendLine(($lintLines[$tailStart..($lintLines.Count - 1)] -join "`n"))
            [void]$sb.AppendLine('')
        }
    }

    $output = @{
        hookSpecificOutput = @{
            hookEventName = 'SessionStart'
            additionalContext = $sb.ToString()
        }
        suppressOutput = $true
    }

    $output | ConvertTo-Json -Depth 10 -Compress
    exit 0
}
catch {
    [Console]::Error.WriteLine("load-grundlagen hook error: $_")
    exit 0
}
