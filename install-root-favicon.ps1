$ErrorActionPreference = 'Stop'

# Windows PowerShell 5.1-compatible installer. Source is ASCII-only to avoid encoding/parser issues.
# This script updates only the root index.html <head>; it preserves the redirect/body after </head>.
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$indexPath = Join-Path $root 'index.html'
if (-not (Test-Path -LiteralPath $indexPath -PathType Leaf)) {
    throw 'index.html was not found beside this script. No files were changed.'
}

$rawBytes = [System.IO.File]::ReadAllBytes($indexPath)
$hasUtf8Bom = $false
if ($rawBytes.Length -ge 3 -and $rawBytes[0] -eq 239 -and $rawBytes[1] -eq 187 -and $rawBytes[2] -eq 191) {
    $hasUtf8Bom = $true
}
$content = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)
$headOpenMatch = [System.Text.RegularExpressions.Regex]::Match($content, '(?is)<head\b[^>]*>')
$headCloseIndex = $content.IndexOf('</head>', [System.StringComparison]::OrdinalIgnoreCase)
if (-not $headOpenMatch.Success -or $headCloseIndex -lt $headOpenMatch.Index) {
    throw 'index.html must contain <head> and </head>. No files were changed.'
}
$headContentStart = $headOpenMatch.Index + $headOpenMatch.Length
$head = $content.Substring($headContentStart, $headCloseIndex - $headContentStart)
$bodyAndTail = $content.Substring($headCloseIndex)

function Get-AttributeValue {
    param([string]$Tag, [string]$AttributeName)
    $escapedName = [System.Text.RegularExpressions.Regex]::Escape($AttributeName)
    $pattern = '(?is)\b' + $escapedName + '\s*=\s*"([^"]*)"'
    $m = [System.Text.RegularExpressions.Regex]::Match($Tag, $pattern)
    if (-not $m.Success) {
        $pattern = '(?is)\b' + $escapedName + '\s*=\s*\x27([^\x27]*)\x27'
        $m = [System.Text.RegularExpressions.Regex]::Match($Tag, $pattern)
    }
    if (-not $m.Success) { return '' }
    return $m.Groups[1].Value
}

function Set-HeadTagByAttribute {
    param(
        [string]$HeadText,
        [string]$TagName,
        [string]$AttributeName,
        [string]$AttributeValue,
        [string]$Replacement
    )
    $tagPattern = '(?is)<' + [System.Text.RegularExpressions.Regex]::Escape($TagName) + '\b[^>]*>'
    $tagMatches = [System.Text.RegularExpressions.Regex]::Matches($HeadText, $tagPattern)
    $selected = @()
    foreach ($tagMatch in $tagMatches) {
        $value = Get-AttributeValue -Tag $tagMatch.Value -AttributeName $AttributeName
        if ([System.String]::Equals($value, $AttributeValue, [System.StringComparison]::OrdinalIgnoreCase)) {
            $selected += $tagMatch
        }
    }
    if ($selected.Count -eq 0) {
        return ($HeadText.TrimEnd() + [Environment]::NewLine + $Replacement + [Environment]::NewLine)
    }
    $keepIndex = $selected[0].Index
    for ($i = $selected.Count - 1; $i -ge 0; $i--) {
        $selectedMatch = $selected[$i]
        if ($selectedMatch.Index -eq $keepIndex) {
            $HeadText = $HeadText.Remove($selectedMatch.Index, $selectedMatch.Length).Insert($selectedMatch.Index, $Replacement)
        } else {
            $HeadText = $HeadText.Remove($selectedMatch.Index, $selectedMatch.Length)
        }
    }
    return $HeadText
}

# Replace exactly one title tag and remove duplicate titles.
$titlePattern = '(?is)<title\b[^>]*>.*?</title\s*>'
$titleMatches = [System.Text.RegularExpressions.Regex]::Matches($head, $titlePattern)
$titleReplacement = '<title>HAPPY-pedia RevolGC - R2 Online Guide / &#1057;&#1087;&#1088;&#1072;&#1074;&#1086;&#1095;&#1085;&#1080;&#1082; R2 Online</title>'
if ($titleMatches.Count -eq 0) {
    $head = $head.TrimEnd() + [Environment]::NewLine + $titleReplacement + [Environment]::NewLine
} else {
    $keepTitleIndex = $titleMatches[0].Index
    for ($i = $titleMatches.Count - 1; $i -ge 0; $i--) {
        $titleMatch = $titleMatches[$i]
        if ($titleMatch.Index -eq $keepTitleIndex) {
            $head = $head.Remove($titleMatch.Index, $titleMatch.Length).Insert($titleMatch.Index, $titleReplacement)
        } else {
            $head = $head.Remove($titleMatch.Index, $titleMatch.Length)
        }
    }
}

$canonical = 'https://dimarus222.github.io/ZlKonstantin/'
$description = 'HAPPY-pedia &#8212; &#1089;&#1087;&#1088;&#1072;&#1074;&#1086;&#1095;&#1085;&#1080;&#1082; R2 Online / RevolGC: &#1092;&#1072;&#1088;&#1084;, &#1076;&#1088;&#1086;&#1087;, &#1082;&#1072;&#1083;&#1100;&#1082;&#1091;&#1083;&#1103;&#1090;&#1086;&#1088; &#1055;&#1058;&#1057;, &#1087;&#1080;&#1090;&#1086;&#1084;&#1094;&#1099;, &#1086;&#1088;&#1091;&#1078;&#1080;&#1077;, &#1073;&#1080;&#1078;&#1091;&#1090;&#1077;&#1088;&#1080;&#1103; &#1080; &#1089;&#1092;&#1077;&#1088;&#1099;. Founder: ZLKonstantin; developer and SEO: Dmitry Zhdanov (STALKER); supporter: wLIRw. R2 Online guide &amp; item database.'
$author = 'HAPPY-pedia team: ZLKonstantin (founder); Dmitry Zhdanov / STALKER (developer and SEO); wLIRw (supporter and streamer).'
$keywords = 'HAPPY-pedia, HAPPY-pedia RevolGC, HAPPY Pedia, HAPPY-pedia R2 Online, R2 Online guide, R2 Online wiki, RevolGC guide, R2 Online database, R2 Online item database, farming locations, PTS calculator, pets, weapons, jewelry, spheres, ZLKonstantin founder, Dmitry Zhdanov STALKER developer, wLIRw, &#1093;&#1101;&#1087;&#1087;&#1080; &#1087;&#1077;&#1076;&#1080;&#1103;, &#1093;&#1077;&#1087;&#1087;&#1080; &#1087;&#1077;&#1076;&#1080;&#1103;, &#1089;&#1087;&#1088;&#1072;&#1074;&#1086;&#1095;&#1085;&#1080;&#1082; R2 Online, &#1089;&#1087;&#1088;&#1072;&#1074;&#1086;&#1095;&#1085;&#1080;&#1082; &#1056;2, &#1089;&#1087;&#1088;&#1072;&#1074;&#1086;&#1095;&#1085;&#1080;&#1082; RevolGC, &#1082;&#1072;&#1083;&#1100;&#1082;&#1091;&#1083;&#1103;&#1090;&#1086;&#1088; &#1055;&#1058;&#1057;'

$head = Set-HeadTagByAttribute -HeadText $head -TagName 'meta' -AttributeName 'name' -AttributeValue 'description' -Replacement ('<meta name="description" content="' + $description + '">')
$head = Set-HeadTagByAttribute -HeadText $head -TagName 'meta' -AttributeName 'name' -AttributeValue 'author' -Replacement ('<meta name="author" content="' + $author + '">')
$head = Set-HeadTagByAttribute -HeadText $head -TagName 'meta' -AttributeName 'name' -AttributeValue 'keywords' -Replacement ('<meta name="keywords" content="' + $keywords + '">')
$head = Set-HeadTagByAttribute -HeadText $head -TagName 'meta' -AttributeName 'name' -AttributeValue 'robots' -Replacement '<meta name="robots" content="index,follow,max-image-preview:large">'
$head = Set-HeadTagByAttribute -HeadText $head -TagName 'meta' -AttributeName 'name' -AttributeValue 'googlebot' -Replacement '<meta name="googlebot" content="index,follow,max-image-preview:large">'
$head = Set-HeadTagByAttribute -HeadText $head -TagName 'link' -AttributeName 'rel' -AttributeValue 'canonical' -Replacement ('<link rel="canonical" href="' + $canonical + '">')
$head = Set-HeadTagByAttribute -HeadText $head -TagName 'meta' -AttributeName 'property' -AttributeValue 'og:title' -Replacement '<meta property="og:title" content="HAPPY-pedia RevolGC - R2 Online Guide / &#1057;&#1087;&#1088;&#1072;&#1074;&#1086;&#1095;&#1085;&#1080;&#1082; R2 Online">'
$head = Set-HeadTagByAttribute -HeadText $head -TagName 'meta' -AttributeName 'property' -AttributeValue 'og:description' -Replacement ('<meta property="og:description" content="' + $description + '">')
$head = Set-HeadTagByAttribute -HeadText $head -TagName 'meta' -AttributeName 'property' -AttributeValue 'og:url' -Replacement ('<meta property="og:url" content="' + $canonical + '">')
$head = Set-HeadTagByAttribute -HeadText $head -TagName 'meta' -AttributeName 'property' -AttributeValue 'og:site_name' -Replacement '<meta property="og:site_name" content="HAPPY-pedia RevolGC">'
$head = Set-HeadTagByAttribute -HeadText $head -TagName 'meta' -AttributeName 'property' -AttributeValue 'og:image' -Replacement '<meta property="og:image" content="https://dimarus222.github.io/ZlKonstantin/assets/happy-pedia-social-preview.png">'
$head = Set-HeadTagByAttribute -HeadText $head -TagName 'meta' -AttributeName 'property' -AttributeValue 'og:type' -Replacement '<meta property="og:type" content="website">'
$head = Set-HeadTagByAttribute -HeadText $head -TagName 'meta' -AttributeName 'name' -AttributeValue 'twitter:card' -Replacement '<meta name="twitter:card" content="summary_large_image">'
$head = Set-HeadTagByAttribute -HeadText $head -TagName 'meta' -AttributeName 'name' -AttributeValue 'twitter:title' -Replacement '<meta name="twitter:title" content="HAPPY-pedia RevolGC - R2 Online Guide / &#1057;&#1087;&#1088;&#1072;&#1074;&#1086;&#1095;&#1085;&#1080;&#1082; R2 Online">'
$head = Set-HeadTagByAttribute -HeadText $head -TagName 'meta' -AttributeName 'name' -AttributeValue 'twitter:description' -Replacement ('<meta name="twitter:description" content="' + $description + '">')
$head = Set-HeadTagByAttribute -HeadText $head -TagName 'meta' -AttributeName 'name' -AttributeValue 'twitter:image' -Replacement '<meta name="twitter:image" content="https://dimarus222.github.io/ZlKonstantin/assets/happy-pedia-social-preview.png">'

# Remove any old favicon/manifest links and prior blocks added by this installer.
$head = [System.Text.RegularExpressions.Regex]::Replace($head, '(?is)<!-- HAPPY-PEDIA ROOT FAVICON LINKS START -->.*?<!-- HAPPY-PEDIA ROOT FAVICON LINKS END -->', '')
$head = [System.Text.RegularExpressions.Regex]::Replace($head, '(?is)<link\b(?=[^>]*\bid="hp-root-(about|llms|team|team-json)")[^>]*>', '')
$head = [System.Text.RegularExpressions.Regex]::Replace($head, '(?is)<script\b(?=[^>]*\bid="happy-pedia-root-seo")[^>]*>.*?</script\s*>', '')
$linkMatches = [System.Text.RegularExpressions.Regex]::Matches($head, '(?is)<link\b[^>]*>')
for ($i = $linkMatches.Count - 1; $i -ge 0; $i--) {
    $linkMatch = $linkMatches[$i]
    $relValue = Get-AttributeValue -Tag $linkMatch.Value -AttributeName 'rel'
    if ($relValue -match '(?i)(^|\s)(icon|apple-touch-icon|mask-icon|manifest)(\s|$)') {
        $head = $head.Remove($linkMatch.Index, $linkMatch.Length)
    }
}

$extraHead = @'
<!-- HAPPY-PEDIA ROOT FAVICON LINKS START -->
<link rel="icon" href="https://dimarus222.github.io/favicon.svg" type="image/svg+xml">
<link rel="icon" href="https://dimarus222.github.io/favicon-48.png" type="image/png" sizes="48x48">
<link rel="icon" href="https://dimarus222.github.io/favicon-96.png" type="image/png" sizes="96x96">
<link rel="icon" href="https://dimarus222.github.io/favicon-192.png" type="image/png" sizes="192x192">
<link rel="shortcut icon" href="https://dimarus222.github.io/favicon.ico" type="image/x-icon">
<link rel="apple-touch-icon" href="https://dimarus222.github.io/apple-touch-icon.png" sizes="180x180">
<link rel="manifest" href="https://dimarus222.github.io/site.webmanifest">
<link id="hp-root-about" rel="alternate" type="text/plain" href="https://dimarus222.github.io/about-project.txt" title="HAPPY-pedia project and team">
<link id="hp-root-llms" rel="alternate" type="text/plain" href="https://dimarus222.github.io/llms.txt" title="HAPPY-pedia llms.txt">
<link id="hp-root-team" rel="alternate" type="text/plain" href="https://dimarus222.github.io/team.txt" title="HAPPY-pedia public team profiles">
<link id="hp-root-team-json" rel="alternate" type="application/json" href="https://dimarus222.github.io/team.json" title="HAPPY-pedia structured team data">
<!-- HAPPY-PEDIA ROOT FAVICON LINKS END -->
'@

$schemaBlock = @'
<script type="application/ld+json" id="happy-pedia-root-seo">
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "WebSite",
      "@id": "https://dimarus222.github.io/ZlKonstantin/#website",
      "url": "https://dimarus222.github.io/ZlKonstantin/",
      "name": "HAPPY-pedia RevolGC - R2 Online Guide and Item Database",
      "alternateName": ["HAPPY-pedia", "HAPPY Pedia", "HAPPY-pedia R2 Online", "\u0425\u044d\u043f\u043f\u0438-\u043f\u0435\u0434\u0438\u044f", "\u0445\u044d\u043f\u043f\u0438 \u043f\u0435\u0434\u0438\u044f", "\u0441\u043f\u0440\u0430\u0432\u043e\u0447\u043d\u0438\u043a R2 Online", "\u0441\u043f\u0440\u0430\u0432\u043e\u0447\u043d\u0438\u043a RevolGC"],
      "description": "R2 Online and RevolGC reference. Founder: ZLKonstantin; developer and SEO: Dmitry Zhdanov (STALKER); project supporter and streamer: wLIRw.",
      "inLanguage": ["ru-RU", "en"],
      "publisher": {"@id": "https://dimarus222.github.io/ZlKonstantin/#organization"},
      "creator": [
        {"@id": "https://dimarus222.github.io/ZlKonstantin/#person-zlkonstantin"},
        {"@id": "https://dimarus222.github.io/ZlKonstantin/#person-dmitry-zhdanov-stalker"}
      ],
      "contributor": {"@id": "https://dimarus222.github.io/ZlKonstantin/#person-wlirw"},
      "keywords": ["HAPPY-pedia", "R2 Online guide", "RevolGC guide", "PTS calculator", "ZLKonstantin founder", "Dmitry Zhdanov STALKER developer", "wLIRw", "\u0445\u044d\u043f\u043f\u0438 \u043f\u0435\u0434\u0438\u044f", "\u0441\u043f\u0440\u0430\u0432\u043e\u0447\u043d\u0438\u043a R2 Online", "\u043a\u0430\u043b\u044c\u043a\u0443\u043b\u044f\u0442\u043e\u0440 \u041f\u0422\u0421"]
    },
    {
      "@type": "Organization",
      "@id": "https://dimarus222.github.io/ZlKonstantin/#organization",
      "name": "HAPPY-pedia RevolGC",
      "url": "https://dimarus222.github.io/ZlKonstantin/",
      "sameAs": ["https://revolgc.pro/"]
    },
    {
      "@type": "Person",
      "@id": "https://dimarus222.github.io/ZlKonstantin/#person-zlkonstantin",
      "name": "ZLKonstantin",
      "jobTitle": "Project founder and Twitch streamer",
      "sameAs": ["https://www.twitch.tv/zlkonstantin"]
    },
    {
      "@type": "Person",
      "@id": "https://dimarus222.github.io/ZlKonstantin/#person-dmitry-zhdanov-stalker",
      "name": "Dmitry Zhdanov",
      "alternateName": "STALKER",
      "jobTitle": "Developer and SEO specialist",
      "sameAs": ["https://vk.ru/nezhdanchik_kansk_2288"]
    },
    {
      "@type": "Person",
      "@id": "https://dimarus222.github.io/ZlKonstantin/#person-wlirw",
      "name": "wLIRw",
      "jobTitle": "Project supporter and streamer",
      "sameAs": ["https://www.twitch.tv/wlirw", "https://www.youtube.com/@LirSummer", "https://vk.ru/wlirw"]
    }
  ]
}
</script>
'@

$head = $head.TrimEnd() + [Environment]::NewLine + $extraHead + [Environment]::NewLine + $schemaBlock + [Environment]::NewLine
$newContent = $content.Substring(0, $headContentStart) + $head + $bodyAndTail
$newHeadCloseIndex = $newContent.IndexOf('</head>', [System.StringComparison]::OrdinalIgnoreCase)
if ($newHeadCloseIndex -lt 0 -or $newContent.Substring($newHeadCloseIndex) -cne $bodyAndTail) {
    throw 'Safety check failed: content after </head> would change. No files were written.'
}

# Keep a backup outside the repository before changing anything.
$tempBackup = Join-Path $env:TEMP ('happy-pedia-root-index-before-favicon-' + [DateTime]::Now.ToString('yyyyMMdd-HHmmss') + '.html.bak')
[System.IO.File]::Copy($indexPath, $tempBackup, $true)
$writeEncoding = New-Object -TypeName System.Text.UTF8Encoding -ArgumentList ([bool]$hasUtf8Bom)
[System.IO.File]::WriteAllText($indexPath, $newContent, $writeEncoding)

Write-Host 'Root index head updated: bilingual metadata, canonical, social metadata, team JSON-LD, and favicon links.' -ForegroundColor Green
Write-Host 'Safety check passed: all content from </head> onward (including the redirect) was preserved.' -ForegroundColor Green
Write-Host ('Backup created at: ' + $tempBackup) -ForegroundColor Cyan
