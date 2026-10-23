$ErrorActionPreference = 'Stop'

# Always operate on the repository folder containing this script, not on an arbitrary current directory.
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$index = Join-Path $root 'index.html'
if (-not (Test-Path -LiteralPath $index -PathType Leaf)) {
    throw 'Run this script from the dimarus222.github.io repository root, or keep it in that root. index.html was not found.'
}

$content = [System.IO.File]::ReadAllText($index)
$headClose = $content.IndexOf('</head>', [System.StringComparison]::OrdinalIgnoreCase)
if ($headClose -lt 0) {
    throw 'The root index.html has no </head> tag. No changes were written.'
}

# Find each link element, then inspect its rel attribute. This avoids fragile quote escaping
# in a single large regex (the previous version failed to parse in Windows PowerShell).
$linkPattern = '(?is)<link\b[^>]*>'
$relPattern = '(?is)\brel\s*=\s*(?:"([^"]*)"|''([^'']*)''|([^\s/>]+))'
$links = [System.Text.RegularExpressions.Regex]::Matches($content, $linkPattern)
$oldIconTags = @()

foreach ($linkMatch in $links) {
    $tag = $linkMatch.Value
    $relMatch = [System.Text.RegularExpressions.Regex]::Match($tag, $relPattern)
    if (-not $relMatch.Success) { continue }

    $relValue = ''
    if ($relMatch.Groups[1].Success) {
        $relValue = $relMatch.Groups[1].Value
    } elseif ($relMatch.Groups[2].Success) {
        $relValue = $relMatch.Groups[2].Value
    } elseif ($relMatch.Groups[3].Success) {
        $relValue = $relMatch.Groups[3].Value
    }

    if ($relValue -match '(?i)(^|\s)(icon|apple-touch-icon|mask-icon)(\s|$)') {
        $oldIconTags += $tag
    }
}

# Remove only icon-related link tags; preserve the redirect, verification tags, scripts and other markup.
foreach ($tag in $oldIconTags) {
    $content = $content.Replace($tag, '')
}

$block = @'
<link rel="icon" href="https://dimarus222.github.io/favicon.svg" type="image/svg+xml">
<link rel="icon" href="https://dimarus222.github.io/favicon.png" type="image/png" sizes="128x128">
<link rel="shortcut icon" href="https://dimarus222.github.io/favicon.ico" type="image/x-icon">
<link rel="apple-touch-icon" href="https://dimarus222.github.io/apple-touch-icon.png" sizes="180x180">
'@

$headClose = $content.IndexOf('</head>', [System.StringComparison]::OrdinalIgnoreCase)
$content = $content.Insert($headClose, $block + "`r`n")
$encoding = New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false
[System.IO.File]::WriteAllText($index, $content, $encoding)

Write-Host 'Root favicon links installed successfully.' -ForegroundColor Green
Write-Host 'Only favicon link tags were replaced. Existing redirect and all other HTML content were preserved.' -ForegroundColor Green
