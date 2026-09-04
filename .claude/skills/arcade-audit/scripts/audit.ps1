<#
.SYNOPSIS
    AttractMode repo periodic audit - things tools/validate.ps1 does NOT check.
.DESCRIPTION
    Read-only. Every output line carries a tag:
      ISSUE  - something to report
      OK     - checked, nothing found (kept so the report can say "measured")
      INFO   - numbers / context for the report
    ASCII-only on purpose (PowerShell 5.1 reads BOM-less UTF-8 source as ANSI).
.PARAMETER Root      repo root (default: 4 levels up from this script = repo root)
.PARAMETER Section   run one section only:
                     layout|dispimg|mascot|dupes|fonts|glyph|cfg|case|branch|video|junk
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .claude\skills\arcade-audit\scripts\audit.ps1
    powershell -ExecutionPolicy Bypass -File .claude\skills\arcade-audit\scripts\audit.ps1 -Section mascot
#>
[CmdletBinding()]
param([string]$Root, [string]$Section)
$ErrorActionPreference = 'Continue'
if (-not $Root) { $Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path }
if (-not (Test-Path -LiteralPath (Join-Path $Root 'attract.cfg'))) { Write-Error "attract.cfg not found under $Root"; exit 1 }
Set-Location -LiteralPath $Root
$BOM = [char]0xFEFF
function Want($s) { return (-not $Section) -or ($Section -eq $s) }
function Hdr($t) { ""; "=== $t ===" }
function Rel($full) { return $full.Substring($Root.Length + 1) }

# ---------------------------------------------------------------- shared parsing
$displays = @(); $cur = $null
foreach ($raw in [IO.File]::ReadAllLines("$Root\attract.cfg")) {
    $line = $raw.TrimStart($BOM)
    if ($line -match '^display\s+(.+?)\s*$') { $cur = [pscustomobject]@{ Name = $Matches[1]; Layout = $null; Romlist = $null }; $displays += $cur; continue }
    if ($line -match '^\S') { $cur = $null; continue }
    if ($null -eq $cur) { continue }
    if ($line -match '^\s+layout\s+(.+?)\s*$')  { $cur.Layout  = $Matches[1] }
    if ($line -match '^\s+romlist\s+(.+?)\s*$') { $cur.Romlist = $Matches[1] }
}
$layoutCfg = @{}; $lc = $null
foreach ($raw in [IO.File]::ReadAllLines("$Root\attract.cfg")) {
    if ($raw -match '^layout_config\s+(.+?)\s*$') { $lc = $Matches[1]; $layoutCfg[$lc] = @{}; continue }
    if ($raw -match '^\S') { $lc = $null; continue }
    if ($lc -and $raw -match '^\s+param\s+(\S+)\s*(.*)$') { $layoutCfg[$lc][$Matches[1]] = $Matches[2].Trim() }
}
function AllNutText([string]$dir) {
    $parts = @()
    foreach ($f in Get-ChildItem -LiteralPath $dir -Filter *.nut -Recurse -File) { $parts += [IO.File]::ReadAllText($f.FullName) }
    return ($parts -join "`n")
}

# ---------------------------------------------------------------- 1. layout file references
if (Want 'layout') {
    Hdr "layout: literal media/nut/module references that do not exist"
    $n = 0
    foreach ($ld in Get-ChildItem -LiteralPath "$Root\layouts" -Directory) {
        foreach ($f in Get-ChildItem -LiteralPath $ld.FullName -Filter *.nut -Recurse -File) {
            $ln = 0
            foreach ($line in [IO.File]::ReadAllLines($f.FullName)) {
                $ln++; if ($line.TrimStart().StartsWith('//')) { continue }
                $rel = Rel $f.FullName
                foreach ($m in [regex]::Matches($line, '"([^"]+\.(?:png|jpg|jpeg|gif|mp4|mp3|wav|ogg|frag|vert))"')) {
                    $p = $m.Groups[1].Value
                    if ($p -match '\[' -or $p.Length -lt 6) { continue }
                    # string-concat fragment like  "..." + m + "button.png"
                    if ($line -match ('\+\s*"' + [regex]::Escape($p))) { continue }
                    if (-not (Test-Path -LiteralPath (Join-Path $ld.FullName ($p -replace '/', '\')))) { "ISSUE  missing file   [${rel}:$ln]  $p"; $n++ }
                }
                foreach ($m in [regex]::Matches($line, 'do_nut\s*\(\s*"([^"]+)"')) {
                    $p = $m.Groups[1].Value
                    if (-not (Test-Path -LiteralPath (Join-Path $ld.FullName ($p -replace '/', '\')))) { "ISSUE  missing do_nut  [${rel}:$ln]  $p   (Squirrel exception: rest of layout.nut never runs)"; $n++ }
                }
                foreach ($m in [regex]::Matches($line, 'load_module\s*\(\s*"([^"]+)"')) {
                    $p = $m.Groups[1].Value; $c = Join-Path "$Root\modules" ($p -replace '/', '\')
                    if (-not (Test-Path -LiteralPath $c) -and -not (Test-Path -LiteralPath "$c.nut") -and -not (Test-Path -LiteralPath (Join-Path $c 'module.nut'))) { "ISSUE  missing module  [${rel}:$ln]  $p"; $n++ }
                }
            }
        }
    }
    if ($n -eq 0) { "OK     no dangling references" }
    "INFO   NEVATO layout_vewlix_*.nut are reachable via toggle_layout (key L); attract.am records which file each display uses"

    Hdr "layout: layout*.nut nested deeper than layouts/<name>/ (AM never lists them)"
    foreach ($ld in Get-ChildItem -LiteralPath "$Root\layouts" -Directory) {
        foreach ($f in Get-ChildItem -LiteralPath $ld.FullName -Filter layout*.nut -Recurse -File) {
            if ($f.DirectoryName -ne $ld.FullName) { "ISSUE  stray layout file  $(Rel $f.FullName)" }
        }
    }

    Hdr "layout: .nut files nothing loads (not layout*.nut at top, not named in any do_nut)"
    foreach ($ld in Get-ChildItem -LiteralPath "$Root\layouts" -Directory) {
        $joined = AllNutText $ld.FullName
        foreach ($f in Get-ChildItem -LiteralPath $ld.FullName -Filter *.nut -Recurse -File) {
            if ($f.Name -like 'layout*.nut' -and $f.DirectoryName -eq $ld.FullName) { continue }
            if ($joined -notmatch [regex]::Escape($f.Name)) { "ISSUE  orphan nut  $(Rel $f.FullName)" }
        }
    }
}

# ---------------------------------------------------------------- 2. [DisplayName] templated images
if (Want 'dispimg') {
    Hdr "dispimg: character/ system/ wheel/ [DisplayName] images per display"
    $pat = @{}
    foreach ($ld in Get-ChildItem -LiteralPath "$Root\layouts" -Directory) {
        $set = @{}
        foreach ($f in Get-ChildItem -LiteralPath $ld.FullName -Filter *.nut -File) {
            foreach ($line in [IO.File]::ReadAllLines($f.FullName)) {
                if ($line.TrimStart().StartsWith('//')) { continue }
                foreach ($m in [regex]::Matches($line, 'add_image\s*\(\s*"([^"]*\[DisplayName\][^"]*)"')) { $set[$m.Groups[1].Value] = 1 }
            }
        }
        $pat[$ld.Name] = $set
    }
    $miss = 0
    foreach ($d in $displays) {
        if (-not $d.Layout -or -not $pat.ContainsKey($d.Layout)) { continue }
        foreach ($p in $pat[$d.Layout].Keys) {
            $rel = $p -replace '\[DisplayName\]', $d.Name
            $full = Join-Path "$Root\layouts\$($d.Layout)" ($rel -replace '/', '\')
            $ok = $false
            if ($full -match '\.(png|jpg|gif|mp4)$') { $ok = Test-Path -LiteralPath $full }
            else { foreach ($e in @('.png', '.jpg', '.gif', '.mp4')) { if (Test-Path -LiteralPath ($full + $e)) { $ok = $true; break } } }
            if (-not $ok) { "ISSUE  [$($d.Name)] $p -> layouts\$($d.Layout)\$rel"; $miss++ }
        }
    }
    if ($miss -eq 0) { "OK     all [DisplayName] images present for $($displays.Count) displays" }

    Hdr "dispimg: files in character/ system/ wheel/ that match no display name (dead copies)"
    $names = @{}; foreach ($d in $displays) { $names[$d.Name.ToLower()] = 1 }
    foreach ($ld in Get-ChildItem -LiteralPath "$Root\layouts" -Directory) {
        foreach ($sub in @('character', 'system', 'wheel')) {
            $dir = Join-Path $ld.FullName $sub
            if (-not (Test-Path -LiteralPath $dir)) { continue }
            foreach ($f in Get-ChildItem -LiteralPath $dir -File) {
                if (-not $names.ContainsKey($f.BaseName.ToLower())) { "ISSUE  unreferenced  layouts\$($ld.Name)\$sub\$($f.Name)" }
            }
        }
    }
}

# ---------------------------------------------------------------- 3. mascot spec (480x760, cut-out with alpha)
if (Want 'mascot') {
    Hdr "mascot: 480x760 RGBA cut-out check (alpha sampled every 4px; edge = outer 8px)"
    Add-Type -AssemblyName System.Drawing
    foreach ($lay in @('NEVATO', 'Console Box')) {
        $d = Join-Path $Root "layouts\$lay\character"
        if (-not (Test-Path -LiteralPath $d)) { continue }
        foreach ($f in Get-ChildItem -LiteralPath $d -Filter *.png | Sort-Object Name) {
            try { $bmp = New-Object System.Drawing.Bitmap $f.FullName } catch { "ISSUE  unreadable $lay\$($f.Name)"; continue }
            $w = $bmp.Width; $h = $bmp.Height; $tot = 0; $tr = 0; $edge = 0; $etr = 0
            for ($y = 0; $y -lt $h; $y += 4) {
                for ($x = 0; $x -lt $w; $x += 4) {
                    $a = $bmp.GetPixel($x, $y).A; $tot++; if ($a -lt 16) { $tr++ }
                    if ($x -lt 8 -or $y -lt 8 -or $x -ge $w - 8 -or $y -ge $h - 8) { $edge++; if ($a -lt 16) { $etr++ } }
                }
            }
            $bmp.Dispose()
            $tp = 100 * $tr / $tot; $ep = 0; if ($edge) { $ep = 100 * $etr / $edge }
            $why = @()
            if ($w -ne 480 -or $h -ne 760) { $why += "size ${w}x${h}" }
            if ($tp -lt 20) { $why += "opaque poster, not a cut-out" }
            elseif ($ep -lt 60) { $why += "edges not transparent" }
            if ($f.Length -gt 600KB) { $why += "$([math]::Round($f.Length/1KB))KB (peers 200-430KB)" }
            $tag = 'OK    '; if ($why.Count) { $tag = 'ISSUE ' }
            "{0} {1,-12} {2,-32} {3,4}x{4,-4} transp {5,5:N1}%  edge {6,5:N1}%  {7}" -f $tag, $lay, $f.Name, $w, $h, $tp, $ep, ($why -join '; ')
        }
    }
}

# ---------------------------------------------------------------- 4. duplicate media across layouts
if (Want 'dupes') {
    Hdr "dupes: byte-identical tracked media >= 200KB (outside emulators/)"
    $files = git ls-files | Where-Object { $_ -match '\.(png|jpg|mp4|mp3|wav|gif|psd|tga)$' -and $_ -notmatch '^emulators/' }
    $h = @{}
    foreach ($rel in $files) {
        $full = Join-Path $Root ($rel -replace '/', '\')
        if (-not (Test-Path -LiteralPath $full)) { continue }
        $fi = Get-Item -LiteralPath $full; if ($fi.Length -lt 200KB) { continue }
        $k = (Get-FileHash -LiteralPath $full -Algorithm MD5).Hash
        if (-not $h.ContainsKey($k)) { $h[$k] = @() }
        $h[$k] += [pscustomobject]@{ Rel = $rel; Len = $fi.Length }
    }
    $tot = 0; $groups = 0
    foreach ($k in $h.Keys) { $g = $h[$k]; if ($g.Count -gt 1) { $groups++; $tot += ($g.Count - 1) * $g[0].Len } }
    "INFO   $groups duplicate groups, $([math]::Round($tot/1MB)) MB redundant"
    foreach ($k in ($h.Keys | Sort-Object { -$h[$_][0].Len })) {
        $g = $h[$k]; if ($g.Count -le 1) { continue }
        "ISSUE  x$($g.Count)  $([math]::Round($g[0].Len/1KB))KB  " + (($g | ForEach-Object { $_.Rel }) -join '  |  ')
    }

    Hdr "dupes: same relative path in NEVATO and Console Box but DIFFERENT content (the two layouts drifting apart)"
    # The two layouts share their layout-static assets byte-for-byte. A file that exists in both
    # under the same name but with a different hash means one side was updated and the other was
    # not (ISSUES 35). A file present on one side only is also listed.
    # Per-display folders (character/ system/ wheel/) are NOT compared: a display uses exactly one
    # layout (arcade -> NEVATO, console -> Console Box), so those files never need to match.
    $n = 0
    foreach ($sub in @('background', 'listbox', 'key', 'monitor')) {
        $a = Join-Path $Root "layouts\NEVATO\$sub"; $b = Join-Path $Root "layouts\Console Box\$sub"
        if (-not (Test-Path -LiteralPath $a) -or -not (Test-Path -LiteralPath $b)) { continue }
        $fa = @{}; Get-ChildItem -LiteralPath $a -File | ForEach-Object { $fa[$_.Name] = (Get-FileHash -LiteralPath $_.FullName -Algorithm MD5).Hash }
        $fb = @{}; Get-ChildItem -LiteralPath $b -File | ForEach-Object { $fb[$_.Name] = (Get-FileHash -LiteralPath $_.FullName -Algorithm MD5).Hash }
        foreach ($k in ($fa.Keys + $fb.Keys | Sort-Object -Unique)) {
            if ($fa.ContainsKey($k) -and $fb.ContainsKey($k)) { if ($fa[$k] -ne $fb[$k]) { "ISSUE  differs   $sub\$k"; $n++ } }
            elseif ($fa.ContainsKey($k)) { "ISSUE  NEVATO only       $sub\$k"; $n++ }
            else { "ISSUE  Console Box only  $sub\$k"; $n++ }
        }
    }
    if ($n -eq 0) { "OK     shared folders identical between NEVATO and Console Box" }

    Hdr "dupes: layout background variants nobody references (background/1280 1920 2xScale)"
    foreach ($ld in @('NEVATO', 'Console Box')) {
        if (-not (Test-Path -LiteralPath "$Root\layouts\$ld")) { continue }
        $joined = AllNutText "$Root\layouts\$ld"
        foreach ($sub in @('1280', '1920', '2xScale')) {
            $p = "$Root\layouts\$ld\background\$sub"
            if ((Test-Path -LiteralPath $p) -and $joined -notmatch "background/$sub/") {
                $sz = (Get-ChildItem -LiteralPath $p -File | Measure-Object Length -Sum).Sum
                "ISSUE  unreferenced  layouts\$ld\background\$sub  ($([math]::Round($sz/1MB)) MB)"
            }
        }
    }
}

# ---------------------------------------------------------------- 5. fonts referenced vs available / font_path
if (Want 'fonts') {
    Hdr "fonts: referenced by layouts but not resolvable via font_path or the layout dir"
    $fpLine = Select-String -LiteralPath "$Root\attract.cfg" -Pattern '^\s*font_path\s+(.+)$' | Select-Object -First 1
    $fp = @(); if ($fpLine) { $fp = $fpLine.Matches[0].Groups[1].Value.Trim() -split ';' }
    $avail = @{}
    foreach ($d in $fp) { $dd = Join-Path $Root $d; if (Test-Path -LiteralPath $dd) { foreach ($f in Get-ChildItem -LiteralPath $dd -File) { $avail[$f.BaseName.ToLower()] = $f.Name } } }
    $used = @{}
    foreach ($ld in Get-ChildItem -LiteralPath "$Root\layouts" -Directory) {
        foreach ($f in Get-ChildItem -LiteralPath $ld.FullName -Filter *.nut -Recurse -File) {
            $ln = 0
            foreach ($line in [IO.File]::ReadAllLines($f.FullName)) {
                $ln++; if ($line.TrimStart().StartsWith('//')) { continue }
                foreach ($m in [regex]::Matches($line, 'font\s*=\s*"([^"]+)"')) {
                    $fn = $m.Groups[1].Value; $used[$fn.ToLower()] = 1
                    $local = $false; foreach ($e in @('.ttf', '.otf', '.ttc')) { if (Test-Path -LiteralPath (Join-Path $ld.FullName ($fn + $e))) { $local = $true } }
                    if (-not $local -and -not $avail.ContainsKey($fn.ToLower())) { "ISSUE  font not found '$fn'  [$(Rel $f.FullName):$ln]  -> whole object falls back to default_font" }
                }
            }
        }
        foreach ($f in Get-ChildItem -LiteralPath $ld.FullName -File | Where-Object { $_.Extension -match '(?i)\.(ttf|otf|ttc)' }) { $used[$f.BaseName.ToLower()] = 1 }
    }
    foreach ($k in $layoutCfg.Keys) { if ($layoutCfg[$k].ContainsKey('select_font')) { $used[$layoutCfg[$k]['select_font'].ToLower()] = 1 } }
    $dfLine = Select-String -LiteralPath "$Root\attract.cfg" -Pattern '^\s*default_font\s+(.+)$' | Select-Object -First 1
    $df = ''; if ($dfLine) { $df = $dfLine.Matches[0].Groups[1].Value.Trim(); $used[$df.ToLower()] = 1 }

    Hdr "fonts: files in font_path that nothing references (option lists in layouts count)"
    $optJoined = AllNutText "$Root\layouts"
    foreach ($k in ($avail.Keys | Sort-Object)) {
        $stem = $avail[$k].Substring(0, $avail[$k].LastIndexOf('.'))
        if (-not $used.ContainsKey($k) -and $optJoined -notmatch [regex]::Escape($stem)) { "ISSUE  unused font  $($avail[$k])" }
    }

    Hdr "fonts: font files outside font_path (never loadable)"
    foreach ($f in Get-ChildItem -LiteralPath "$Root\fonts" -Recurse -File | Where-Object { $_.Extension -match '(?i)\.(ttf|otf|ttc)' }) {
        $dir = (Rel $f.DirectoryName) -replace '\\', '/'
        if ($fp -notcontains $dir) { "ISSUE  outside font_path  $dir/$($f.Name)" }
    }
}

# ---------------------------------------------------------------- 6. glyph coverage of displayed text
if (Want 'glyph') {
    Hdr "glyph: text actually displayed vs the font that displays it"
    Add-Type -AssemblyName PresentationCore
    function Cover([string]$fontPath, [string]$text, [string]$label) {
        if (-not (Test-Path -LiteralPath $fontPath)) { "INFO   skip $label (font missing)"; return }
        $gt = New-Object System.Windows.Media.GlyphTypeface (New-Object Uri $fontPath)
        $miss = @{}
        foreach ($ch in $text.ToCharArray()) { $c = [int]$ch; if ($c -lt 32) { continue }; if (-not $gt.CharacterToGlyphMap.ContainsKey($c)) { $miss["U+{0:X4} {1}" -f $c, $ch] = 1 } }
        if ($miss.Count -eq 0) { "OK     $label" } else { "ISSUE  $label -> missing: " + (($miss.Keys | Sort-Object) -join ', ') }
    }
    $ov = ''; Get-ChildItem -LiteralPath "$Root\scraper\@\overview" -File | ForEach-Object { $ov += [Text.Encoding]::UTF8.GetString([IO.File]::ReadAllBytes($_.FullName)) }
    $dfLine = Select-String -LiteralPath "$Root\attract.cfg" -Pattern '^\s*default_font\s+(.+)$' | Select-Object -First 1
    $df = $dfLine.Matches[0].Groups[1].Value.Trim()
    Cover "$Root\fonts\$df.ttf" $ov "overview/*.txt vs default_font $df (start menu)"
    $titles = ''; $byList = @{}
    foreach ($f in Get-ChildItem -LiteralPath "$Root\romlists" -Filter *.txt) {
        $i = 0; $t = ''
        foreach ($l in [IO.File]::ReadAllLines($f.FullName)) { $i++; if ($i -eq 1 -or $l.StartsWith('#') -or -not $l.Trim()) { continue }; $c = $l -split ';'; if ($c.Count -gt 1) { $t += $c[1] } }
        $byList[$f.BaseName] = $t; $titles += $t
    }
    foreach ($k in $layoutCfg.Keys) {
        if ($layoutCfg[$k].ContainsKey('select_font')) {
            $sf = $layoutCfg[$k]['select_font']
            $fpth = Get-ChildItem -LiteralPath "$Root\fonts" -File | Where-Object { $_.BaseName -ieq $sf } | Select-Object -First 1
            if ($fpth) { Cover $fpth.FullName $titles "all romlist Titles vs $k select_font=$sf" }
        }
    }
    Cover "$Root\fonts\$df.ttf" $titles "all romlist Titles vs default_font $df (fallback path)"
    Cover "$Root\fonts\$df.ttf" ([Text.Encoding]::UTF8.GetString([IO.File]::ReadAllBytes("$Root\language\kr.msg"))) "language/kr.msg vs $df"
    if (Test-Path -LiteralPath "$Root\layouts\NXL HD\Layout.nut") {
        $nxl = [Text.Encoding]::UTF8.GetString([IO.File]::ReadAllBytes("$Root\layouts\NXL HD\Layout.nut"))
        $hs = [char]0xAC00; $he = [char]0xD7A3   # Hangul syllable range, built from code points to keep this file ASCII
        $lits = ([regex]::Matches($nxl, ('"([^"]*[' + $hs + '-' + $he + '][^"]*)"')) | ForEach-Object { $_.Groups[1].Value }) -join ''
        Cover "$Root\fonts\SUIT-Regular.ttf" $lits "NXL HD Korean literals (genre/rss) vs SUIT-Regular"
        if ($byList.ContainsKey('NESiCAxLive')) { Cover "$Root\fonts\SUIT-Regular.ttf" $byList['NESiCAxLive'] "NESiCAxLive Titles vs SUIT-Regular (NXL HD child_t)" }
    }
    "INFO   CLAUDE.md 5.4: no per-glyph fallback in AM - a font either has the glyph or shows tofu"
}

# ---------------------------------------------------------------- 7. emulator cfg hygiene (things validate.ps1 trims away)
if (Want 'cfg') {
    Hdr "cfg: trailing whitespace on value lines, no final newline"
    foreach ($f in Get-ChildItem -LiteralPath "$Root\emulators" -Filter *.cfg) {
        $txt = [IO.File]::ReadAllText($f.FullName); $ln = 0
        foreach ($line in [IO.File]::ReadAllLines($f.FullName)) { $ln++; if ($line -match '^(artwork|rompath|executable|args)\b.*[ \t]+$') { "ISSUE  trailing space  emulators\$($f.Name):$ln  '$($line.TrimEnd())'" } }
        if ($txt.Length -gt 0 -and -not $txt.EndsWith("`n")) { "INFO   no final newline  emulators\$($f.Name)" }
    }

    Hdr "cfg: sibling definitions (same system, different container) whose artwork blocks differ"
    $groups = @{}
    foreach ($f in Get-ChildItem -LiteralPath "$Root\emulators" -Filter *.cfg) {
        $g = $f.BaseName -replace '\s+(CUE|CCD|PBP|TOC|ISO|GZ|GCZ|WBFS|GECD|SCDSYS)$', ''
        if ($g -ne $f.BaseName) { if (-not $groups.ContainsKey($g)) { $groups[$g] = @() }; $groups[$g] += $f }
    }
    $diffs = 0
    foreach ($g in $groups.Keys) {
        $norm = @{}
        foreach ($f in $groups[$g]) { $norm[$f.BaseName] = ((Get-Content -LiteralPath $f.FullName | Where-Object { $_ -match '^artwork' } | ForEach-Object { ($_ -replace '\s+', ' ').Trim() } | Sort-Object) -join "`n") }
        $vals = @($norm.Values | Select-Object -Unique)
        if ($vals.Count -gt 1) { "ISSUE  artwork differs within group '$g': " + (($norm.Keys | Sort-Object) -join ', '); $diffs++ }
    }
    if ($diffs -eq 0) { "OK     $($groups.Count) sibling groups consistent" }

    Hdr "cfg: layout_config toggles that decide which artwork labels are actually drawn"
    foreach ($k in $layoutCfg.Keys) { foreach ($key in @('select_character', 'boximage_type', 'spinwheelArt', 'bg_art', 'cabScreenType', 'marquee_type', 'enable_flyer', 'bg_media')) { if ($layoutCfg[$k].ContainsKey($key)) { "INFO   $k.$key = $($layoutCfg[$k][$key])" } } }
}

# ---------------------------------------------------------------- 8. exact-case consistency
if (Want 'case') {
    Hdr "case: attract.cfg romlist names vs romlists/*.txt exact case (Windows hides this, Linux does not)"
    $files = @{}; Get-ChildItem -LiteralPath "$Root\romlists" -Filter *.txt | ForEach-Object { $files[$_.BaseName] = 1 }
    $n = 0
    foreach ($d in $displays) {
        if ($d.Romlist -and -not $files.ContainsKey($d.Romlist)) {
            $real = $files.Keys | Where-Object { $_ -ieq $d.Romlist }
            "ISSUE  [$($d.Name)] attract.cfg romlist '$($d.Romlist)' but file is '$real.txt'"; $n++
        }
    }
    if ($n -eq 0) { "OK     romlist file names match exactly" }

    Hdr "case: .gitignore entries whose case differs from the real path"
    $n = 0
    foreach ($p in (Get-Content -LiteralPath "$Root\.gitignore")) {
        $p = $p.Trim(); if (-not $p -or $p.StartsWith('#') -or $p -match '[\*\[]') { continue }
        $d = $p.TrimEnd('/'); $parent = Split-Path $d -Parent; $base = Split-Path $d -Leaf
        if ($parent -and (Test-Path -LiteralPath $parent)) {
            $real = Get-ChildItem -LiteralPath $parent -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -ieq $base } | Select-Object -First 1
            if ($real -and $real.Name -ne $base) { "ISSUE  .gitignore '$p' but real name is '$($real.Name)'"; $n++ }
        }
    }
    if ($n -eq 0) { "OK     .gitignore case matches" }
}

# ---------------------------------------------------------------- 9. branch propagation
if (Want 'branch') {
    Hdr "branch: device branches vs origin/main (behind must be 0; ahead = device-specific commits)"
    git fetch --quiet 2>$null
    foreach ($b in @('bartop', 'desktop', 'desktop-ASUS-TUF', 'desktop-MSI-Sword', 'desktop-MSI-Sword-DriveWheel', 'develop')) {
        $behind = git rev-list --count "origin/$b..origin/main" 2>$null; $ahead = git rev-list --count "origin/main..origin/$b" 2>$null
        $tag = 'OK    '; if ([int]$behind -gt 0) { $tag = 'ISSUE ' }
        "{0} {1,-30} behind {2,-4} ahead {3}" -f $tag, $b, $behind, $ahead
    }
    Hdr "branch: non-merge commits on device branches touching shared files (candidates to port to develop)"
    $any = $false
    foreach ($b in @('bartop', 'desktop', 'desktop-ASUS-TUF', 'desktop-MSI-Sword', 'desktop-MSI-Sword-DriveWheel')) {
        # --cherry-pick --right-only drops commits whose patch already exists in main under another
        # hash (the bartop -> develop cherry-picks of 2022); without it every one of them is listed.
        $c = git log --oneline --no-merges --cherry-pick --right-only "origin/main...origin/$b" -- 'emulators/*.cfg' attract.cfg romlists/ tools/ docs/ 2>$null
        if ($c) { $any = $true; "ISSUE  $b"; $c | ForEach-Object { "         $_" } }
    }
    if (-not $any) { "OK     nothing shared-looking stranded on a device branch" }
}

# ---------------------------------------------------------------- 10. video metadata (no ffprobe needed)
if (Want 'video') {
    Hdr "video: tracked mp4 -> width x height / duration / bitrate (tkhd+mvhd parse)"
    function BE32($b, $o) { return ([uint32]$b[$o] * 16777216 + [uint32]$b[$o + 1] * 65536 + [uint32]$b[$o + 2] * 256 + [uint32]$b[$o + 3]) }
    foreach ($rel in (git ls-files | Where-Object { $_ -match '\.mp4$' })) {
        $full = Join-Path $Root ($rel -replace '/', '\'); if (-not (Test-Path -LiteralPath $full)) { continue }
        $b = [IO.File]::ReadAllBytes($full); $w = 0; $h = 0; $dur = 0.0
        for ($i = 0; $i -lt $b.Length - 100; $i++) {
            if ($b[$i] -eq 0x74 -and $b[$i + 1] -eq 0x6B -and $b[$i + 2] -eq 0x68 -and $b[$i + 3] -eq 0x64) {
                $o = $i + 4; $ver = $b[$o]
                $base = $o + 4 + 4 + 4 + 4 + 4 + 4; if ($ver -eq 1) { $base = $o + 4 + 8 + 8 + 4 + 4 + 8 }
                $wo = $base + 8 + 2 + 2 + 2 + 2 + 36
                $w = [math]::Round((BE32 $b $wo) / 65536.0); $h = [math]::Round((BE32 $b ($wo + 4)) / 65536.0); break
            }
        }
        for ($i = 0; $i -lt $b.Length - 24; $i++) {
            if ($b[$i] -eq 0x6D -and $b[$i + 1] -eq 0x76 -and $b[$i + 2] -eq 0x68 -and $b[$i + 3] -eq 0x64) {
                $o = $i + 4; if ($b[$o] -eq 0) { $ts = BE32 $b ($o + 12); $du = BE32 $b ($o + 16); if ($ts) { $dur = [math]::Round($du / $ts, 1) } }; break
            }
        }
        $mb = 0; if ($dur) { $mb = ($b.Length * 8 / 1MB) / $dur }
        $tag = 'INFO  '; if ($w -gt 1920 -or $mb -gt 12) { $tag = 'ISSUE ' }
        "{0} {1,-46} {2,5}x{3,-5} {4,6}s {5,8:N0}KB {6,5:N2}Mbps" -f $tag, $rel, $w, $h, $dur, ($b.Length / 1KB), $mb
    }
    if (Test-Path -LiteralPath "$Root\intro\intro.nut") {
        $intro = [IO.File]::ReadAllText("$Root\intro\intro.nut")
        foreach ($m in [regex]::Matches($intro, 'video_\w+\s*=\s*"([^"]+)"')) {
            if (-not (Test-Path -LiteralPath "$Root\intro\$($m.Groups[1].Value)")) { "ISSUE  intro.nut references missing $($m.Groups[1].Value)  (that aspect ratio -> intro silently skipped)" }
        }
    }
}

# ---------------------------------------------------------------- 11. junk in our own asset areas
if (Want 'junk') {
    Hdr "junk: tracked files in own asset areas that look like copies / backups / sources"
    $pat = '(?i)Thumbs\.db|desktop\.ini|\.DS_Store|\.psd$|\.orig$|\.tmp$|\(\d\)|/bak/|/old/|Recovered|- copy'
    $list = @(git ls-files layouts/ fonts/ intro/ screensaver/ scraper/ sounds/ shaders/ romlists/ | Where-Object { $_ -match $pat })
    "INFO   $($list.Count) files"
    $list | ForEach-Object { "ISSUE  $_" }

    Hdr "junk: runtime outputs that are tracked (reset-runtime.ps1 must skip them every run)"
    foreach ($p in @('emulators/Mame/cheat/output.json', 'emulators/Mame/cheat/output.xml', 'last_run.log', 'script.nv')) { if (git ls-files -- $p) { "ISSUE  tracked runtime output  $p" } }
    if (-not (Select-String -LiteralPath "$Root\.gitignore" -Pattern '^stats/?\s*$' -Quiet)) { "INFO   stats/ not in .gitignore (play statistics show up as untracked files)" }
}
""
"done."
