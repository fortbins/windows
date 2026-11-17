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