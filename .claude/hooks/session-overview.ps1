# Session-Overview Hook
# Injects project status overview into Claude's context at session start.
# Claude formats it in Caveman-Lite style as part of first response.

$ErrorActionPreference = 'Stop'

try {
    $projectRoot = 'C:/Projects/Ark_CRM'

    # --- Project-local Skills ---
    $skillsDir = Join-Path $projectRoot '.claude/skills'
    $projectSkills = @()
    if (Test-Path $skillsDir) {
        $projectSkills = Get-ChildItem $skillsDir -Directory | ForEach-Object { $_.Name } | Sort-Object
    }

    # --- Project Slash Commands ---
    $cmdDir = Join-Path $projectRoot '.claude/commands'
    $projectCommands = @()
    if (Test-Path $cmdDir) {
        $projectCommands = Get-ChildItem $cmdDir -Filter '*.md' | ForEach-Object { '/' + $_.BaseName } | Sort-Object
    }

    # --- Plugins from user settings.json ---
    $plugins = @()
    $userSettingsPath = Join-Path $env:USERPROFILE '.claude/settings.json'
    if (Test-Path $userSettingsPath) {
        try {
            $userSettings = Get-Content $userSettingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($userSettings.enabledPlugins) {
                $plugins = @($userSettings.enabledPlugins.PSObject.Properties | Where-Object { $_.Value -eq $true } | ForEach-Object {
                    # Strip @source suffix for display
                    ($_.Name -split '@')[0]
                })
            }
        } catch { }
    }

    # --- MCPs from user .claude.json ---
    $mcps = @()
    $userConfigPath = Join-Path $env:USERPROFILE '.claude.json'
    if (Test-Path $userConfigPath) {
        try {
            $cfg = Get-Content $userConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($cfg.projects -and $cfg.projects.PSObject.Properties[$projectRoot]) {
                $proj = $cfg.projects.PSObject.Properties[$projectRoot].Value
                if ($proj.mcpServers) {
                    $mcps = @($proj.mcpServers.PSObject.Properties | ForEach-Object { $_.Name })
                }
            }
        } catch { }
    }

    # --- Unresolved Grundlagen-Changelog entries ---
    $changelogPath = Join-Path $projectRoot 'wiki/meta/grundlagen-changelog.md'
    $unresolved = 0
    $unresolvedEntries = @()
    if (Test-Path $changelogPath) {
        $content = Get-Content $changelogPath -Raw -Encoding UTF8

        # Split into entries by ## header
        $entries = [regex]::Split($content, '(?=^## \[)', 'Multiline')
        foreach ($entry in $entries) {
            if ($entry -notmatch '\*\*Status:\*\*\s*unresolved') { continue }
            $ts = if ($entry -match '## \[([0-9\-\s:]+)\]') { $matches[1].Trim() } else { '?' }
            $file = if ($entry -match '\*\*File:\*\*\s*(\S+)') { $matches[1].Trim() } else { '?' }
            $unresolvedEntries += [PSCustomObject]@{ Timestamp = $ts; File = $file }
        }
        $unresolved = $unresolvedEntries.Count
    }

    # Build detailed unresolved list if any
    $unresolvedDetail = ''
    if ($unresolved -gt 0) {
        $lines = foreach ($e in $unresolvedEntries) {
            # Suggest which specs/mockups to sync based on file type
            $suggest = switch -Wildcard ($e.File) {
                '*STAMMDATEN*'     { 'alle 9 Specs + Mockups mit Dropdowns/Filter' }
                '*DATABASE_SCHEMA*' { 'Entity-Specs (Schema) + Backend-Datei' }
                '*BACKEND_ARCH*'    { 'Interactions-Specs + Mockup-Drawer-Previews' }
                '*FRONTEND_FREEZE*' { 'alle Mockups' }
                '*GESAMTSYSTEM*'    { 'wiki/index.md + wiki/meta/overview.md' }
                default             { 'spec-sync-regel.md pruefen' }
            }
            "- ``$($e.File)`` @ $($e.Timestamp) -> sync: $suggest"
        }
        $unresolvedDetail = @"


### Offene Sync-Schulden ($unresolved)

$($lines -join "`n")

Tipp: ``/prime-ark`` fuehrt dich durch Sync-Review-Flow (Status a/b/c/d pro Eintrag).
"@
    }

    # --- Git-Branch (Detached-HEAD-Detection per drift-log [2026-04-20] Action #1) ---
    $gitBranch = '?'
    try {
        Push-Location $projectRoot
        $gitBranch = (& git rev-parse --abbrev-ref HEAD 2>$null).Trim()
        Pop-Location
        if (-not $gitBranch) { $gitBranch = '?' }
    } catch {
        try { Pop-Location } catch {}
        $gitBranch = '?'
    }

    $branchInfo = switch -Wildcard ($gitBranch) {
        'main'  { 'main OK' }
        'HEAD'  { '!!! DETACHED HEAD - bitte ``git checkout main`` ausfuehren vor Edits' }
        '?'     { '? (nicht erkennbar)' }
        default { "WARN: ``$gitBranch`` (nicht main - sicher dass beabsichtigt?)" }
    }

    $gitBranchWarning = ''
    if ($gitBranch -eq 'HEAD') {
        $gitBranchWarning = @"


### !!! DETACHED-HEAD-WARNUNG

Aktueller Git-State: **detached HEAD** - Commits gehen nicht auf einen Branch und koennen verloren gehen.

**Sofort ausfuehren vor jedem Edit:**
``````
git checkout main
``````

Hintergrund: 2026-04-20 ging Commit 89b367b in detached HEAD verloren. Recovery via Reflog erfolgreich, aber Wiederholung verhindern.
"@
    } elseif ($gitBranch -ne 'main' -and $gitBranch -ne '?') {
        $gitBranchWarning = @"


### Git-Branch-Hinweis

Aktiver Branch: ``$gitBranch`` (nicht main). OK wenn beabsichtigte Feature-Arbeit, sonst ``git checkout main``.
"@
    }

    # --- Active Hooks (from project settings) ---
    $settingsPath = Join-Path $projectRoot '.claude/settings.json'
    $activeHooks = @()
    if (Test-Path $settingsPath) {
        try {
            $settings = Get-Content $settingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($settings.hooks) {
                $activeHooks = @($settings.hooks.PSObject.Properties | ForEach-Object { $_.Name })
            }
        } catch { }
    }

    # --- Build overview ---
    $skillsList = if ($projectSkills.Count -gt 0) { ($projectSkills -join ', ') } else { '(none)' }
    $cmdList = if ($projectCommands.Count -gt 0) { ($projectCommands -join ', ') } else { '(none)' }
    $pluginList = if ($plugins.Count -gt 0) { ($plugins -join ', ') } else { '(none)' }
    $mcpList = if ($mcps.Count -gt 0) { ($mcps -join ', ') } else { '(none)' }
    $hookList = if ($activeHooks.Count -gt 0) { ($activeHooks -join ', ') } else { '(none)' }

    $overview = @"
## ARK Session Overview

**MCPs aktiv:** $mcpList
**Plugins:** $pluginList
**Projekt-Skills (8):** $skillsList
**Slash-Commands (projekt):** $cmdList
**Aktive Hooks:** $hookList
**Git-Branch:** $branchInfo
**Grundlagen-Changelog:** $unresolved unresolved$unresolvedDetail$gitBranchWarning

### Quick-Reference

| Was | Wie |
|-----|-----|
| Grundlagen preload | ``/prime-ark`` (~225k Tokens, cache-stabil) |
| Caveman umschalten | ``/caveman lite``, ``/caveman full``, ``stop caveman`` |
| Permission-Allowlist updaten | ``/less-permission-prompts`` |
| DB-Query (Supabase MCP) | ``"zeig ark-Schema Tabellen"`` -> nutzt Supabase MCP |
| Live Lib-Docs | ``"Context7 shadcn Drawer"`` -> nutzt Context7 MCP |

### Automatisch aktiv

- **Grundlagen-Edit** auf ``Grundlagen MD/ARK_*.md`` -> PostToolUse-Hook loggt in ``wiki/meta/grundlagen-changelog.md`` + flaggt Digest stale
- **Edit/Write** auf ``mockups/*.html``/``specs/*.md``/``wiki/*.md`` -> Auto-Lint (Umlaute/DB-Tech/Drawer-Default) schreibt nach ``wiki/meta/lint-violations.md``
- **PreToolUse** auf Edit/Write kritischer Pfade -> Skill-Reminder via ``pre-edit-hint.ps1``
- **SessionStart** laedt Digests + Anti-Patterns + Decisions + Mockup-Baseline (~55k Token)
- **Caveman-Lite** Kommunikations-Regeln (Statusline-Command konfiguriert)
- **Auto-Memory** schreibt in ``~/.claude/projects/.../memory/``

### Bei Session-Start immer pruefen

1. Unresolved Changelog-Eintraege -> ``/prime-ark`` fuehrt dich durch Sync-Check
2. Aktuelle Mockup-Arbeit -> Kontext-Budget planen (preload vs on-demand)

**INSTRUCTIONS-TO-MODEL:** Prepend this overview (as markdown) to your first assistant response in this session. Format in Caveman-Lite style if caveman mode aktiv, sonst normal. Nach Overview direkt zur User-Frage uebergehen.
"@

    # --- Output JSON ---
    $output = @{
        hookSpecificOutput = @{
            hookEventName = 'SessionStart'
            additionalContext = $overview
        }
        suppressOutput = $true
    }

    $output | ConvertTo-Json -Depth 10 -Compress
    exit 0
}
catch {
    [Console]::Error.WriteLine("session-overview hook error: $_")
    exit 0
}
