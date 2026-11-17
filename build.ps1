$ErrorActionPreference = 'Stop'
$Version = '1.0.3'
$root = $PSScriptRoot

$mainPath = Join-Path $root 'main.ps1'
$downloadPath = Join-Path $root 'download.ps1'
$outPath = Join-Path $root 's.ps1'

$main = [IO.File]::ReadAllText($mainPath, [Text.Encoding]::UTF8)
$download = [IO.File]::ReadAllText($downloadPath, [Text.Encoding]::UTF8)

if ($download -match "(?m)^'@") {
    throw "download.ps1 cannot be embedded"
}

$bundle = @(
    "# Root-Flow Downloader v$Version | built $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    "`$EmbeddedScript = @'"
    $download.TrimEnd()
    "'@"
    ""
    $main.TrimStart()
) -join "`r`n"

[IO.File]::WriteAllText($outPath, $bundle, [System.Text.UTF8Encoding]::new($true))