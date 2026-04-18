# ARK-Status Script
# Called by /ark-status slash command. Outputs plain markdown status to stdout.

$ErrorActionPreference = 'Stop'

try {
    $projectRoot = 'C:/ARK CRM'

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

    # --- Unresolved Changelog count + last entry ---
    $changelogPath = Join-Path $projectRoot 'wiki/meta/grundlagen-changelog.md'
    $unresolved = 0
    $lastEntry = '(keine Eintraege)'
    if (Test-Path $changelogPath) {
        $content = Get-Content $changelogPath -Raw -Encoding UTF8
        $unresolved = ([regex]::Matches($content, '\*\*Status:\*\*\s*unresolved')).Count
        $headers = [regex]::Matches($content, '## \[([0-9\-\s:]+)\]')
        if ($headers.Count -gt 0) {
            $lastEntry = $headers[$headers.Count - 1].Groups[1].Value
        }
    }

    # --- Active Hooks ---
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

    # --- Backups count ---
    $backupsDir = Join-Path $projectRoot 'backups'
    $backupCount = 0
    if (Test-Path $backupsDir) {
        $backupCount = (Get-ChildItem $backupsDir -Filter '*.bak' -ErrorAction SilentlyContinue).Count
    }

    # --- Format output ---
    $skillsList = if ($projectSkills.Count -gt 0) { ($projectSkills -join ', ') } else { '(none)' }
    $cmdList = if ($projectCommands.Count -gt 0) { ($projectCommands -join ', ') } else { '(none)' }
    $pluginList = if ($plugins.Count -gt 0) { ($plugins -join ', ') } else { '(none)' }
    $mcpList = if ($mcps.Count -gt 0) { ($mcps -join ', ') } else { '(none)' }
    $hookList = if ($activeHooks.Count -gt 0) { ($activeHooks -join ', ') } else { '(none)' }
    $now = Get-Date -Format 'yyyy-MM-dd HH:mm'

    Write-Output ""
    Write-Output "## ARK Status -- $now"
    Write-Output ""
    Write-Output "| Bereich | Wert |"
    Write-Output "|---------|------|"
    Write-Output "| MCPs aktiv | $mcpList |"
    Write-Output "| Plugins | $pluginList |"
    Write-Output "| Projekt-Skills ($($projectSkills.Count)) | $skillsList |"
    Write-Output "| Slash-Commands (projekt) | $cmdList |"
    Write-Output "| Aktive Hooks | $hookList |"
    Write-Output "| Changelog unresolved | $unresolved |"
    Write-Output "| Letzter Changelog-Eintrag | $lastEntry |"
    Write-Output "| Backups-Ordner | $backupCount Dateien |"

    exit 0
}
catch {
    Write-Error "ark-status error: $_"
    exit 1
}
