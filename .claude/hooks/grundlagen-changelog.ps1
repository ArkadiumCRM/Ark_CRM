# Grundlagen-Changelog Hook
# Logs Edit/Write operations on Grundlagen MD/ARK_*.md to wiki/meta/grundlagen-changelog.md
# Additionally flags corresponding digest as stale in wiki/meta/digests/STALE.md
# Triggered by PostToolUse hook matching Edit|Write

$ErrorActionPreference = 'Stop'

try {
    $raw = [Console]::In.ReadToEnd()
    if (-not $raw) { exit 0 }

    $json = $raw | ConvertFrom-Json
    $tool = $json.tool_name
    $path = $json.tool_input.file_path

    if (-not $path) { exit 0 }

    # Match Grundlagen files in Grundlagen MD/ (current canonical location)
    # Also still match raw/Ark_CRM_v2/ for legacy edits in archive
    $isGrundlagen = ($path -match 'Grundlagen[\s_]MD[\\/]+ARK_.*\.md$') -or `
                    ($path -match 'raw[\\/]+Ark_CRM_v2[\\/]+ARK_.*\.md$')
    if (-not $isGrundlagen) { exit 0 }

    # Skip non-Grundlagen (BKP, project-guideline, etc.)
    $fname = Split-Path -Leaf $path
    $allowed = @(
        'ARK_STAMMDATEN_EXPORT',
        'ARK_DATABASE_SCHEMA',
        'ARK_BACKEND_ARCHITECTURE',
        'ARK_FRONTEND_FREEZE',
        'ARK_GESAMTSYSTEM_UEBERSICHT'
    )
    $matchedPrefix = $null
    foreach ($prefix in $allowed) {
        if ($fname -like "$prefix*") { $matchedPrefix = $prefix; break }
    }
    if (-not $matchedPrefix) { exit 0 }

    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm'
    $sid = if ($json.session_id) { $json.session_id.Substring(0, [Math]::Min(8, $json.session_id.Length)) } else { 'unknown' }

    # --- 1. Append to grundlagen-changelog.md ---
    $logPath = 'C:/ARK CRM/wiki/meta/grundlagen-changelog.md'

    $entry = @"

## [$ts] session-$sid
- **File:** $fname
- **Tool:** $tool
- **Status:** unresolved
- **Sync-Check:** -- pending --
- **Resolved-In:** -- (fill when specs/mockups nachgezogen) --
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)
"@

    Add-Content -Path $logPath -Value $entry -Encoding UTF8

    # --- 2. Flag corresponding digest as stale ---
    $digestMap = @{
        'ARK_STAMMDATEN_EXPORT'       = 'stammdaten-digest.md'
        'ARK_DATABASE_SCHEMA'         = 'database-schema-digest.md'
        'ARK_BACKEND_ARCHITECTURE'    = 'backend-architecture-digest.md'
        'ARK_FRONTEND_FREEZE'         = 'frontend-freeze-digest.md'
        'ARK_GESAMTSYSTEM_UEBERSICHT' = 'gesamtsystem-digest.md'
    }
    $staleDigest = $digestMap[$matchedPrefix]
    $stalePath = 'C:/ARK CRM/wiki/meta/digests/STALE.md'

    # Append stale-flag (deduplicate on same digest + same day)
    $today = Get-Date -Format 'yyyy-MM-dd'
    $staleEntry = "- [$today $ts] ``$staleDigest`` stale -- source ``$fname`` edited (session-$sid)"

    $existing = if (Test-Path $stalePath) { Get-Content $stalePath -Raw -Encoding UTF8 } else { "# Stale Digests`n`nDigests in ``wiki/meta/digests/`` that need regeneration because their source Grundlagen MD was edited.`n`n" }
    # Dedup: skip if same digest already flagged today
    if ($existing -notmatch [regex]::Escape("[$today") + '.*' + [regex]::Escape($staleDigest)) {
        Add-Content -Path $stalePath -Value $staleEntry -Encoding UTF8
    }

    exit 0
}
catch {
    # Never block tool execution -- log silently to stderr
    [Console]::Error.WriteLine("grundlagen-changelog hook error: $_")
    exit 0
}
