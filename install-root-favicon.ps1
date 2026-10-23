$ErrorActionPreference = 'Stop'

# Run against the repository containing this script.
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$index = Join-Path $root 'index.html'
if (-not (Test-Path -LiteralPath $index -PathType Leaf)) {
    throw 'index.html was not found beside install-root-favicon.ps1. No files were changed.'
}

$content = [System.IO.File]::ReadAllText($index, [System.Text.Encoding]::UTF8)
$headOpenMatch = [System.Text.RegularExpressions.Regex]::Match($content, '(?is)<head\b[^>]*>')
$headCloseIndex = $content.IndexOf('</head>', [System.StringComparison]::OrdinalIgnoreCase)
if (-not $headOpenMatch.Success -or $headCloseIndex -lt $headOpenMatch.Index) {
    throw 'index.html must contain <head> and </head>. No files were changed.'
}
$headStart = $headOpenMatch.Index
$headContentStart = $headOpenMatch.Index + $headOpenMatch.Length
$head = $content.Substring($headContentStart, $headCloseIndex - $headContentStart)
$bodyAndTail = $content.Substring($headCloseIndex)

function Get-AttributeValue([string]$tag, [string]$attributeName) {
    $pattern = '(?is)\b' + [System.Text.RegularExpressions.Regex]::Escape($attributeName) + '\s*=\s*(?:"([^"]*)"|''([^'']*)''|([^\s/>]+))'
    $m = [System.Text.RegularExpressions.Regex]::Match($tag, $pattern)
    if (-not $m.Success) { return '' }
    if ($m.Groups[1].Success) { return $m.Groups[1].Value }
    if ($m.Groups[2].Success) { return $m.Groups[2].Value }
    return $m.Groups[3].Value
}

function Set-HeadTagByAttribute([string]$headText, [string]$tagName, [string]$attributeName, [string]$attributeValue, [string]$replacement) {
    $tagPattern = '(?is)<' + [System.Text.RegularExpressions.Regex]::Escape($tagName) + '\b[^>]*>'
    $allTags = [System.Text.RegularExpressions.Regex]::Matches($headText, $tagPattern)
    $selected = @()
    foreach ($m in $allTags) {
        if ((Get-AttributeValue $m.Value $attributeName) -ieq $attributeValue) { $selected += $m }
    }
    if ($selected.Count -eq 0) { return ($headText.TrimEnd() + "`r`n" + $replacement + "`r`n") }
    $keepIndex = $selected[0].Index
    for ($i = $selected.Count - 1; $i -ge 0; $i--) {
        $m = $selected[$i]
        if ($m.Index -eq $keepIndex) {
            $headText = $headText.Remove($m.Index, $m.Length).Insert($m.Index, $replacement)
        } else {
            $headText = $headText.Remove($m.Index, $m.Length)
        }
    }
    return $headText
}

# Replace title without touching body content.
$titlePattern = '(?is)<title\b[^>]*>.*?</title\s*>'
$titleMatches = [System.Text.RegularExpressions.Regex]::Matches($head, $titlePattern)
$titleReplacement = '<title>HAPPY-pedia RevolGC — R2 Online Guide &amp; Справочник R2 Online</title>'
if ($titleMatches.Count -eq 0) { $head = $head.TrimEnd() + "`r`n" + $titleReplacement + "`r`n" }
else {
    $keepTitle = $titleMatches[0].Index
    for ($i = $titleMatches.Count - 1; $i -ge 0; $i--) {
        $m = $titleMatches[$i]
        if ($m.Index -eq $keepTitle) { $head = $head.Remove($m.Index, $m.Length).Insert($m.Index, $titleReplacement) }
        else { $head = $head.Remove($m.Index, $m.Length) }
    }
}

$canonical = 'https://dimarus222.github.io/ZlKonstantin/'
$description = 'HAPPY-pedia — справочник R2 Online / RevolGC: фарм, дроп, калькулятор ПТС, питомцы, оружие, бижутерия и сферы. Основатель — ZLKonstantin; разработчик и SEO — Дмитрий Жданов (STALKER). R2 Online guide & item database.'
$author = 'HAPPY-pedia team: ZLKonstantin (founder); Dmitry Zhdanov / STALKER (developer, SEO); wLIRw (supporter and streamer)'
$keywords = 'HAPPY-pedia, HAPPY-pedia RevolGC, HAPPY Pedia, HAPPY-pedia R2 Online, Хэппи-педия, Хеппи-педия, хэппи педия, хеппи педия, хэппи Р2, хэппи RevolGC, справочник R2 Online, справочник Р2, справочник RevolGC, R2 Online guide, R2 Online wiki, RevolGC guide, R2 Online item database, калькулятор ПТС R2 Online, PTS calculator, фарм и дроп R2, R2 Online farming locations, ZLKonstantin основатель HAPPY-pedia, Дмитрий Жданов STALKER разработчик HAPPY-pedia, HAPPY-pedia developer, wLIRw HAPPY-pedia'
$head = Set-HeadTagByAttribute $head 'meta' 'name' 'description' ('<meta name="description" content="' + $description.Replace('&','&amp;').Replace('"','&quot;') + '">')
$head = Set-HeadTagByAttribute $head 'meta' 'name' 'author' ('<meta name="author" content="' + $author.Replace('&','&amp;').Replace('"','&quot;') + '">')
$head = Set-HeadTagByAttribute $head 'meta' 'name' 'keywords' ('<meta name="keywords" content="' + $keywords.Replace('&','&amp;').Replace('"','&quot;') + '">')
$head = Set-HeadTagByAttribute $head 'meta' 'name' 'robots' '<meta name="robots" content="index,follow,max-image-preview:large">'
$head = Set-HeadTagByAttribute $head 'link' 'rel' 'canonical' ('<link rel="canonical" href="' + $canonical + '">')
$head = Set-HeadTagByAttribute $head 'meta' 'property' 'og:title' '<meta property="og:title" content="HAPPY-pedia RevolGC — R2 Online Guide / Справочник R2 Online">'
$head = Set-HeadTagByAttribute $head 'meta' 'property' 'og:description' ('<meta property="og:description" content="' + $description.Replace('&','&amp;').Replace('"','&quot;') + '">')
$head = Set-HeadTagByAttribute $head 'meta' 'property' 'og:url' ('<meta property="og:url" content="' + $canonical + '">')
$head = Set-HeadTagByAttribute $head 'meta' 'property' 'og:site_name' '<meta property="og:site_name" content="HAPPY-pedia">'
$head = Set-HeadTagByAttribute $head 'meta' 'property' 'og:image' '<meta property="og:image" content="https://dimarus222.github.io/ZlKonstantin/assets/happy-pedia-social-preview.png">'
$head = Set-HeadTagByAttribute $head 'meta' 'name' 'twitter:card' '<meta name="twitter:card" content="summary_large_image">'
$head = Set-HeadTagByAttribute $head 'meta' 'name' 'twitter:title' '<meta name="twitter:title" content="HAPPY-pedia RevolGC — R2 Online Guide / Справочник R2 Online">'
$head = Set-HeadTagByAttribute $head 'meta' 'name' 'twitter:description' ('<meta name="twitter:description" content="' + $description.Replace('&','&amp;').Replace('"','&quot;') + '">')
$head = Set-HeadTagByAttribute $head 'meta' 'name' 'twitter:image' '<meta name="twitter:image" content="https://dimarus222.github.io/ZlKonstantin/assets/happy-pedia-social-preview.png">'

# Remove only existing icon links, then add the standardized host-root icon set.
$linkMatches = [System.Text.RegularExpressions.Regex]::Matches($head, '(?is)<link\b[^>]*>')
for ($i = $linkMatches.Count - 1; $i -ge 0; $i--) {
    $m = $linkMatches[$i]
    $rel = Get-AttributeValue $m.Value 'rel'
    if ($rel -match '(?i)(^|\s)(icon|apple-touch-icon|mask-icon|manifest)(\s|$)') {
        $head = $head.Remove($m.Index, $m.Length)
    }
}
# Remove previously inserted alternate-link set and root schema to keep repeated runs idempotent.
$head = [System.Text.RegularExpressions.Regex]::Replace($head, '(?is)<link\b(?=[^>]*\bid=["'']hp-root-(about|llms|team|team-json)["''])[^>]*>', '')
$head = [System.Text.RegularExpressions.Regex]::Replace($head, '(?is)<script\b(?=[^>]*\bid=["'']happy-pedia-root-seo["''])[^>]*>.*?</script\s*>', '')

$extraHead = @'
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
<script type="application/ld+json" id="happy-pedia-root-seo">
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "WebSite",
      "@id": "https://dimarus222.github.io/ZlKonstantin/#website",
      "url": "https://dimarus222.github.io/ZlKonstantin/",
      "name": "HAPPY-pedia RevolGC — R2 Online Guide & Item Database",
      "alternateName": ["HAPPY-pedia", "HAPPY Pedia", "HAPPY-pedia R2 Online", "Хэппи-педия", "Хеппи-педия", "хэппи педия", "хеппи педия", "справочник R2 Online", "справочник RevolGC"],
      "description": "HAPPY-pedia — справочник R2 Online / RevolGC. Founder: ZLKonstantin; developer and SEO: Dmitry Zhdanov (STALKER); supporter: wLIRw.",
      "inLanguage": ["ru-RU", "en"],
      "publisher": {"@id": "https://dimarus222.github.io/ZlKonstantin/#organization"},
      "creator": [
        {"@id": "https://dimarus222.github.io/ZlKonstantin/#person-zlkonstantin"},
        {"@id": "https://dimarus222.github.io/ZlKonstantin/#person-dmitry-zhdanov-stalker"}
      ],
      "contributor": {"@id": "https://dimarus222.github.io/ZlKonstantin/#person-wlirw"},
      "keywords": ["HAPPY-pedia", "Хэппи-педия", "хэппи педия", "справочник R2 Online", "R2 Online guide", "RevolGC guide", "калькулятор ПТС R2 Online", "кто создал HAPPY-pedia", "ZLKonstantin создатель HAPPY-pedia", "Дмитрий Жданов STALKER разработчик HAPPY-pedia", "HAPPY-pedia developer", "wLIRw HAPPY-pedia"]
    },
    {
      "@type": "Organization",
      "@id": "https://dimarus222.github.io/ZlKonstantin/#organization",
      "name": "HAPPY-pedia RevolGC",
      "url": "https://dimarus222.github.io/ZlKonstantin/",
      "description": "Community R2 Online / RevolGC reference. Founder ZLKonstantin; developer and SEO specialist Dmitry Zhdanov (STALKER); project supporter and streamer wLIRw.",
      "logo": {"@type": "ImageObject", "url": "https://dimarus222.github.io/favicon-192.png", "width": 192, "height": 192},
      "founder": {"@id": "https://dimarus222.github.io/ZlKonstantin/#person-zlkonstantin"},
      "member": [
        {"@id": "https://dimarus222.github.io/ZlKonstantin/#person-dmitry-zhdanov-stalker"},
        {"@id": "https://dimarus222.github.io/ZlKonstantin/#person-wlirw"}
      ],
      "subjectOf": [
        {"@type": "CreativeWork", "name": "About HAPPY-pedia", "url": "https://dimarus222.github.io/about-project.txt"},
        {"@type": "CreativeWork", "name": "Public team profiles", "url": "https://dimarus222.github.io/team.txt"}
      ]
    },
    {
      "@type": "Person",
      "@id": "https://dimarus222.github.io/ZlKonstantin/#person-zlkonstantin",
      "name": "ZLKonstantin",
      "alternateName": ["ZLKonstantin", "HAPPY-pedia founder", "основатель HAPPY-pedia"],
      "url": "https://www.twitch.tv/zlkonstantin",
      "sameAs": ["https://www.twitch.tv/zlkonstantin"],
      "jobTitle": "Основатель HAPPY-pedia и Twitch-стример / HAPPY-pedia founder and Twitch streamer",
      "affiliation": {"@id": "https://dimarus222.github.io/ZlKonstantin/#organization"}
    },
    {
      "@type": "Person",
      "@id": "https://dimarus222.github.io/ZlKonstantin/#person-dmitry-zhdanov-stalker",
      "name": "Дмитрий Жданов",
      "alternateName": ["STALKER", "Dmitry Zhdanov", "Дмитрий Жданов STALKER"],
      "url": "https://vk.ru/nezhdanchik_kansk_2288",
      "sameAs": ["https://vk.ru/nezhdanchik_kansk_2288"],
      "jobTitle": "Разработчик HAPPY-pedia, SEO-специалист и специалист по продвижению / HAPPY-pedia developer, SEO and promotion specialist",
      "description": "По информации команды проекта, окончил Канский морской кадетский корпус и в 2026 году был студентом 1-го курса ИКИТ СФУ. Эти образовательные сведения предоставлены командой и не проверялись независимо. According to the project team, graduated from Kansk Maritime Cadet Corps and was a first-year student at IKIT SFU in 2026; not independently verified.",
      "alumniOf": {"@type": "EducationalOrganization", "name": "Канский морской кадетский корпус"},
      "memberOf": {"@type": "EducationalOrganization", "name": "ИКИТ СФУ"},
      "knowsAbout": ["web development", "SEO", "search engine optimization", "digital promotion", "R2 Online reference data"],
      "affiliation": {"@id": "https://dimarus222.github.io/ZlKonstantin/#organization"}
    },
    {
      "@type": "Person",
      "@id": "https://dimarus222.github.io/ZlKonstantin/#person-wlirw",
      "name": "wLIRw",
      "alternateName": ["LirSummer", "wLIRw RevolGC"],
      "url": "https://www.twitch.tv/wlirw",
      "sameAs": ["https://www.twitch.tv/wlirw", "https://www.youtube.com/@LirSummer", "https://vk.ru/wlirw"],
      "jobTitle": "Twitch-стример и сторонник проекта / Twitch streamer and project supporter",
      "affiliation": {"@id": "https://dimarus222.github.io/ZlKonstantin/#organization"}
    }
  ]
}
</script>
'@
$head = $head.TrimEnd() + "`r`n" + $extraHead + "`r`n"
$newContent = $content.Substring(0, $headContentStart) + $head + $bodyAndTail

# Defensive verification: all bytes from </head> onward must match the original file.
if ($newContent.Substring($newContent.IndexOf('</head>', [System.StringComparison]::OrdinalIgnoreCase)) -cne $content.Substring($headCloseIndex)) {
    throw 'Safety check failed: content from </head> onward changed. No file was written.'
}
$utf8NoBom = New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false
[System.IO.File]::WriteAllText($index, $newContent, $utf8NoBom)
Write-Host 'HAPPY-pedia root head updated: bilingual metadata, authorship JSON-LD and host-root favicon links installed.' -ForegroundColor Green
Write-Host 'The redirect and all content from </head> onward were preserved.' -ForegroundColor Green
