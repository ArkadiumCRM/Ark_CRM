# Ark-Lint Hook (PostToolUse)
# Scans files after Edit/Write for:
#   - Umlaut-Ersatz-Patterns (ae/oe/ue where real Umlaut expected)
#   - DB-Tech-Details in UI-facing files (dim_/fact_/bridge_/_id/_fk in mockups)
#   - Modal statt Drawer (HTML <dialog> or class="modal" in CRUD contexts)
# Writes violations to wiki/meta/lint-violations.md (append, rolling)
# Non-blocking — never fails tool execution.

$ErrorActionPreference = 'Stop'

try {
    $raw = [Console]::In.ReadToEnd()
    if (-not $raw) { exit 0 }

    $json = $raw | ConvertFrom-Json
    $tool = $json.tool_name
    $path = $json.tool_input.file_path

    if (-not $path) { exit 0 }
    if (-not (Test-Path $path)) { exit 0 }

    # Normalize path
    $pathNorm = $path -replace '\\', '/'

    # Classify file type for scope-appropriate checks
    $isMockup = $pathNorm -match '/mockups/.+\.html$'
    $isSpec   = $pathNorm -match '/specs/.+\.md$'
    $isWiki   = $pathNorm -match '/wiki/.+\.md$'
    $isCode   = $pathNorm -match '\.(js|ts|tsx|jsx|py)$'
    $isMd     = $pathNorm -match '\.md$'

    # Skip files that are neither mockup/spec/wiki/code/md
    if (-not ($isMockup -or $isSpec -or $isWiki -or $isCode -or $isMd)) { exit 0 }

    # Skip digests and changelog and STALE (they reference DB terms legitimately)
    if ($pathNorm -match '/wiki/meta/digests/') { exit 0 }
    if ($pathNorm -match '/wiki/meta/grundlagen-changelog\.md$') { exit 0 }
    if ($pathNorm -match '/wiki/meta/lint-violations\.md$') { exit 0 }

    $content = Get-Content $path -Raw -Encoding UTF8
    if (-not $content) { exit 0 }
    $lines = $content -split "`n"

    # --- Skip-Range-Detection via <!-- ark-lint-skip:begin / :end --> Markers ---
    # Erlaubt Admin/Debug/Saga-Sektionen bewusst auszuklammern.
    # Beispiel: <!-- ark-lint-skip:begin reason=admin-saga-preview --> ... <!-- ark-lint-skip:end -->
    $skipRanges = @()
    $skipStart = -1
    for ($si = 0; $si -lt $lines.Count; $si++) {
        $hasBegin = $lines[$si] -match '<!--\s*ark-lint-skip:begin'
        $hasEnd   = $lines[$si] -match '<!--\s*ark-lint-skip:end'
        if ($hasBegin -and $hasEnd) {
            # Inline: begin + end auf gleicher Zeile → nur diese Zeile skippen
            $skipRanges += ,@($si, $si)
        } elseif ($hasBegin) {
            $skipStart = $si
        } elseif ($hasEnd) {
            if ($skipStart -ge 0) {
                $skipRanges += ,@($skipStart, $si)
                $skipStart = -1
            }
        }
    }
    function Test-InSkipRange { param($LineIdx, $Ranges)
        foreach ($r in $Ranges) { if ($LineIdx -ge $r[0] -and $LineIdx -le $r[1]) { return $true } }
        return $false
    }

    $violations = @()

    # --- 1. Umlaut-Ersatz-Patterns ---
    # Unicode char codes: ae=0xE4, oe=0xF6, ue=0xFC, AE=0xC4, OE=0xD6, UE=0xDC, ss=0xDF
    $ue = [char]0xFC; $oe = [char]0xF6; $ae = [char]0xE4
    $umlautPatterns = @(
        @{ Pat = '\bfuer\b';        Fix = "f${ue}r" },
        @{ Pat = '\bueber\b';       Fix = "${ue}ber" },
        @{ Pat = '\bkoenn';         Fix = "k${oe}nn" },
        @{ Pat = '\bmuess';         Fix = "m${ue}ss" },
        @{ Pat = '\bwaehren';       Fix = "w${ae}hren" },
        @{ Pat = '\bnaechst';       Fix = "n${ae}chst" },
        @{ Pat = '\blaenge\b';      Fix = "L${ae}nge" },
        @{ Pat = '\bkuerzel\b';     Fix = "K${ue}rzel" },
        @{ Pat = '\bgeloescht\b';   Fix = "gel${oe}scht" },
        @{ Pat = '\bspaet';         Fix = "sp${ae}t" },
        @{ Pat = '\bfruehe?\b';     Fix = "fr${ue}he" },
        @{ Pat = '\bmoeglich';      Fix = "m${oe}glich" },
        @{ Pat = '\bverfuegb';      Fix = "verf${ue}gb" },
        @{ Pat = '\bgroess';        Fix = "gr${oe}ss" },
        @{ Pat = '\bauftraeg';      Fix = "auftr${ae}g" },
        @{ Pat = '\btraeger';       Fix = "tr${ae}ger" },
        @{ Pat = '\bzurueck';       Fix = "zur${ue}ck" },
        @{ Pat = '\btueftelt?';     Fix = "t${ue}ftel" },
        @{ Pat = '\bpruefen?';      Fix = "pr${ue}fen" }
    )

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        # Skip obvious code lines (import/require/comments-only)
        if ($line -match '^\s*(//|#|\*|import |from |require\(|<!--)') { continue }
        # Skip lines inside <!-- ark-lint-skip:begin/end --> ranges
        if (Test-InSkipRange -LineIdx $i -Ranges $skipRanges) { continue }

        $seenOnLine = @{}
        foreach ($p in $umlautPatterns) {
            if ($line -cmatch $p.Pat) {
                # Dedup: only one violation per line per pattern
                $key = "$($i+1)-$($p.Pat)"
                if ($seenOnLine.ContainsKey($key)) { continue }
                $seenOnLine[$key] = $true
                $trimmed = $line.Trim()
                if ($trimmed.Length -gt 80) { $trimmed = $trimmed.Substring(0, 80) + '...' }
                $violations += "UMLAUT | $($i+1) | $trimmed | -> $($p.Fix)"
            }
        }
    }

    # --- 2. DB-Tech-Details in UI files (mockups only -- specs/wiki allowed) ---
    if ($isMockup) {
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            # Skip JS code within script tags (heuristic: lines starting with whitespace + JS keywords)
            if ($line -match '^\s*(const|let|var|function|if|for|while|return|\/\/|\/\*)') { continue }
            # Skip data-attributes used for wiring (data-table-id etc. are fine in HTML)
            if ($line -match 'data-[a-z-]+=') { continue }
            # Skip lines inside <!-- ark-lint-skip:begin/end --> ranges
            if (Test-InSkipRange -LineIdx $i -Ranges $skipRanges) { continue }

            # Scan for dim_/fact_/bridge_ in user-visible text (between > and < or inside text attributes)
            if ($line -match '>[^<]*\b(dim_|fact_|bridge_)[a-z_]+\b[^<]*<') {
                $snippet = $line.Trim()
                if ($snippet.Length -gt 80) { $snippet = $snippet.Substring(0, 80) + '...' }
                $violations += "DB-TECH | $($i+1) | $snippet | -> use sprechenden Begriff"
            }
            # Scan for _id / _fk as visible label (aria-label, title, placeholder, text content)
            if ($line -match '(title|aria-label|placeholder)="[^"]*\b\w+_(id|fk)\b') {
                $snippet = $line.Trim()
                if ($snippet.Length -gt 80) { $snippet = $snippet.Substring(0, 80) + '...' }
                $violations += "DB-TECH | $($i+1) | $snippet | -> use Entity-Name"
            }

            # dim_/fact_/bridge_ auch in title/aria-label/placeholder (nicht nur Text-Content)
            if ($line -match '(title|aria-label|placeholder)="[^"]*\b(dim_|fact_|bridge_)[a-z_]+') {
                $snippet = $line.Trim()
                if ($snippet.Length -gt 80) { $snippet = $snippet.Substring(0, 80) + '...' }
                $violations += "DB-TECH | $($i+1) | $snippet | -> use sprechenden Begriff in Attribut"
            }

            # --- 2b. snake_case-Identifier in <code> Tags (Enum-Codes, Event-Types, DB-Columns) ---
            # Fangt: <code>email_dossier</code>, <code>stage_changed</code>, <code>fact_history</code>, etc.
            # dim_/fact_/bridge_ sind schon oben erfasst - hier der Rest
            if ($line -match '<code>[a-z][a-z0-9]*(_[a-z][a-z0-9_]*)+</code>' -and `
                $line -notmatch '<code>(dim_|fact_|bridge_)') {
                $snippet = $line.Trim()
                if ($snippet.Length -gt 80) { $snippet = $snippet.Substring(0, 80) + '...' }
                $violations += "SNAKE-CASE | $($i+1) | $snippet | -> sprechenden Begriff statt snake_case-Identifier"
            }

            # --- 2c. Route-Template-Placeholders /entity/[id] in UI-Text ---
            # Fangt: /processes/[id], /mandates/[id], /groups/[id], /accounts/[slug] etc.
            if ($line -match '/[a-z]+/\[(id|uuid|slug)\]') {
                $snippet = $line.Trim()
                if ($snippet.Length -gt 80) { $snippet = $snippet.Substring(0, 80) + '...' }
                $violations += "ROUTE-TMPL | $($i+1) | $snippet | -> sprechende Bezeichnung (z.B. ''Mandat-Vollansicht'')"
            }

            # --- 2d. snake_case mit 2+ Underscores in User-Attributes (title/aria-label/onclick/alert/confirm) ---
            # Fangt z.B. title="Klick oeffnet fact_history-Event" oder alert('Activity-Type: stage_changed + status_changed')
            # Dreigliedriges snake_case ist fast immer technisch (company_participation_added)
            if ($line -match '(title|aria-label|placeholder)="[^"]*\b[a-z][a-z0-9]+_[a-z][a-z0-9]+_[a-z][a-z0-9_]+\b[^"]*"') {
                $snippet = $line.Trim()
                if ($snippet.Length -gt 80) { $snippet = $snippet.Substring(0, 80) + '...' }
                $violations += "SNAKE-CASE | $($i+1) | $snippet | -> deutsches Label statt snake_case in Attribut"
            }
            if ($line -match "(alert|confirm)\([`"']+[^`"']*\b[a-z][a-z0-9]+_[a-z][a-z0-9]+_[a-z][a-z0-9_]+\b") {
                $snippet = $line.Trim()
                if ($snippet.Length -gt 80) { $snippet = $snippet.Substring(0, 80) + '...' }
                $violations += "SNAKE-CASE | $($i+1) | $snippet | -> deutsches Label statt snake_case in Alert/Confirm"
            }

            # --- 2e. Bekannte Enum-Values mit 1 Underscore in UI-Text (zweistufig aber klar DB-ish) ---
            # Nur explizit gelistete Patterns - Whitelist-Ansatz gegen False-Positives
            $knownEnumPatterns = 'email_dossier|verbal_meeting|claim_pending|matching_computed|stage_changed|status_changed|vakanz_confirmed|process_created|scraper_proposal|jobbasket_added|media_uploaded|document_uploaded|classification_changed|internal_notes_updated|bauherr_changed|needs_am_review|presentation_type|account_group_id'
            if ($line -match ">[^<]*\b($knownEnumPatterns)\b[^<]*<") {
                $snippet = $line.Trim()
                if ($snippet.Length -gt 80) { $snippet = $snippet.Substring(0, 80) + '...' }
                $violations += "SNAKE-CASE | $($i+1) | $snippet | -> deutsches Label fuer Enum-Value"
            }

            # --- 2f. Kebab-case technische Identifier in <em> / <code> Tags ---
            # Fangt: <em>audit-log-retention</em>, <em>mandat-kuendigung</em>
            # Natuerliche deutsche Wortkombinationen werden normalerweise ohne Bindestrich in <em> gesetzt
            if ($line -match '<(em|code)>(audit-log-retention|mandat-kuendigung|candidate-manager|account-manager)</(em|code)>') {
                $snippet = $line.Trim()
                if ($snippet.Length -gt 80) { $snippet = $snippet.Substring(0, 80) + '...' }
                $violations += "KEBAB-TECH | $($i+1) | $snippet | -> sprechende Beschreibung statt kebab-case-Identifier"
            }
        }

        # --- 3. Modal-for-CRUD (Drawer-Default-Regel) ---
        # Heuristic: HTML <dialog> element or class="modal" combined with form/CRUD keywords
        if ($content -match '<dialog' -or $content -match 'class="[^"]*\bmodal\b') {
            # Count occurrences
            $modalHits = ([regex]::Matches($content, '<dialog|class="[^"]*\bmodal\b')).Count
            # Crude check for CRUD context: form / input / submit in nearby lines
            if ($content -match '<form' -or $content -match 'input name=' -or $content -match 'Speichern|Anlegen|Erstellen|Bearbeiten') {
                $violations += "DRAWER-DEFAULT | -- | $modalHits Modal-Patterns gefunden | -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel)"
            }
        }
    }

    if ($violations.Count -eq 0) { exit 0 }

    # --- Write violations to log ---
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm'
    $sid = if ($json.session_id) { $json.session_id.Substring(0, [Math]::Min(8, $json.session_id.Length)) } else { 'unknown' }
    $fname = Split-Path -Leaf $path

    $logPath = 'C:/Projects/Ark_CRM/wiki/meta/lint-violations.md'

    $header = @"

## [$ts] session-$sid | $fname ($($violations.Count) Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
"@
    $rows = $violations | ForEach-Object { '| ' + ($_ -replace '\|', '\|') + ' |' }
    $entry = $header + "`n" + ($rows -join "`n") + "`n"

    Add-Content -Path $logPath -Value $entry -Encoding UTF8

    exit 0
}
catch {
    [Console]::Error.WriteLine("ark-lint hook error: $_")
    exit 0
}
