param([string]$GamePath = '', [switch]$NoLaunch)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Assert-GameClosed {
    foreach ($process in @(Get-Process -Name 'Last Epoch' -ErrorAction SilentlyContinue)) {
        if (!$process.Path -or [string]::Equals($process.Path, $gameExe, [StringComparison]::OrdinalIgnoreCase)) {
            throw 'Close Last Epoch through the game menu before updating.'
        }
    }
}
function Stream-Hash($stream) {
    $stream.Position = 0
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($stream))).Replace('-', '').ToLowerInvariant() }
    finally { $sha.Dispose(); $stream.Position = 0 }
}
function Write-Stream($source, $destination) {
    $inputFile = [IO.File]::OpenRead($source)
    try {
        $destination.Position = 0
        $destination.SetLength(0)
        $inputFile.CopyTo($destination)
        $destination.Flush($true)
    } finally { $inputFile.Dispose() }
}

if ([string]::IsNullOrWhiteSpace($GamePath)) {
    if (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'Last Epoch.exe')) { $GamePath = $PSScriptRoot }
    elseif (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'runtime\Last Epoch.exe')) { $GamePath = Join-Path $PSScriptRoot 'runtime' }
    else { $GamePath = Read-Host 'Enter the game folder containing Last Epoch.exe' }
}
$target = [IO.Path]::GetFullPath($GamePath.Trim().Trim('"'))
$gameExe = Join-Path $target 'Last Epoch.exe'
if (!(Test-Path -LiteralPath $gameExe)) { throw 'Last Epoch.exe not found.' }
Assert-GameClosed
if (!(Test-Path -LiteralPath (Join-Path $target 'version.dll')) -or !(Test-Path -LiteralPath (Join-Path $target 'MelonLoader\net6\MelonLoader.dll'))) {
    throw 'Install MelonLoader 0.7.3 x64 before using this updater.'
}
if ((Get-FileHash -LiteralPath (Join-Path $target 'GameAssembly.dll') -Algorithm SHA256).Hash -ne 'D5F9FB458F0E9878E697A92B590A586A52FD77E645F8BF87BB4F2B74C6C56567') {
    throw 'Unsupported game build. This updater supports Steam build 25816319 / Unity 6000.4.8f1.'
}

$stateRoot = Join-Path $target 'TM-Coop-Updater'
New-Item -ItemType Directory -Path $stateRoot -Force | Out-Null
$updateLock = $null
try {
    $updateLock = [IO.File]::Open((Join-Path $stateRoot 'update.lock'), [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
    $headers = @{ 'User-Agent' = 'TM-LastEpoch-Coop-Updater'; Accept = 'application/vnd.github+json'; 'X-GitHub-Api-Version' = '2022-11-28' }
    Write-Host 'Checking latest GitHub release...'
    $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/cielthephantom2/LastEpoch/releases/latest' -Headers $headers -TimeoutSec 30
    if ($release.draft -or $release.prerelease -or $release.tag_name -notmatch '^v\d+\.\d+\.\d+$') { throw 'Invalid stable release.' }
    $mapping = @(
        @{ Name = 'LastEpochLAN.dll'; Folder = 'Mods'; Assembly = 'LastEpochLAN' },
        @{ Name = 'LastEpoch_Hud.dll'; Folder = 'Mods'; Assembly = 'LastEpoch_Hud' },
        @{ Name = 'LastEpochLAN.Core.dll'; Folder = 'UserLibs'; Assembly = 'LastEpochLAN.Core' }
    )
    $records = @()
    foreach ($item in $mapping) {
        $assets = @($release.assets | Where-Object { $_.name -eq $item.Name })
        if ($assets.Count -ne 1) { throw "Missing or duplicate release asset: $($item.Name)" }
        $asset = $assets[0]
        $url = 'https://github.com/cielthephantom2/LastEpoch/releases/download/' + $release.tag_name + '/' + $item.Name
        if ($asset.state -ne 'uploaded' -or $asset.browser_download_url -cne $url -or $asset.digest -notmatch '^sha256:[a-fA-F0-9]{64}$' -or $asset.size -lt 1024 -or $asset.size -gt 33554432) {
            throw "Invalid download metadata: $($item.Name)"
        }
        $destination = Join-Path (Join-Path $target $item.Folder) $item.Name
        $expected = $asset.digest.Substring(7).ToLowerInvariant()
        $existed = Test-Path -LiteralPath $destination
        $changed = !$existed -or (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expected
        $records += [pscustomobject]@{ Name=$item.Name; Relative=($item.Folder + '\' + $item.Name); Destination=$destination;
            Hash=$expected; Size=$asset.size; Url=$url; Existed=$existed; Changed=$changed; Assembly=$item.Assembly; Source=''; Handle=$null; Dirty=$false }
    }
    $changes = @($records | Where-Object Changed)
    $backup = ''
    if ($changes.Count -gt 0) {
        $stamp = (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [Guid]::NewGuid().ToString('N').Substring(0,8)
        $stage = Join-Path $stateRoot ('downloads\' + $stamp)
        $backup = Join-Path $target ('TM-Coop-Backups\auto-' + $stamp)
        New-Item -ItemType Directory -Path $stage -Force | Out-Null
        foreach ($record in $changes) {
            Write-Host "Downloading $($record.Name)..."
            $record.Source = Join-Path $stage $record.Name
            Invoke-WebRequest -Uri $record.Url -Headers @{ 'User-Agent'='TM-LastEpoch-Coop-Updater' } -OutFile $record.Source -UseBasicParsing -TimeoutSec 120
            if ((Get-Item -LiteralPath $record.Source).Length -ne $record.Size -or
                (Get-FileHash -LiteralPath $record.Source -Algorithm SHA256).Hash.ToLowerInvariant() -ne $record.Hash -or
                [Reflection.AssemblyName]::GetAssemblyName($record.Source).Name -ne $record.Assembly) {
                throw "Downloaded DLL verification failed: $($record.Name)"
            }
            if ($record.Name -eq 'LastEpochLAN.dll' -and [Reflection.AssemblyName]::GetAssemblyName($record.Source).Version.ToString(3) -ne $release.tag_name.Substring(1)) {
                throw 'Co-op DLL version does not match the release tag.'
            }
        }
        Assert-GameClosed
        $failure = $null
        try {
            # Keep all existing DLLs exclusively locked through backup, update
            # and rollback; no file is changed before every lock is obtained.
            foreach ($record in $records) {
                New-Item -ItemType Directory -Path ([IO.Path]::GetDirectoryName($record.Destination)) -Force | Out-Null
                $mode = if ($record.Existed) { [IO.FileMode]::Open } else { [IO.FileMode]::CreateNew }
                $record.Handle = [IO.File]::Open($record.Destination, $mode, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
            }
            foreach ($record in $changes | Where-Object Existed) {
                $saved = Join-Path $backup $record.Relative
                New-Item -ItemType Directory -Path ([IO.Path]::GetDirectoryName($saved)) -Force | Out-Null
                $outputFile = [IO.File]::Open($saved, [IO.FileMode]::CreateNew)
                try { $record.Handle.Position=0; $record.Handle.CopyTo($outputFile) } finally { $outputFile.Dispose(); $record.Handle.Position=0 }
            }
            foreach ($record in $changes) {
                $record.Dirty = $true
                Write-Stream $record.Source $record.Handle
                if ((Stream-Hash $record.Handle) -ne $record.Hash) { throw "Installed hash mismatch: $($record.Name)" }
            }
        } catch {
            $failure = $_
            $rollbackErrors = @()
            foreach ($record in $changes | Where-Object { $_.Dirty -and $_.Existed }) {
                try { Write-Stream (Join-Path $backup $record.Relative) $record.Handle }
                catch { $rollbackErrors += $_.Exception.Message }
            }
            if ($rollbackErrors.Count -gt 0) { $failure = "Update failed; restore DLLs from $backup. Rollback errors: $($rollbackErrors -join '; ')" }
        } finally {
            foreach ($record in $records) { if ($null -ne $record.Handle) { $record.Handle.Dispose() } }
            if ($null -ne $failure) {
                foreach ($record in $records | Where-Object { !$_.Existed -and $null -ne $_.Handle }) {
                    if (Test-Path -LiteralPath $record.Destination) { Remove-Item -LiteralPath $record.Destination -Force }
                }
            }
        }
        if ($null -ne $failure) { throw $failure }
        Write-Host "Updated to $($release.tag_name). Previous DLLs: $backup"
    } else { Write-Host "Already up to date: $($release.tag_name)." }
    @{ Version=$release.tag_name; UpdatedUtc=[DateTime]::UtcNow.ToString('o'); Backup=$backup;
        Files=@($records | Select-Object Relative,Hash) } | ConvertTo-Json -Depth 4 |
        Set-Content -LiteralPath (Join-Path $stateRoot 'last-update.json') -Encoding UTF8
    if (!$NoLaunch) {
        Assert-GameClosed
        Write-Host 'Starting game. Choose Play Offline. F4: co-op; F3: Host LE HUD.'
        Start-Process -FilePath $gameExe -WorkingDirectory $target -ArgumentList @('--offline', '--melonloader.agfoffline')
    }
} finally { if ($null -ne $updateLock) { $updateLock.Dispose() } }
