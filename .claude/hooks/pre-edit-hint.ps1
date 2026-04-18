# Pre-Edit-Hint Hook (PreToolUse)
# Emits a non-blocking reminder of relevant skills/rules before Edit/Write
# on critical paths (mockups/*.html, specs/ARK_*.md, Grundlagen MD/ARK_*.md).
# Output goes to additionalContext so assistant sees it in-turn.

$ErrorActionPreference = 'Stop'

try {
    $raw = [Console]::In.ReadToEnd()
    if (-not $raw) { exit 0 }

    $json = $raw | ConvertFrom-Json
    $tool = $json.tool_name
    $path = $json.tool_input.file_path

    if (-not $path) { exit 0 }
    $pathNorm = $path -replace '\\', '/'

    $hints = @()

    # Mockups -- full lint/drift checks apply
    if ($pathNorm -match '/mockups/.+\.html$') {
        $hints += '**Mockup-Edit** -> pruefe: Drawer 540px (nicht Modal), Stage-Pipeline 9 Dots, Umlaute echt, keine dim_*/fact_*/bridge_* in UI-Texten, Stammdaten-Begriffe aus STAMMDATEN v1.3'
        $hints += '**Baseline-Snippets:** ``wiki/meta/mockup-baseline.md`` -- copy-paste ready statt neu erfinden'
    }

    # Specs
    if ($pathNorm -match '/specs/ARK_.+\.md$') {
        $hints += '**Spec-Edit** -> Spec-Sync-Regel: nach Commit 5 Grundlagen-Digests gegenlesen (STAMMDATEN, DATABASE_SCHEMA, BACKEND_ARCH, FRONTEND_FREEZE, GESAMTSYSTEM)'
        $hints += 'Bei Enum/Stage/Endpoint-Aenderung: zusaetzlich 9 Detailmasken-Specs pruefen (wiki/meta/spec-sync-regel.md)'
    }

    # Grundlagen MD
    if ($pathNorm -match 'Grundlagen[\s_]MD/ARK_.+\.md$') {
        $hints += '**GRUNDLAGEN-Edit (CRITICAL)** -> digest wird automatisch stale geflaggt (wiki/meta/digests/STALE.md). Nach Commit: Digest regenerieren via Agent.'
        $hints += 'Sync-Kaskade: 9 Detailmasken-Specs + Mockups pruefen.'
    }

    # Wiki (non-meta)
    if ($pathNorm -match '/wiki/(sources|entities|concepts|analyses)/' -and $pathNorm -match '\.md$') {
        $hints += '**Wiki-Edit** -> Umlaute echt. Wikilinks ``[[Page Title]]``. index.md + log.md aktualisieren.'
    }

    # Memory
    if ($pathNorm -match '/\.claude/projects/.+/memory/.+\.md$') {
        $hints += '**Memory-Edit** -> Frontmatter (name/description/type). MEMORY.md-Index aktualisieren wenn neue Datei.'
    }

    # Large-file backup reminder
    if (Test-Path $path) {
        $size = (Get-Item $path).Length
        if ($size -gt 5000) {
            $hints += "**Datei >5KB ($([Math]::Round($size/1024,1))KB)** -> VOR Edit Backup nach ``backups/`` (Datei-Schutz-Regel CLAUDE.md)."
        }
    }

    if ($hints.Count -eq 0) { exit 0 }

    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine('# Pre-Edit-Hints')
    [void]$sb.AppendLine('')
    foreach ($h in $hints) {
        [void]$sb.AppendLine("- $h")
    }

    $output = @{
        hookSpecificOutput = @{
            hookEventName = 'PreToolUse'
            additionalContext = $sb.ToString()
        }
    }

    $output | ConvertTo-Json -Depth 10 -Compress
    exit 0
}
catch {
    [Console]::Error.WriteLine("pre-edit-hint hook error: $_")
    exit 0
}
