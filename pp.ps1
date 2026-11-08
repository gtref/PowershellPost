# PowershellPost, a single-file blog generator for Windows PowerShell.
# Settings in .pp.conf use key=value lines and override the defaults below.

$script:conf_file = ".pp.conf"
$script:project_root = (Get-Location).Path

function global_variables {
    $script:global_software_name = "PowershellPost"
    $script:global_software_version = "2.12"
    $script:global_title = "My fancy blog"
    $script:global_description = "A blog about turtles and carrots"
    $script:global_url = "http://example.com/blog"
    $script:global_author = "John Smith"
    $script:global_author_url = "http://twitter.com/example"
    $script:global_source_url = "https://github.com/gtref/PowershellPost"
    $script:global_email = "john@smith.com"
    $script:global_license = "CC by-nc-nd"
    $script:global_feedburner = ""
    $script:global_twitter_username = ""
    $script:global_twitter_card_image = ""
    $script:global_twitter_cookieless = "true"
    $script:global_twitter_search = "twitter"
    $script:global_disqus_username = ""
    $script:about_page = $true
    $script:about_me = ""
    $script:github_profile = $false
    $script:github_user_name = ""
    $script:devto_profile = $false
    $script:devto_user_name = ""

    $script:index_file = "index.html"
    $script:about_file = "about.html"
    $script:number_of_index_articles = 8
    $script:archive_index = "all_posts.html"
    $script:tags_index = "all_tags.html"
    $script:non_blogpost_files = @()
    $script:blog_feed = "feed.rss"
    $script:number_of_feed_articles = 10
    $script:cut_do = ""
    $script:cut_tags = "yes"
    $script:cut_line = '<hr ?\/?>'
    $script:save_markdown = "yes"
    $script:prefix_tags = "tag_"
    $script:staticpage_tag = "staticpage"
    $script:header_file = ""
    $script:footer_file = ""
    $script:body_begin_file = ""
    $script:body_end_file = ""
    $script:body_begin_file_index = ""
    $script:css_include = @()
    $script:html_exclude = @()

    $script:template_comments = "Comments?"
    $script:template_read_more = "Read more..."
    $script:template_archive = "View more posts"
    $script:template_archive_title = "All posts"
    $script:template_tags_title = "All tags"
    $script:template_tags_posts = "posts"
    $script:template_tags_posts_2_4 = "posts"
    $script:template_tags_posts_singular = "post"
    $script:template_tag_title = "Posts tagged"
    $script:template_tags_line_header = "Tags:"
    $script:template_archive_index_page = "Back to the index page"
    $script:template_subscribe = "Subscribe"
    $script:template_subscribe_browser_button = "Subscribe to this page..."
    $script:template_twitter_button = "Tweet"
    $script:template_twitter_comment = "&lt;Type your comment here but please leave the URL so that other people can follow the comments&gt;"

    $script:date_format = "%B %d, %Y"
    $script:date_locale = "C"
    $script:date_inpost = "bashblog_timestamp"
    $script:date_format_full = "%a, %d %b %Y %H:%M:%S %z"
    $script:date_format_timestamp = "%Y%m%d%H%M.%S"
    $script:date_allposts_header = "%B %Y"
    $script:preview_url = ""
    $script:convert_filename = $true
    $script:posts_dir = "posts"
    $script:dist_dir = "dist"

    $script:markdown_bin = ""
    $script:markdown_arguments = @()
    $script:markdown_is_application = $false
    $script:markdown_file = ""
    $script:configurable_settings = @(
        "global_title", "global_description", "global_url", "global_author",
        "global_author_url", "global_source_url", "global_email", "global_license", "global_feedburner",
        "global_twitter_username", "global_twitter_card_image", "global_twitter_cookieless",
        "global_twitter_search", "global_disqus_username", "about_page", "about_me",
        "github_profile", "github_user_name", "devto_profile", "devto_user_name", "index_file",
        "number_of_index_articles", "archive_index", "tags_index", "non_blogpost_files",
        "blog_feed", "number_of_feed_articles", "cut_do", "cut_tags", "cut_line",
        "save_markdown", "prefix_tags", "staticpage_tag", "header_file", "footer_file",
        "body_begin_file", "body_end_file", "body_begin_file_index", "css_include",
        "html_exclude", "template_comments", "template_read_more", "template_archive",
        "template_archive_title", "template_tags_title", "template_tags_posts",
        "template_tags_posts_2_4", "template_tags_posts_singular", "template_tag_title",
        "template_tags_line_header", "template_archive_index_page", "template_subscribe",
        "template_subscribe_browser_button", "template_twitter_button",
        "template_twitter_comment", "date_format", "date_locale", "date_inpost",
        "date_format_full", "date_format_timestamp", "date_allposts_header",
        "preview_url", "convert_filename", "posts_dir", "dist_dir"
    )
}

function Initialize-PpPaths {
    $script:project_root = (Get-Location).Path
    $script:posts_root = [IO.Path]::GetFullPath((Resolve-ProjectFile $script:posts_dir))
    $script:dist_root = [IO.Path]::GetFullPath((Resolve-ProjectFile $script:dist_dir))
    $projectRootFull = [IO.Path]::GetFullPath($script:project_root)
    if ($script:posts_root -eq $projectRootFull -or $script:dist_root -eq $projectRootFull) {
        throw "posts_dir and dist_dir must not point to the project root."
    }
    if ((Test-PathWithinDirectory $script:posts_root $script:dist_root) -or
        (Test-PathWithinDirectory $script:dist_root $script:posts_root)) {
        throw "posts_dir and dist_dir must not contain one another."
    }
    New-Item -ItemType Directory -Path $script:posts_root -Force | Out-Null
    New-Item -ItemType Directory -Path $script:dist_root -Force | Out-Null
    $script:conf_file = Join-Path $script:project_root ".pp.conf"
}

function Resolve-ProjectFile {
    param([string]$Path)
    if ([IO.Path]::IsPathRooted($Path)) { return $Path }
    return Join-Path $script:project_root $Path
}

function Test-PathWithinDirectory {
    param([string]$Path, [string]$Directory)
    $fullPath = [IO.Path]::GetFullPath($Path).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
    $fullDirectory = [IO.Path]::GetFullPath($Directory).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
    return $fullPath.StartsWith($fullDirectory, [StringComparison]::OrdinalIgnoreCase)
}

function Assert-PathWithinDirectory {
    param([string]$Path, [string]$Directory, [string]$Description)
    $fullPath = [IO.Path]::GetFullPath($Path)
    if (-not (Test-PathWithinDirectory $fullPath $Directory)) {
        throw "$Description must be inside '$Directory'."
    }
}

function Import-PpConfig {
    param([string]$Path = $script:conf_file)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return
    }

    foreach ($line in Get-Content -LiteralPath $Path -Encoding UTF8) {
        if ($line -match '^\s*(#|$)') { continue }
        if ($line -notmatch '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*$') {
            throw "Invalid configuration line in '$Path': $line"
        }

        $name = $Matches[1]
        $value = $Matches[2]
        if ($name -notin $script:configurable_settings) { continue }

        if ($value.Length -ge 2 -and
            (($value.StartsWith('"') -and $value.EndsWith('"')) -or
             ($value.StartsWith("'") -and $value.EndsWith("'")))) {
            $value = $value.Substring(1, $value.Length - 2)
        }

        if ($name -in @("non_blogpost_files", "css_include", "html_exclude")) {
            $parsedValue = @($value -split '\s*,\s*' | Where-Object { $_ -ne "" })
        }
        elseif ($name -eq "convert_filename") {
            $parsedValue = $value -notin @("", "false", "no", "0")
        }
        elseif ($name -in @("about_page", "github_profile", "devto_profile")) {
            if ($value -match '^(true|yes|1)$') { $parsedValue = $true }
            elseif ($value -match '^(false|no|0|)$') { $parsedValue = $false }
            else { throw "Configuration setting '$name' must be true or false." }
        }
        elseif ($name -in @(
            "global_url", "global_author_url", "global_source_url",
            "global_twitter_username", "global_twitter_card_image",
            "global_feedburner", "preview_url"
        ) -and $value -match '^(false|no|0)$') {
            $parsedValue = ""
        }
        elseif ($name -in @("number_of_index_articles", "number_of_feed_articles")) {
            $parsedValue = 0
            if (-not [int]::TryParse($value, [ref]$parsedValue) -or $parsedValue -lt 0) {
                throw "Configuration setting '$name' must be a non-negative integer."
            }
        }
        else {
            $parsedValue = $value
        }

        Set-Variable -Name $name -Value $parsedValue -Scope Script
    }
}

function Get-PpPublicUrl {
    param([string]$Path)

    if (-not $script:global_url) { return "" }
    $baseUrl = $script:global_url.TrimEnd('/')
    if (-not $Path) { return $baseUrl }
    return "$baseUrl/$($Path.TrimStart('/'))"
}

function Convert-PpMarkdownInline {
    param([string]$Text)

    $encoded = [Net.WebUtility]::HtmlEncode($Text)
    $codeSpans = [Collections.Generic.List[string]]::new()
    $encoded = [regex]::Replace($encoded, '(?<!`)(?<ticks>`+)(?!`)(?<code>.+?)\k<ticks>(?!`)', {
        param($match)
        $code = $match.Groups["code"].Value -replace '\r?\n', ' '
        if ($code.Length -ge 2 -and $code.StartsWith(" ") -and $code.EndsWith(" ") -and
            $code.Trim(" ").Length -gt 0) {
            $code = $code.Substring(1, $code.Length - 2)
        }
        $codeSpans.Add("<code>$code</code>")
        "PPMARKDOWNCODE$($codeSpans.Count - 1)TOKEN"
    })
    $encoded = [regex]::Replace($encoded, '!\[([^\]]*)\]\(([^)\s]+)(?:\s+&quot;(.*?)&quot;)?\)', {
        param($match)
        $alt = $match.Groups[1].Value
        $url = $match.Groups[2].Value
        if ($url -match '^\s*(javascript|vbscript|data):') { return $match.Value }
        $title = if ($match.Groups[3].Success) { " title=`"$($match.Groups[3].Value)`"" } else { "" }
        "<img src=`"$url`" alt=`"$alt`"$title />"
    })
    $encoded = [regex]::Replace($encoded, '\[([^\]]+)\]\(([^)\s]+)(?:\s+&quot;(.*?)&quot;)?\)', {
        param($match)
        $url = $match.Groups[2].Value
        if ($url -match '^\s*(javascript|vbscript|data):') { return $match.Value }
        $title = if ($match.Groups[3].Success) { " title=`"$($match.Groups[3].Value)`"" } else { "" }
        "<a href=`"$url`"$title>$($match.Groups[1].Value)</a>"
    })
    $encoded = [regex]::Replace($encoded, '\*\*(.+?)\*\*|__(.+?)__', {
        param($match)
        $content = if ($match.Groups[1].Success) { $match.Groups[1].Value } else { $match.Groups[2].Value }
        "<strong>$content</strong>"
    })
    $encoded = [regex]::Replace($encoded, '(?<!\*)\*([^*]+)\*(?!\*)|(?<!_)_([^_]+)_(?!_)', {
        param($match)
        $content = if ($match.Groups[1].Success) { $match.Groups[1].Value } else { $match.Groups[2].Value }
        "<em>$content</em>"
    })
    for ($index = 0; $index -lt $codeSpans.Count; $index++) {
        $encoded = $encoded.Replace("PPMARKDOWNCODE${index}TOKEN", $codeSpans[$index])
    }
    return $encoded
}

function Convert-PpMarkdown {
    param([Parameter(Mandatory = $true)][string]$Path)

    $lines = [IO.File]::ReadAllLines((Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path)
    $html = [Collections.Generic.List[string]]::new()
    $paragraph = [Collections.Generic.List[string]]::new()
    $index = 0
    while ($index -lt $lines.Count) {
        $line = $lines[$index]
        if ([string]::IsNullOrWhiteSpace($line)) {
            if ($paragraph.Count) {
                $formattedParagraph = @($paragraph | ForEach-Object { Convert-PpMarkdownInline $_ }) -join ' '
                $html.Add("<p>$formattedParagraph</p>")
                $paragraph.Clear()
            }
            $index++
            continue
        }

        if ($line -match '^\s*(?<fence>`{3,}|~{3,})\s*(?<language>.*?)\s*$|^\s*(?<single>`)\s*$') {
            if ($paragraph.Count) {
                $formattedParagraph = @($paragraph | ForEach-Object { Convert-PpMarkdownInline $_ }) -join ' '
                $html.Add("<p>$formattedParagraph</p>")
                $paragraph.Clear()
            }
            $fence = if ($Matches["fence"]) { $Matches["fence"] } else { $Matches["single"] }
            $language = if ($Matches["fence"]) { $Matches["language"].Trim() } else { "" }
            $code = [Collections.Generic.List[string]]::new()
            $index++
            $closingFence = "^\s*$([regex]::Escape($fence))\s*$"
            while ($index -lt $lines.Count -and $lines[$index] -notmatch $closingFence) {
                $code.Add([Net.WebUtility]::HtmlEncode($lines[$index]))
                $index++
            }
            $class = if ($language -match '^[A-Za-z0-9_-]+$') { " class=`"language-$language`"" } else { "" }
            $html.Add("<pre><code$class>$([string]::Join([Environment]::NewLine, $code.ToArray()))</code></pre>")
            if ($index -lt $lines.Count) { $index++ }
            continue
        }

        if ($line -match '^\s{0,3}(#{1,6})\s+(.+?)\s*#*\s*$') {
            if ($paragraph.Count) {
                $formattedParagraph = @($paragraph | ForEach-Object { Convert-PpMarkdownInline $_ }) -join ' '
                $html.Add("<p>$formattedParagraph</p>")
                $paragraph.Clear()
            }
            $level = $Matches[1].Length
            $html.Add("<h$level>$(Convert-PpMarkdownInline $Matches[2])</h$level>")
            $index++
            continue
        }

        if ($line -match '^\s{0,3}(---+|\*\*\*+|___+)\s*$') {
            if ($paragraph.Count) {
                $formattedParagraph = @($paragraph | ForEach-Object { Convert-PpMarkdownInline $_ }) -join ' '
                $html.Add("<p>$formattedParagraph</p>")
                $paragraph.Clear()
            }
            $html.Add("<hr />")
            $index++
            continue
        }

        if ($line -match '^\s{0,3}>\s?(.*)$') {
            if ($paragraph.Count) {
                $formattedParagraph = @($paragraph | ForEach-Object { Convert-PpMarkdownInline $_ }) -join ' '
                $html.Add("<p>$formattedParagraph</p>")
                $paragraph.Clear()
            }
            $quote = [Collections.Generic.List[string]]::new()
            while ($index -lt $lines.Count -and $lines[$index] -match '^\s{0,3}>\s?(.*)$') {
                $quote.Add((Convert-PpMarkdownInline $Matches[1]))
                $index++
            }
            $html.Add("<blockquote><p>$([string]::Join(' ', $quote.ToArray()))</p></blockquote>")
            continue
        }

        if ($line -match '^\s{0,3}([-+*]|\d+\.)\s+(.+)$') {
            if ($paragraph.Count) {
                $formattedParagraph = @($paragraph | ForEach-Object { Convert-PpMarkdownInline $_ }) -join ' '
                $html.Add("<p>$formattedParagraph</p>")
                $paragraph.Clear()
            }
            $ordered = $Matches[1] -match '^\d'
            $listTag = if ($ordered) { "ol" } else { "ul" }
            $html.Add("<$listTag>")
            while ($index -lt $lines.Count -and $lines[$index] -match '^\s{0,3}([-+*]|\d+\.)\s+(.+)$' -and (($Matches[1] -match '^\d') -eq $ordered)) {
                $html.Add("<li>$(Convert-PpMarkdownInline $Matches[2])</li>")
                $index++
            }
            $html.Add("</$listTag>")
            continue
        }

        if ($line -match '^\s{0,3}<') {
            if ($paragraph.Count) {
                $formattedParagraph = @($paragraph | ForEach-Object { Convert-PpMarkdownInline $_ }) -join ' '
                $html.Add("<p>$formattedParagraph</p>")
                $paragraph.Clear()
            }
            $html.Add($line)
            $index++
            continue
        }

        $paragraph.Add($line.Trim())
        $index++
    }
    if ($paragraph.Count) {
        $formattedParagraph = @($paragraph | ForEach-Object { Convert-PpMarkdownInline $_ }) -join ' '
        $html.Add("<p>$formattedParagraph</p>")
    }
    $html
}

function Find-Markdown {
    $script:markdown_bin = ""
    $script:markdown_arguments = @()
    $script:markdown_is_application = $false
    $script:markdown_file = ""

    $candidates = @(
        (Join-Path $script:project_root "Markdown.pl"),
        (Join-Path $PSScriptRoot "Markdown.pl")
    ) | Select-Object -Unique
    $markdownPath = $candidates |
        Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
        Select-Object -First 1

    if ($markdownPath) {
        $perl = Get-Command -Name perl -CommandType Application -ErrorAction SilentlyContinue |
            Select-Object -First 1
        if ($perl) {
            $script:markdown_bin = $perl.Source
            $script:markdown_arguments = @($markdownPath)
            $script:markdown_is_application = $true
            $script:markdown_file = $markdownPath
            return
        }
    }

    $command = Get-Command -Name markdown -CommandType Application, ExternalScript, Function -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($command) {
        $script:markdown_bin = if ($command.Source) { $command.Source } else { $command.Name }
        $script:markdown_is_application = $command.CommandType -eq "Application"
        return
    }

    $script:markdown_bin = "Convert-PpMarkdown"
    $script:markdown_is_application = $false
}

function ConvertTo-PostFileName {
    param([AllowEmptyString()][string]$Title)

    $transliterations = @{}
    $transliterations[[string][char]0x00E6] = "ae"
    $transliterations[[string][char]0x0153] = "oe"
    $transliterations[[string][char]0x00F8] = "o"
    $transliterations[[string][char]0x0142] = "l"
    $transliterations[[string][char]0x0111] = "d"
    $transliterations[[string][char]0x00F0] = "d"
    $transliterations[[string][char]0x00FE] = "th"
    $transliterations[[string][char]0x00DF] = "ss"
    $normalized = $Title.ToLowerInvariant().Normalize([Text.NormalizationForm]::FormD)
    $builder = [System.Text.StringBuilder]::new()

    foreach ($character in $normalized.ToCharArray()) {
        $value = [string]$character
        if ($transliterations.ContainsKey($value)) {
            [void]$builder.Append($transliterations[$value])
            continue
        }

        $category = [Globalization.CharUnicodeInfo]::GetUnicodeCategory($character)
        if ($category -in @(
            [Globalization.UnicodeCategory]::NonSpacingMark,
            [Globalization.UnicodeCategory]::SpacingCombiningMark,
            [Globalization.UnicodeCategory]::EnclosingMark
        )) { continue }

        if ([char]::IsWhiteSpace($character)) {
            [void]$builder.Append("-")
        }
        elseif ($value -match '^[a-z0-9-]$') {
            [void]$builder.Append($value)
        }
    }

    $builder.ToString().TrimStart("-")
}

function ConvertFrom-StrftimeFormat {
    param([string]$Format)

    return [regex]::Replace($Format, '%([aAbBdeHImMpSyzY%])', {
        param($match)
        switch -CaseSensitive ($match.Groups[1].Value) {
            "a" { return "ddd" }
            "A" { return "dddd" }
            "b" { return "MMM" }
            "B" { return "MMMM" }
            "d" { return "dd" }
            "e" { return "d" }
            "H" { return "HH" }
            "I" { return "hh" }
            "m" { return "MM" }
            "M" { return "mm" }
            "p" { return "tt" }
            "S" { return "ss" }
            "z" { return "zzz" }
            "y" { return "yy" }
            "Y" { return "yyyy" }
            "%" { return "%" }
            default { return $match.Value }
        }
    })
}

function Format-PpDate {
    param([datetime]$Date, [string]$Format)
    $Date.ToString((ConvertFrom-StrftimeFormat $Format), [Globalization.CultureInfo]::InvariantCulture)
}

function Write-Utf8File {
    param([string]$Path, [AllowEmptyString()][string]$Content)
    $resolvedPath = if ([IO.Path]::IsPathRooted($Path)) {
        $Path
    }
    else {
        Join-Path (Get-Location).Path $Path
    }
    [IO.File]::WriteAllText($resolvedPath, $Content, [Text.UTF8Encoding]::new($false))
}

function Get-RandomOutputPath {
    param([string]$BasePath, [string]$Extension = ".html")

    $candidate = "$BasePath$Extension"
    while (Test-Path -LiteralPath $candidate) {
        $candidate = "$BasePath.$(Get-Random -Minimum 0 -Maximum 32768)$Extension"
    }
    return $candidate
}

function Test-Markdown {
    if (-not $script:markdown_bin) { return $false }

    $testFile = Join-Path ([IO.Path]::GetTempPath()) ("pp-markdown-" + [guid]::NewGuid().ToString("N") + ".md")
    $htmlPath = ""
    try {
        Write-Utf8File -Path $testFile -Content "line 1`n`nline 2"
        $htmlPath = Convert-MarkdownFile $testFile
        $html = [IO.File]::ReadAllText($htmlPath) -replace "`r`n?", "`n"
        return $html.Trim() -match '^<p>line 1</p>\n(?:\n)?<p>line 2</p>$'
    }
    catch {
        return $false
    }
    finally {
        if (Test-Path -LiteralPath $testFile) { Remove-Item -LiteralPath $testFile -Force }
        if ($htmlPath -and (Test-Path -LiteralPath $htmlPath)) {
            Remove-Item -LiteralPath $htmlPath -Force
        }
    }
}

function Convert-MarkdownFile {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$InputFile,
        [string]$OutputDirectory
    )

    if (-not $script:markdown_bin) {
        throw "No Markdown converter was found."
    }

    $resolvedInput = (Resolve-Path -LiteralPath $InputFile -ErrorAction Stop).Path
    $baseName = if ($resolvedInput.EndsWith(".md", [StringComparison]::OrdinalIgnoreCase)) {
        $resolvedInput.Substring(0, $resolvedInput.Length - 3)
    }
    else {
        $resolvedInput
    }
    if ($OutputDirectory) {
        $outputDirectoryPath = [IO.Path]::GetFullPath($OutputDirectory)
        New-Item -ItemType Directory -Path $outputDirectoryPath -Force | Out-Null
        $baseName = Join-Path $outputDirectoryPath ([IO.Path]::GetFileName($baseName))
    }
    $outputPath = Get-RandomOutputPath -BasePath $baseName
    $arguments = @($script:markdown_arguments) + @($resolvedInput)

    try {
        $output = @(& $script:markdown_bin @arguments)
        $succeeded = $?
        $exitCode = $LASTEXITCODE
        if (-not $succeeded -or
            ($script:markdown_is_application -and $exitCode -ne 0)) {
            throw "Markdown conversion failed for '$resolvedInput'."
        }

        Write-Utf8File -Path $outputPath -Content ($output -join [Environment]::NewLine)
        return $outputPath
    }
    catch {
        if (Test-Path -LiteralPath $outputPath) {
            Remove-Item -LiteralPath $outputPath -Force
        }
        throw
    }
}

function global_variables_check {
    if ($script:header_file -eq ".header.html") {
        throw "'.header.html' is not a valid value for the setting 'header_file'."
    }
    if ($script:footer_file -eq ".footer.html") {
        throw "'.footer.html' is not a valid value for the setting 'footer_file'."
    }
    if ($script:github_profile -and $script:github_user_name -notmatch '^[A-Za-z0-9-]+$') {
        throw "Set github_user_name to a valid GitHub username when github_profile is enabled."
    }
    if ($script:devto_profile -and $script:devto_user_name -notmatch '^[A-Za-z0-9_-]+$') {
        throw "Set devto_user_name to a valid dev.to username when devto_profile is enabled."
    }
}

function Get-PostTitle {
    param([string]$Path)
    $content = Get-Content -LiteralPath $Path -Encoding UTF8
    $inside = $false
    foreach ($line in $content) {
        if ($line -match '<h3[^>]*><a class="ablack" href="[^"]*">') {
            $inside = $true
            continue
        }
        if ($inside -and $line -match '</a></h3>') { break }
        if ($inside) { $line }
    }
}

function Get-PostAuthor {
    param([string]$Path)
    $inside = $false
    foreach ($line in Get-Content -LiteralPath $Path -Encoding UTF8) {
        if ($line -match '<div class="subtitle"[^>]*>') {
            $inside = $true
            continue
        }
        if ($inside -and $line -match '<!-- text begin -->') { break }
        if ($inside) { $line -replace '</div>', '' }
    }
}

function Get-PostTags {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return @() }
    $header = [regex]::Escape($script:template_tags_line_header)
    foreach ($line in Get-Content -LiteralPath $Path -Encoding UTF8) {
        if ($line -match "^<p[^>]*>$header") {
            $plain = [regex]::Replace($line, '<[^>]*>', '')
            $plain = $plain.Substring($script:template_tags_line_header.Length).Trim()
            return @($plain -split '\s*,\s*' | Where-Object { $_ })
        }
    }
    return @()
}

function Get-HtmlFileContent {
    param(
        [string]$Path,
        [ValidateSet("text", "entry")][string]$Start = "entry",
        [ValidateSet("text", "entry")][string]$End = "entry",
        [switch]$Cut
    )

    $inside = $false
    $textEnd = $false
    $startMarker = "<!-- $Start begin -->"
    $endMarker = "<!-- $End end -->"
    $tagPattern = "^<p[^>]*>$([regex]::Escape($script:template_tags_line_header))"
    foreach ($line in Get-Content -LiteralPath $Path -Encoding UTF8) {
        if (-not $inside) {
            if ($line.Contains($startMarker)) { $inside = $true }
            continue
        }
        if ($line.Contains($endMarker)) { break }
        if ($textEnd) {
            if ($script:cut_tags -eq "no" -and $line -match $tagPattern) { $line }
            continue
        }
        if ($Cut -and $line -match $script:cut_line) {
            $line
            if ($End -eq "text") { break }
            $textEnd = $true
            continue
        }
        $line
    }
}

function Get-PostFiles {
    Get-ChildItem -LiteralPath (Get-Location) -File -Filter "*.html" |
        Sort-Object LastWriteTimeUtc -Descending |
        ForEach-Object { $_.FullName }
}

function Test-BoilerplateFile {
    param([string]$Path)
    $name = [IO.Path]::GetFileName($Path)
    if ($name -in $script:non_blogpost_files) { return $true }
    if ($name -in @(
        $script:index_file, $script:archive_index, $script:tags_index,
        [IO.Path]::GetFileName($script:footer_file), [IO.Path]::GetFileName($script:header_file),
        ".header.html", ".footer.html", ".title.html"
    )) { return $true }
    if ($script:about_page -and $name -eq $script:about_file) { return $true }
    if ($name.StartsWith($script:prefix_tags, [StringComparison]::OrdinalIgnoreCase)) { return $true }
    return $name -in $script:html_exclude
}

function Test-StaticPage {
    param([string]$Path)
    return (Get-PostTags -Path $Path) -contains $script:staticpage_tag
}

function Get-AbsoluteImageUrl {
    param([string]$Image)
    if (-not $Image) { return "" }
    if ($Image -match '^https?://') { return $Image }
    if (-not $script:global_url) { return "" }
    $uri = [Uri]$script:global_url
    if ($Image.StartsWith("//")) { return "$($uri.Scheme):$Image" }
    if ($Image.StartsWith("/")) { return "$($uri.Scheme)://$($uri.Authority)$Image" }
    return "$($script:global_url.TrimEnd('/'))/$($Image.TrimStart('.', '/'))"
}

function Get-SocialMeta {
    param([string]$ContentPath, [string]$Title, [bool]$IsIndex, [string]$Url)
    $type = if ($IsIndex) { "website" } else { "article" }
    $safeTitle = [Net.WebUtility]::HtmlEncode($Title.Replace('"', "'"))
    $description = $script:global_description
    $image = ""
    if (-not $IsIndex -and (Test-Path -LiteralPath $ContentPath)) {
        $lines = Get-Content -LiteralPath $ContentPath -Encoding UTF8 |
            Where-Object { $_ -notmatch "^<p[^>]*>$([regex]::Escape($script:template_tags_line_header))" }
        $description = ([regex]::Replace(($lines -join " "), '<[^>]*>', '') -replace '"', "'")
        if ($description.Length -gt 250) { $description = $description.Substring(0, 250) }
        $match = [regex]::Match(($lines -join "`n"), '<img[^>]*src\s*=\s*["'']([^"'']+)["'']', 'IgnoreCase')
        if ($match.Success) { $image = $match.Groups[1].Value }
    }
    if (-not $image) { $image = $script:global_twitter_card_image }
    $description = [Net.WebUtility]::HtmlEncode($description)
    $meta = [Collections.Generic.List[string]]::new()
    $meta.Add("<meta property='og:type' content='$type' />")
    $meta.Add("<meta property='og:title' content=`"$safeTitle`" />")
    $meta.Add("<meta property='og:description' content=`"$description`" />")
    if ($Url) { $meta.Add("<meta property='og:url' content='$Url' />") }
    $image = Get-AbsoluteImageUrl $image
    if ($image) { $meta.Add("<meta property='og:image' content='$image' />") }
    if ($script:global_twitter_username -and $Url) {
        $meta.Add("<meta name='twitter:card' content='summary' />")
        $meta.Add("<meta name='twitter:title' content=`"$safeTitle`" />")
        $meta.Add("<meta name='twitter:site' content='@$($script:global_twitter_username)' />")
        $meta.Add("<meta name='twitter:description' content=`"$description`" />")
        if ($image) { $meta.Add("<meta name='twitter:image' content='$image' />") }
    }
    return $meta
}

function Get-ExternalProfile {
    param([ValidateSet("GitHub", "DevTo")][string]$Service, [string]$Username)

    $escapedUsername = [Uri]::EscapeDataString($Username)
    if ($Service -eq "GitHub") {
        $uri = "https://api.github.com/users/$escapedUsername"
        $profileUrl = "https://github.com/$escapedUsername"
    }
    else {
        $uri = "https://dev.to/api/users/by_username?username=$escapedUsername"
        $profileUrl = "https://dev.to/$escapedUsername"
    }

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers @{ "User-Agent" = "PowershellPost" } `
            -TimeoutSec 20 -ErrorAction Stop
    }
    catch {
        throw "Unable to fetch the $Service profile for '$Username': $($_.Exception.Message)"
    }

    if (-not $response) { throw "The $Service profile response for '$Username' was empty." }
    $name = if ($response.name) { [string]$response.name } else { $Username }
    $bio = if ($Service -eq "GitHub") { [string]$response.bio } else { [string]$response.summary }
    $image = if ($Service -eq "GitHub") { [string]$response.avatar_url } else { [string]$response.profile_image }
    if ($image) {
        $imageUri = $null
        if (-not [Uri]::TryCreate($image, [UriKind]::Absolute, [ref]$imageUri) -or
            $imageUri.Scheme -ne "https") {
            $image = ""
        }
    }
    return [pscustomobject]@{
        Service = $Service
        Username = $Username
        Name = $name
        Bio = $bio
        Image = $image
        Url = $profileUrl
    }
}

function Get-PpProfiles {
    $profiles = [Collections.Generic.List[object]]::new()
    if ($script:github_profile) {
        $profiles.Add((Get-ExternalProfile -Service GitHub -Username $script:github_user_name))
    }
    if ($script:devto_profile) {
        $profiles.Add((Get-ExternalProfile -Service DevTo -Username $script:devto_user_name))
    }
    return $profiles.ToArray()
}

function New-AboutPage {
    param([object[]]$Profiles)

    $contentPath = Join-Path (Get-Location) (".about-" + [guid]::NewGuid().ToString("N") + ".content")
    $lines = [Collections.Generic.List[string]]::new()
    $author = [Net.WebUtility]::HtmlEncode($script:global_author)
    $lines.Add('<div class="about-page">')
    $lines.Add('<div class="about-intro">')
    $lines.Add("<h2>About me</h2>")
    $lines.Add("<h3>$author</h3>")
    $biography = if ($script:about_me) { $script:about_me } else { $script:global_description }
    foreach ($paragraph in ($biography -split '\r?\n\s*\r?\n')) {
        if (-not [string]::IsNullOrWhiteSpace($paragraph)) {
            $text = [Net.WebUtility]::HtmlEncode($paragraph.Trim()) -replace '\r?\n', '<br />'
            $lines.Add("<p>$text</p>")
        }
    }
    $lines.Add("</div>")
    foreach ($profile in $Profiles) {
        $name = [Net.WebUtility]::HtmlEncode($profile.Name)
        $url = [Net.WebUtility]::HtmlEncode($profile.Url)
        $service = [Net.WebUtility]::HtmlEncode($profile.Service)
        $lines.Add("<div class=`"about-profile`"><h3>$service</h3>")
        if ($profile.Image) {
            $image = [Net.WebUtility]::HtmlEncode($profile.Image)
            $lines.Add("<p class=`"about-avatar`"><a href=`"$url`" rel=`"noopener noreferrer`"><img src=`"$image`" alt=`"$name profile photo`" width=`"120`" /></a></p>")
        }
        $lines.Add("<p class=`"about-profile-name`"><a href=`"$url`" rel=`"noopener noreferrer`">$name</a></p>")
        if ($profile.Bio) {
            $bio = [Net.WebUtility]::HtmlEncode($profile.Bio)
            $lines.Add("<p>$bio</p>")
        }
        $lines.Add("</div>")
    }
    $lines.Add("</div>")

    Write-Utf8File -Path $contentPath -Content ($lines -join [Environment]::NewLine)
    try {
        New-HtmlPage -ContentPath $contentPath -OutputPath $script:about_file -IsIndex $true `
            -Title "About me" -Timestamp $null -Author $script:global_author
    }
    finally {
        if (Test-Path -LiteralPath $contentPath) { Remove-Item -LiteralPath $contentPath -Force }
    }
}

function Get-DisqusBody {
    if (-not $script:global_disqus_username) { return }
@"
<div id="disqus_thread"></div>
<script>
var disqus_shortname = "$($script:global_disqus_username)";
(function() {
var dsq = document.createElement("script"); dsq.type = "text/javascript"; dsq.async = true;
dsq.src = "//" + disqus_shortname + ".disqus.com/embed.js";
(document.getElementsByTagName("head")[0] || document.getElementsByTagName("body")[0]).appendChild(dsq);
})();
</script>
<noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
<a href="http://disqus.com" class="dsq-brlink">comments powered by <span class="logo-disqus">Disqus</span></a>
"@
}

function Get-DisqusFooter {
    if (-not $script:global_disqus_username) { return }
@"
<script>
var disqus_shortname = "$($script:global_disqus_username)";
(function () {
var s = document.createElement("script"); s.async = true;
s.type = "text/javascript"; s.src = "//" + disqus_shortname + ".disqus.com/count.js";
(document.getElementsByTagName("HEAD")[0] || document.getElementsByTagName("BODY")[0]).appendChild(s);
}());
</script>
"@
}

function Get-TwitterMarkup {
    param([string]$Url)
    if (-not $script:global_twitter_username -or -not $Url) { return }
    if (-not $script:global_disqus_username -and $script:global_twitter_cookieless -eq "true") {
        $id = Get-Random -Minimum 0 -Maximum 32768
        return "<p id='twitter'><a href='https://twitter.com/intent/tweet?url=$Url&text=$($script:template_twitter_comment)&via=$($script:global_twitter_username)'>$($script:template_comments) $($script:template_twitter_button)</a> <a href='https://twitter.com/search?q=$Url'><span id='count-$id'></span></a>&nbsp;</p>"
    }
    $prefix = if ($script:global_disqus_username) {
        "<p id=`"twitter`"><a href=`"$Url#disqus_thread`">$($script:template_comments)</a> &nbsp;"
    }
    else {
        "<p id=`"twitter`">$($script:template_comments)&nbsp;"
    }
    return "$prefix<a href=`"https://twitter.com/share`" class=`"twitter-share-button`" data-text=`"$($script:template_twitter_comment)`" data-url=`"$Url`" data-via=`"$($script:global_twitter_username)`">$($script:template_twitter_button)</a><script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=`"//platform.twitter.com/widgets.js`";fjs.parentNode.insertBefore(js,fjs);}}(document,`"script`",`"twitter-wjs`");</script></p>"
}

function New-HtmlPage {
    param(
        [string]$ContentPath,
        [string]$OutputPath,
        [bool]$IsIndex,
        [string]$Title,
        [AllowNull()][object]$Timestamp,
        [string]$Author
    )

    $content = @(Get-Content -LiteralPath $ContentPath -Encoding UTF8)
    $static = if (-not $IsIndex -and (Test-StaticPage $ContentPath)) { " hidden" } else { "" }
    $pageName = [IO.Path]::GetFileName($OutputPath) -replace '\.rebuilt$|\.tmp$', ''
    if ($pageName -match "^$([regex]::Escape($script:index_file))\.") { $pageName = $script:index_file }
    $fileUrl = [IO.Path]::GetFileName($OutputPath) -replace '\.rebuilt$', ''
    $lines = [Collections.Generic.List[string]]::new()
    if (Test-Path -LiteralPath ".header.html") { $lines.AddRange([string[]](Get-Content -LiteralPath ".header.html" -Encoding UTF8)) }
    $lines.Add("<title>$Title</title>")
    $pageUrl = Get-PpPublicUrl $pageName
    $lines.AddRange([string[]](Get-SocialMeta -ContentPath $ContentPath -Title $Title -IsIndex $IsIndex -Url $pageUrl))
    $lines.Add("</head><body>")
    $bodyBeginPath = if ($script:body_begin_file) { Resolve-ProjectFile $script:body_begin_file } else { "" }
    if ($bodyBeginPath -and (Test-Path -LiteralPath $bodyBeginPath)) {
        $lines.AddRange([string[]](Get-Content -LiteralPath $bodyBeginPath -Encoding UTF8))
    }
    $bodyBeginIndexPath = if ($script:body_begin_file_index) { Resolve-ProjectFile $script:body_begin_file_index } else { "" }
    if ($pageName -eq $script:index_file -and $bodyBeginIndexPath -and
        (Test-Path -LiteralPath $bodyBeginIndexPath)) {
        $lines.AddRange([string[]](Get-Content -LiteralPath $bodyBeginIndexPath -Encoding UTF8))
    }
    $lines.Add('<div id="divbodyholder">')
    $lines.Add('<div class="headerholder"><div class="header">')
    $lines.Add('<div id="title">')
    if (Test-Path -LiteralPath ".title.html") {
        $lines.AddRange([string[]](Get-Content -LiteralPath ".title.html" -Encoding UTF8))
    }
    $lines.Add('</div></div></div>')
    $lines.Add('<div id="divbody"><div class="content">')
    if (-not $IsIndex) {
        $lines.Add('<!-- entry begin -->')
        $lines.Add("<h3$static><a class=`"ablack`" href=`"$fileUrl`">")
        $lines.Add(($Title -replace '<p>', '' -replace '</p>', ''))
        $lines.Add('</a></h3>')
        $date = if ($Timestamp -is [datetime]) { $Timestamp } else { Get-Date }
        $lines.Add("<!-- $($script:date_inpost): #$(Format-PpDate $date $script:date_format_timestamp)# -->")
        $subtitle = "<div class=`"subtitle`"$static>$(Format-PpDate $date $script:date_format)"
        if ($Author) { $subtitle += " &mdash;`n$Author" }
        $lines.Add("$subtitle</div>")
        $lines.Add('<!-- text begin -->')
    }

    foreach ($line in $content) {
        $tagPattern = "^<p[^>]*>$([regex]::Escape($script:template_tags_line_header))"
        if (-not $IsIndex -and $line -match $tagPattern) {
            $line = $line -replace '^<p', "<p$static"
        }
        $lines.Add($line)
    }

    if (-not $IsIndex) {
        $lines.Add('<!-- text end -->')
        $postUrl = Get-PpPublicUrl $fileUrl
        $lines.Add((Get-TwitterMarkup $postUrl))
        $lines.Add('<!-- entry end -->')
    }
    $lines.Add('</div>')
    if (-not $IsIndex) {
        $disqus = Get-DisqusBody
        if ($disqus) { $lines.Add($disqus.TrimEnd()) }
    }
    if (Test-Path -LiteralPath ".footer.html") {
        $lines.AddRange([string[]](Get-Content -LiteralPath ".footer.html" -Encoding UTF8))
    }
    $lines.Add('</div></div>')
    $disqusFooter = Get-DisqusFooter
    if ($disqusFooter) { $lines.Add($disqusFooter.TrimEnd()) }
    $bodyEndPath = if ($script:body_end_file) { Resolve-ProjectFile $script:body_end_file } else { "" }
    if ($bodyEndPath -and (Test-Path -LiteralPath $bodyEndPath)) {
        $lines.AddRange([string[]](Get-Content -LiteralPath $bodyEndPath -Encoding UTF8))
    }
    $lines.Add('</body></html>')
    Write-Utf8File -Path $OutputPath -Content ($lines -join [Environment]::NewLine)
}

function Parse-PostFile {
    param([string]$SourcePath, [AllowNull()][object]$Timestamp, [string]$DestinationPath)

    $sourceLines = Get-Content -LiteralPath $SourcePath -Encoding UTF8
    $titleLine = $sourceLines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1
    if (-not $titleLine) { throw "Post '$SourcePath' is empty or has no title." }
    $title = [Net.WebUtility]::HtmlDecode(($titleLine -replace '<[^>]*>', '')).Trim()

    if ($DestinationPath) {
        $outputPath = $DestinationPath
    }
    else {
        $slug = if ($script:convert_filename) { ConvertTo-PostFileName $title } else { $title }
        if (-not $slug) { $slug = [guid]::NewGuid().ToString("N").Substring(0, 8) }
        $outputPath = Get-RandomOutputPath -BasePath $slug
    }

    $contentPath = "$outputPath.tmp"
    $content = [Collections.Generic.List[string]]::new()
    foreach ($line in ($sourceLines | Select-Object -Skip 1)) {
        $tagPrefix = "<p>$($script:template_tags_line_header)"
        if ($line.StartsWith($tagPrefix)) {
            $tagText = ($line -replace '</?p>', '').Substring($script:template_tags_line_header.Length).Trim()
            $tags = @($tagText -split '\s*,\s*' | Where-Object { $_ })
            if ($tags.Count) {
                $links = @($tags | ForEach-Object { "<a href='$($script:prefix_tags)$_.html'>$_</a>" })
                $content.Add("<p>$($script:template_tags_line_header) $($links -join ', ') </p>")
            }
        }
        else { $content.Add($line) }
    }

    try {
        Write-Utf8File -Path $contentPath -Content ($content -join [Environment]::NewLine)
        New-HtmlPage -ContentPath $contentPath -OutputPath $outputPath -IsIndex $false `
            -Title $title -Timestamp $Timestamp -Author $script:global_author
        return $outputPath
    }
    finally {
        if (Test-Path -LiteralPath $contentPath) { Remove-Item -LiteralPath $contentPath -Force }
    }
}

function Get-EntryEditor {
    if ($env:EDITOR) { return $env:EDITOR }
    return (Join-Path $env:WINDIR "System32\notepad.exe")
}

function Invoke-Editor {
    param([string]$Path)
    $editor = Get-EntryEditor
    if (-not (Get-Command -Name $editor -ErrorAction SilentlyContinue) -and
        -not (Test-Path -LiteralPath $editor -PathType Leaf)) {
        throw "Editor '$editor' was not found. Set the EDITOR environment variable."
    }
    Start-Process -FilePath $editor -ArgumentList @("`"$Path`"") -Wait
}

function Write-Entry {
    param([string]$InputFile, [switch]$Html)

    $format = if ((Test-Markdown) -and -not $Html) { "md" } else { "html" }
    $temporary = $InputFile
    $starterContent = ""
    if ($InputFile) {
        $candidate = if ([IO.Path]::IsPathRooted($InputFile)) {
            $InputFile
        }
        else {
            Join-Path $script:posts_root $InputFile
        }
        if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
            throw "The source file '$InputFile' was not found in '$($script:posts_root)'."
        }
        $temporary = (Resolve-Path -LiteralPath $candidate).Path
        Assert-PathWithinDirectory -Path $temporary -Directory $script:posts_root -Description "Post source"
        $format = [IO.Path]::GetExtension($temporary).TrimStart('.').ToLowerInvariant()
        if ($format -notin @("md", "html")) { $format = if ($Html) { "html" } else { "md" } }
        if ($Html) { $format = "html" }
        if ($format -eq "md" -and -not (Test-Markdown)) {
            throw "Markdown is not working. Please edit or post an HTML file instead."
        }
    }
    else {
        $temporary = Join-Path $script:posts_root ".entry-$([guid]::NewGuid().ToString('N')).$format"
        $example = if ($format -eq "md") {
            "The rest of the text file is a **Markdown** blog post.`n`n$($script:template_tags_line_header) keep-this-tag-format, tags-are-optional, example"
        }
        else {
            "<p>The rest of the text file is an <b>HTML</b> blog post.</p>`n`n<p>$($script:template_tags_line_header) keep-this-tag-format, tags-are-optional, example</p>"
        }
        $starterContent = "Title on this line`n`n$example"
        Write-Utf8File -Path $temporary -Content $starterContent
    }

    $postedPath = ""
    while ($true) {
        Invoke-Editor -Path $temporary
        if ($starterContent) {
            $editedContent = [IO.File]::ReadAllText($temporary) -replace "`r`n?", "`n"
            if ($editedContent -eq $starterContent) {
                Remove-Item -LiteralPath $temporary -Force
                Write-Host "No post created. Replace the starter title and text before publishing or saving a draft."
                return $false
            }
        }
        $source = $temporary
        $markdownOutput = ""
        if ($format -eq "md") {
            $markdownOutput = Convert-MarkdownFile $temporary -OutputDirectory $script:dist_root
            $source = $markdownOutput
        }
        $postedPath = Parse-PostFile -SourcePath $source

        $previewBase = if ($script:preview_url) { $script:preview_url.TrimEnd('/') } else { $script:global_url.TrimEnd('/') }
        $previewLink = if ($previewBase) { "$previewBase/$([IO.Path]::GetFileName($postedPath))" } else { Join-Path $script:dist_root ([IO.Path]::GetFileName($postedPath)) }
        Write-Host "To preview the entry, open $previewLink"
        $answer = Read-Host "[P]ost this entry, [E]dit again, [D]raft for later? (p/E/d)"
        if ($answer -match '^[pP]$') { break }
        if ($answer -match '^[dD]$') {
            $draftDirectory = Join-Path $script:posts_root "drafts"
            New-Item -ItemType Directory -Path $draftDirectory -Force | Out-Null
            $draftName = [IO.Path]::GetFileNameWithoutExtension($postedPath) + ".$format"
            $draft = Join-Path $draftDirectory $draftName
            Move-Item -LiteralPath $temporary -Destination $draft -Force
            Remove-Item -LiteralPath $postedPath -Force
            if ($markdownOutput -and (Test-Path -LiteralPath $markdownOutput)) {
                Remove-Item -LiteralPath $markdownOutput -Force
            }
            Write-Host "Saved your draft as '$draft'"
            return $true
        }
        Remove-Item -LiteralPath $postedPath -Force
        if ($markdownOutput -and (Test-Path -LiteralPath $markdownOutput)) {
            Remove-Item -LiteralPath $markdownOutput -Force
        }
    }

    if (-not $InputFile -and (Test-Path -LiteralPath $temporary)) {
        $sourceExtension = if ($format -eq "md") { ".md" } else { ".html" }
        $sourcePath = Join-Path $script:posts_root ([IO.Path]::GetFileNameWithoutExtension($postedPath) + $sourceExtension)
        Move-Item -LiteralPath $temporary -Destination $sourcePath -Force
    }
    elseif ($InputFile -and (Test-Path -LiteralPath $temporary)) {
        $sourceExtension = if ($format -eq "md") { ".md" } else { ".html" }
        $sourcePath = Join-Path $script:posts_root ([IO.Path]::GetFileNameWithoutExtension($postedPath) + $sourceExtension)
        if ([IO.Path]::GetFullPath($temporary) -ne [IO.Path]::GetFullPath($sourcePath)) {
            Move-Item -LiteralPath $temporary -Destination $sourcePath -Force
        }
    }
    if (Test-Path -LiteralPath $postedPath) {
        Remove-Item -LiteralPath $postedPath -Force
    }
    if ($markdownOutput -and (Test-Path -LiteralPath $markdownOutput)) {
        Remove-Item -LiteralPath $markdownOutput -Force
    }

    Write-Host "Posted $postedPath"
    $tags = Get-PostTags $postedPath
    if ($tags.Count) { Rebuild-Tags }
    return $false
}

function Edit-Post {
    param([string]$Path, [ValidateSet("keep", "new", "full")][string]$Mode = "keep")
    $candidate = if ([IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $script:posts_root $Path }
    $resolved = (Resolve-Path -LiteralPath $candidate -ErrorAction Stop).Path
    Assert-PathWithinDirectory -Path $resolved -Directory $script:posts_root -Description "Edit source"
    if ([IO.Path]::GetExtension($resolved) -notin @(".md", ".html")) {
        throw "Post sources must use the .md or .html extension."
    }
    Invoke-Editor $resolved
    return $resolved
}

function Get-BlogPostFiles {
    foreach ($path in Get-PostFiles) {
        if (Test-BoilerplateFile $path) { continue }
        if (Test-StaticPage $path) { continue }
        $path
    }
}

function Build-SourcePosts {
    $sources = @(Get-ChildItem -LiteralPath $script:posts_root -File |
        Where-Object { $_.Extension -in @(".md", ".html") -and $_.Name -notlike ".*" } |
        Sort-Object Name)
    $manifestPath = Join-Path $script:dist_root ".pp-posts.json"
    $previous = @()
    if (Test-Path -LiteralPath $manifestPath) {
        $previousData = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($previousData -is [array]) {
            $previous = $previousData
        }
        elseif ($previousData) {
            $previous = @($previousData)
        }
    }

    $built = [Collections.Generic.List[object]]::new()
    $outputNames = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($sourceFile in $sources) {
        $convertedPath = ""
        $conversionDirectory = ""
        $contentPath = $sourceFile.FullName
        try {
            if ($sourceFile.Extension -eq ".md") {
                if (-not $script:markdown_bin) {
                    throw "Cannot build '$($sourceFile.Name)': install a Markdown converter or remove the Markdown source."
                }
                $conversionDirectory = Join-Path ([IO.Path]::GetTempPath()) ("pp-build-" + [guid]::NewGuid().ToString("N"))
                New-Item -ItemType Directory -Path $conversionDirectory -Force | Out-Null
                $convertedPath = Convert-MarkdownFile $sourceFile.FullName -OutputDirectory $conversionDirectory
                $contentPath = $convertedPath
            }

            $lines = Get-Content -LiteralPath $contentPath -Encoding UTF8
            $titleLine = $lines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1
            if (-not $titleLine) { throw "Post source '$($sourceFile.Name)' is empty." }
            $title = [Net.WebUtility]::HtmlDecode(($titleLine -replace '<[^>]*>', '')).Trim()
            $slug = if ($script:convert_filename) { ConvertTo-PostFileName $title } else { $title }
            if (-not $slug) { throw "Post source '$($sourceFile.Name)' has a title that cannot form a filename." }
            $outputName = "$slug.html"
            if ($script:about_page -and $outputName -eq $script:about_file) {
                throw "Post '$($sourceFile.Name)' conflicts with the generated About page '$($script:about_file)'."
            }
            if (-not $outputNames.Add($outputName)) {
                throw "More than one source post generates '$outputName'. Give the posts distinct titles."
            }

            $destination = Join-Path $script:dist_root $outputName
            Parse-PostFile -SourcePath $contentPath -Timestamp $sourceFile.LastWriteTime -DestinationPath $destination | Out-Null
            $built.Add([pscustomobject]@{ source = $sourceFile.Name; output = $outputName })
        }
        finally {
            if ($convertedPath -and (Test-Path -LiteralPath $convertedPath)) {
                Remove-Item -LiteralPath $convertedPath -Force
            }
            if ($conversionDirectory -and (Test-Path -LiteralPath $conversionDirectory)) {
                Remove-Item -LiteralPath $conversionDirectory -Recurse -Force
            }
        }
    }

    $currentOutputs = @($built | ForEach-Object { $_.output })
    foreach ($old in $previous) {
        $oldOutput = [string]$old
        if ($oldOutput -and $oldOutput -notin $currentOutputs) {
            $stalePath = Join-Path $script:dist_root $oldOutput
            if ((Split-Path $oldOutput -Leaf) -eq $oldOutput -and (Test-Path -LiteralPath $stalePath)) {
                Remove-Item -LiteralPath $stalePath -Force
            }
        }
    }
    Write-Utf8File -Path $manifestPath -Content (ConvertTo-Json -InputObject $currentOutputs -Depth 4)
    if (-not $sources.Count) { Write-Host "No .md or .html source posts found in '$($script:posts_root)'." }
    Copy-PostAssetsToDist
}

function Copy-PostAssetsToDist {
    $draftsRoot = Join-Path $script:posts_root "drafts"
    foreach ($asset in Get-ChildItem -LiteralPath $script:posts_root -File -Recurse |
        Where-Object {
            $_.Extension -notin @(".md", ".html") -and
            $_.Name -notlike ".*" -and
            -not (Test-PathWithinDirectory $_.FullName $draftsRoot)
        }) {
        $relativePath = $asset.FullName.Substring($script:posts_root.TrimEnd('\', '/').Length).TrimStart('\', '/')
        $destination = Join-Path $script:dist_root $relativePath
        $destinationDirectory = Split-Path -Parent $destination
        New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
        Copy-Item -LiteralPath $asset.FullName -Destination $destination -Force
    }
}

function New-IndexEntryContent {
    param([string]$Path, [switch]$Cut)
    $lines = @(Get-HtmlFileContent -Path $Path -Start entry -End entry -Cut:$Cut)
    if ($Cut) {
        $lines = @($lines | ForEach-Object {
            if ($_ -match $script:cut_line) {
                "<p class=`"readmore`"><a href=`"$([IO.Path]::GetFileName($Path))`">$($script:template_read_more)</a></p>"
            }
            else { $_ }
        })
    }
    return $lines
}

function Rebuild-Index {
    Write-Host -NoNewline "Rebuilding the index "
    $contentPath = Join-Path (Get-Location) (".index-" + [guid]::NewGuid().ToString("N") + ".content")
    $entries = [Collections.Generic.List[string]]::new()
    $count = 0
    foreach ($path in Get-PostFiles) {
        if (Test-BoilerplateFile $path -or (Test-StaticPage $path)) { continue }
        if ($count -ge [int]$script:number_of_index_articles) { break }
        $entryContent = @(New-IndexEntryContent -Path $path -Cut ([bool]$script:cut_do))
        if ($entryContent.Count) { $entries.AddRange([string[]]$entryContent) }
        $entries.Add(".")
        $count++
    }
    $feed = if ($script:global_feedburner) { $script:global_feedburner } else { $script:blog_feed }
    $navigation = "<div id=`"all_posts`"><a href=`"$($script:archive_index)`">$($script:template_archive)</a> &mdash; <a href=`"$($script:tags_index)`">$($script:template_tags_title)</a> &mdash; <a href=`"$feed`">$($script:template_subscribe)</a>"
    if ($script:about_page) { $navigation += " &mdash; <a href=`"$($script:about_file)`">About me</a>" }
    $entries.Add("$navigation</div>")
    Write-Utf8File -Path $contentPath -Content ($entries -join [Environment]::NewLine)
    try {
        $temporary = "$($script:index_file).tmp"
        New-HtmlPage -ContentPath $contentPath -OutputPath $temporary -IsIndex $true -Title $script:global_title -Timestamp $null -Author $script:global_author
        Move-Item -LiteralPath $temporary -Destination $script:index_file -Force
    }
    finally {
        Remove-Item -LiteralPath $contentPath -Force -ErrorAction SilentlyContinue
    }
    Write-Host
}

function New-ArchivePage {
    param([switch]$Tags)
    $destination = if ($Tags) { $script:tags_index } else { $script:archive_index }
    $contentPath = Join-Path (Get-Location) (".archive-" + [guid]::NewGuid().ToString("N") + ".content")
    $lines = [Collections.Generic.List[string]]::new()
    if ($Tags) {
        $lines.Add("<h3>$($script:template_tags_title)</h3>")
        $lines.Add("<ul>")
        foreach ($tagPage in Get-ChildItem -LiteralPath (Get-Location) -File -Filter "$($script:prefix_tags)*.html" |
            Sort-Object Name) {
            $n = [regex]::Matches([IO.File]::ReadAllText($tagPage.FullName), '<!-- text begin -->').Count
            $tag = $tagPage.BaseName.Substring($script:prefix_tags.Length)
            $word = if ($n -eq 1) { $script:template_tags_posts_singular } elseif ($n -in 2, 3, 4) {
                $script:template_tags_posts_2_4
            } else { $script:template_tags_posts }
            $lines.Add("<li><a href=`"$($tagPage.Name)`">$tag</a> &mdash; $n $word</li>")
        }
        $lines.Add("</ul>")
    }
    else {
        $lines.Add("<h3>$($script:template_archive_title)</h3>")
        $previousMonth = ""
        foreach ($path in Get-BlogPostFiles) {
            $item = Get-Item -LiteralPath $path
            $month = Format-PpDate $item.LastWriteTime $script:date_allposts_header
            if ($month -ne $previousMonth) {
                if ($previousMonth) { $lines.Add("</ul>") }
                $lines.Add("<h4 class='allposts_header'>$month</h4><ul>")
                $previousMonth = $month
            }
            $title = (Get-PostTitle $path) -join " "
            $date = Format-PpDate $item.LastWriteTime $script:date_format
            $lines.Add("<li><a href=`"$([IO.Path]::GetFileName($path))`">$title</a> &mdash; $date</li>")
        }
        if ($previousMonth) { $lines.Add("</ul>") }
    }
    $lines.Add("<div id=`"all_posts`"><a href=`"./$($script:index_file)`">$($script:template_archive_index_page)</a></div>")
    Write-Utf8File -Path $contentPath -Content ($lines -join [Environment]::NewLine)
    try {
        $title = if ($Tags) {
            "$($script:global_title) &mdash; $($script:template_tags_title)"
        } else {
            "$($script:global_title) &mdash; $($script:template_archive_title)"
        }
        $temporary = "$destination.tmp"
        New-HtmlPage -ContentPath $contentPath -OutputPath $temporary -IsIndex $true -Title $title -Timestamp $null -Author $script:global_author
        Move-Item -LiteralPath $temporary -Destination $destination -Force
    }
    finally {
        Remove-Item -LiteralPath $contentPath -Force -ErrorAction SilentlyContinue
    }
}

function Rebuild-Tags {
    param([string[]]$Files, [string[]]$Tags)
    $rebuildAll = -not $Files -or -not $Tags
    if ($rebuildAll) {
        $Files = @(Get-BlogPostFiles)
        Get-ChildItem -LiteralPath (Get-Location) -File -Filter "$($script:prefix_tags)*.html" |
            Remove-Item -Force
        $Tags = @($Files | ForEach-Object { Get-PostTags $_ } | Sort-Object -Unique)
    }
    else {
        foreach ($tag in $Tags) {
            $tagPath = "$($script:prefix_tags)$tag.html"
            if (Test-Path -LiteralPath $tagPath) { Remove-Item -LiteralPath $tagPath -Force }
        }
    }

    foreach ($tag in $Tags) {
        if ($tag -eq $script:staticpage_tag) { continue }
        $matching = @($Files | Where-Object { (Get-PostTags $_) -contains $tag } |
            Sort-Object { (Get-Item -LiteralPath $_).LastWriteTimeUtc } -Descending)
        if (-not $matching.Count) { continue }
        $contentPath = "$($script:prefix_tags)$tag.tmp.html"
        $tagContent = [Collections.Generic.List[string]]::new()
        foreach ($path in $matching) {
            $tagContent.AddRange([string[]](New-IndexEntryContent -Path $path -Cut ([bool]$script:cut_do)))
        }
        Write-Utf8File -Path $contentPath -Content ($tagContent -join [Environment]::NewLine)
        $destination = "$($script:prefix_tags)$tag.html"
        $title = "$($script:global_title) &mdash; $($script:template_tag_title) `"$tag`""
        New-HtmlPage -ContentPath $contentPath -OutputPath $destination -IsIndex $true -Title $title -Timestamp $null -Author $script:global_author
        Remove-Item -LiteralPath $contentPath -Force
    }
}

function Rebuild-AllEntries {
    Write-Host -NoNewline "Rebuilding all entries "
    foreach ($path in Get-PostFiles) {
        if (Test-BoilerplateFile $path) { continue }
        $title = (Get-PostTitle $path) -join " "
        $author = (Get-PostAuthor $path) -join " "
        $timestamp = (Get-Item -LiteralPath $path).LastWriteTime
        $contentPath = ".entry-$([guid]::NewGuid().ToString('N')).content"
        $body = @(Get-HtmlFileContent -Path $path -Start text -End text)
        Write-Utf8File -Path $contentPath -Content ($body -join [Environment]::NewLine)
        try {
            New-HtmlPage -ContentPath $contentPath -OutputPath "$path.rebuilt" -IsIndex $false -Title $title -Timestamp $timestamp -Author $author
            Move-Item -LiteralPath "$path.rebuilt" -Destination $path -Force
            (Get-Item -LiteralPath $path).LastWriteTime = $timestamp
        }
        finally {
            Remove-Item -LiteralPath $contentPath -Force -ErrorAction SilentlyContinue
            Remove-Item -LiteralPath "$path.rebuilt" -Force -ErrorAction SilentlyContinue
        }
        Write-Host -NoNewline "."
    }
    Write-Host
}

function Get-RssEscape {
    param([AllowNull()][string]$Value)
    [Security.SecurityElement]::Escape($Value)
}

function Make-Rss {
    $temporary = Get-RandomOutputPath -BasePath $script:blog_feed
    $now = Get-Date
    $lines = [Collections.Generic.List[string]]::new()
    $lines.Add('<?xml version="1.0" encoding="UTF-8" ?>')
    $lines.Add('<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:dc="http://purl.org/dc/elements/1.1/">')
    $indexUrl = Get-PpPublicUrl $script:index_file
    $feedUrl = Get-PpPublicUrl $script:blog_feed
    $channelStart = "<channel><title>$(Get-RssEscape $script:global_title)</title>"
    if ($indexUrl) { $channelStart += "<link>$indexUrl</link>" }
    $lines.Add($channelStart)
    $lines.Add("<description>$(Get-RssEscape $script:global_description)</description><language>en</language>")
    $lines.Add("<lastBuildDate>$($now.ToUniversalTime().ToString('r'))</lastBuildDate>")
    $lines.Add("<pubDate>$($now.ToUniversalTime().ToString('r'))</pubDate>")
    if ($feedUrl) {
        $lines.Add("<atom:link href=`"$feedUrl`" rel=`"self`" type=`"application/rss+xml`" />")
    }
    $count = 0
    foreach ($path in Get-BlogPostFiles) {
        if ($count -ge [int]$script:number_of_feed_articles) { break }
        $title = (Get-PostTitle $path) -join " "
        $author = (Get-PostAuthor $path) -join " "
        $item = Get-Item -LiteralPath $path
        $body = @(Get-HtmlFileContent -Path $path -Start text -End entry -Cut ([bool]$script:cut_do)) -join "`n"
        $body = $body.Replace("]]>", "]]]]><![CDATA[>")
        $url = Get-PpPublicUrl ([IO.Path]::GetFileName($path))
        $lines.Add("<item><title>$(Get-RssEscape $title)</title><description><![CDATA[$body]]></description>")
        if ($url) { $lines.Add("<link>$url</link><guid>$url</guid>") }
        $lines.Add("<dc:creator>$(Get-RssEscape $author)</dc:creator><pubDate>$($item.LastWriteTime.ToUniversalTime().ToString('r'))</pubDate></item>")
        $count++
    }
    $lines.Add("</channel></rss>")
    Write-Utf8File -Path $temporary -Content ($lines -join [Environment]::NewLine)
    Move-Item -LiteralPath $temporary -Destination $script:blog_feed -Force
    Write-Host "Made RSS $($script:blog_feed)"
}

function Create-Includes {
    $indexUrl = Get-PpPublicUrl $script:index_file
    if (-not $indexUrl) { $indexUrl = $script:index_file }
    $title = "<h1 class=`"nomargin`"><a class=`"ablack`" href=`"$indexUrl`">$($script:global_title)</a></h1>"
    Write-Utf8File ".title.html" "$title`n<div id=`"description`">$($script:global_description)</div>"
    $headerPath = if ($script:header_file) { Resolve-ProjectFile $script:header_file } else { "" }
    if ($headerPath -and (Test-Path -LiteralPath $headerPath)) {
        Copy-Item -LiteralPath $headerPath -Destination ".header.html" -Force
    }
    else {
        $header = @(
            '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
            '<html xmlns="http://www.w3.org/1999/xhtml"><head>',
            '<meta http-equiv="Content-type" content="text/html;charset=UTF-8" />',
            '<meta name="viewport" content="width=device-width, initial-scale=1.0" />'
        )
        foreach ($css in $script:css_include) {
            $header += "<link rel=`"stylesheet`" href=`"$css`" type=`"text/css`" />"
        }
        $feed = if ($script:global_feedburner) { $script:global_feedburner } else { $script:blog_feed }
        $header += "<link rel=`"alternate`" type=`"application/rss+xml`" title=`"$($script:template_subscribe_browser_button)`" href=`"$feed`" />"
        Write-Utf8File ".header.html" ($header -join [Environment]::NewLine)
    }
    $footerPath = if ($script:footer_file) { Resolve-ProjectFile $script:footer_file } else { "" }
    if ($footerPath -and (Test-Path -LiteralPath $footerPath)) {
        Copy-Item -LiteralPath $footerPath -Destination ".footer.html" -Force
    }
    else {
        $mail = $script:global_email.Replace("@", "&#64;").Replace(".", "&#46;")
        $author = if ($script:global_author_url) {
            "<a href=`"$($script:global_author_url)`">$($script:global_author)</a>"
        }
        else { $script:global_author }
        $footer = "<div id=`"footer`">$($script:global_license) $author &mdash; <a href=`"mailto:$mail`">$mail</a><br/>"
        $sourceLink = if ($script:global_source_url) {
            "<a href=`"$($script:global_source_url)`">PowershellPost</a>"
        }
        else { "PowershellPost" }
        $footer += "Generated with $sourceLink, a single PowerShell script to easily create blogs</div>"
        Write-Utf8File ".footer.html" $footer
    }
}

function Delete-Includes {
    foreach ($path in @(".title.html", ".footer.html", ".header.html")) {
        if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Force }
    }
}

function Create-Css {
    if (-not $script:css_include.Count) { $script:css_include = @("main.css", "blog.css") }
    foreach ($css in $script:css_include) {
        if ($css -match '^(https?:)?//' -or [IO.Path]::IsPathRooted($css)) { continue }
        $sourceCss = Resolve-ProjectFile $css
        if ((Test-Path -LiteralPath $sourceCss -PathType Leaf) -and
            [IO.Path]::GetFullPath($sourceCss) -ne [IO.Path]::GetFullPath((Join-Path (Get-Location) $css))) {
            Copy-Item -LiteralPath $sourceCss -Destination (Join-Path (Get-Location) $css) -Force
        }
    }
    if (-not (Test-Path -LiteralPath "blog.css")) {
        Write-Utf8File "blog.css" @'
#title{font-size:x-large}a.ablack{color:#172b4d!important}li{margin-bottom:10px}
ul,ol{margin-left:24px;margin-right:24px}#all_posts{margin-top:32px;text-align:center;padding:16px;background:#f3f6fa;border-radius:8px}
.subtitle{font-size:small;margin:12px 0;color:#667085}.content p{margin-left:24px;margin-right:24px;line-height:1.75}
h1{margin-bottom:12px!important}#description{font-size:large;margin-bottom:12px;color:#526174}
h3{margin-top:36px;margin-bottom:8px}h4{margin-left:24px;margin-right:24px}
img{max-width:100%}#twitter{line-height:20px;vertical-align:top;text-align:right;font-style:italic;color:#333;margin-top:24px;font-size:14px}
.about-page{max-width:720px;margin:12px auto 28px}.about-intro{padding:8px 0 18px}
.about-page h2{margin:0 24px 12px;color:#172b4d;font-size:2rem}.about-page h3{margin:8px 24px;color:#344054}
.about-page p{margin:10px 24px}.about-profile{display:inline-block;vertical-align:top;box-sizing:border-box;width:calc(50% - 14px);min-width:220px;margin:8px 5px;padding:20px;background:#f7f9fc;border:1px solid #e4eaf2;border-radius:12px}
.about-profile h3{margin:0 0 12px;font-size:1.1rem}.about-avatar{text-align:left}.about-avatar img{width:96px;height:96px;object-fit:cover;border-radius:50%;border:3px solid #fff;box-shadow:0 2px 10px rgba(23,43,77,.14)}
.about-profile-name{font-size:1.1rem;font-weight:bold}.about-profile a{color:#1769aa!important}
@media(max-width:600px){.about-profile{display:block;width:auto;margin:12px 18px}#divbody{padding:0 18px 24px}.content p{margin-left:12px;margin-right:12px}}
'@
    }
    if (-not (Test-Path -LiteralPath "main.css") -and (Test-Path -LiteralPath (Join-Path (Get-Location) "..\style.css"))) {
        Copy-Item -LiteralPath (Join-Path (Get-Location) "..\style.css") -Destination "main.css"
    }
    elseif (-not (Test-Path -LiteralPath "main.css")) {
        Write-Utf8File "main.css" @'
*{box-sizing:border-box}
body{font-family:Georgia,"Times New Roman",Times,serif;margin:0;padding:0;background:#eef2f6;color:#27364b;line-height:1.6}
#divbodyholder{padding:8px;background:#e3eaf2;width:calc(100% - 32px);max-width:920px;margin:32px auto;border-radius:14px;box-shadow:0 8px 28px rgba(28,48,74,.08)}
#divbody{border:1px solid #dce3eb;background:#fff;padding:0 48px 28px;border-radius:10px}
.headerholder{background:#f8fafc;border:1px solid #e5eaf0;border-radius:10px 10px 0 0}
.header{width:100%;max-width:800px;margin:0 auto;padding:28px 20px 14px}
.content{margin:0 auto 5%;max-width:800px}.nomargin{margin:0}.description{margin-top:10px;border-top:solid 1px #dce3eb;padding:10px 0}
h3{font-size:20pt;width:100%;font-weight:bold;margin-top:32px;margin-bottom:0}.clear{clear:both}
#footer{padding-top:16px;border-top:solid 1px #dce3eb;color:#667085;text-align:center;font-size:small;font-family:"Courier New",monospace}
a{text-decoration:none;color:#1769aa!important}a:visited{text-decoration:none;color:#4b61a8!important}a:hover{text-decoration:underline}
blockquote{background:#f7f9fc;border-left:solid 4px #91b5d8;margin-left:12px;padding:12px 12px 12px 24px;border-radius:0 8px 8px 0}
blockquote img,blockquote iframe{margin:12px 0}
@media(max-width:600px){#divbodyholder{width:calc(100% - 16px);margin:8px auto;padding:4px}#divbody{padding:0 16px 22px}.header{padding:20px 12px 10px}}
'@
    }
}

function List-Posts {
    $files = @(Get-PostFiles | Where-Object { -not (Test-BoilerplateFile $_) })
    if (-not $files.Count) {
        Write-Host "No posts yet. Use 'pp.ps1 post' to create one"
        return
    }
    $number = 1
    foreach ($path in $files) {
        $title = (Get-PostTitle $path) -join " "
        $date = Format-PpDate (Get-Item -LiteralPath $path).LastWriteTime $script:date_format
        "{0,3}  {1}  {2}" -f $number, $title, $date
        $number++
    }
}

function List-Tags {
    param([switch]$ByCount)
    $rows = [Collections.Generic.List[object]]::new()
    foreach ($path in Get-ChildItem -LiteralPath (Get-Location) -File -Filter "$($script:prefix_tags)*.html") {
        $tag = $path.BaseName.Substring($script:prefix_tags.Length)
        $count = [regex]::Matches([IO.File]::ReadAllText($path.FullName), '<!-- text begin -->').Count
        $word = if ($count -eq 1) { $script:template_tags_posts_singular } else { $script:template_tags_posts }
        $rows.Add([pscustomobject]@{ Tag = $tag; Count = $count; Word = $word })
    }
    if (-not $rows.Count) { Write-Host "No posts yet. Use 'pp.ps1 post' to create one"; return }
    if ($ByCount) { $rows = [Collections.Generic.List[object]]::new([object[]]@($rows | Sort-Object Count -Descending)) }
    foreach ($row in $rows) {
        "{0,-30} {1,4} {2}" -f $row.Tag, $row.Count, $row.Word
    }
}

function Reset-Blog {
    $answer = Read-Host 'Are you sure you want to delete all blog entries? Type "Yes, I am!" to confirm'
    if ($answer -ne "Yes, I am!") {
        Write-Host "Nothing was modified."
        return
    }
    Get-ChildItem -LiteralPath $script:dist_root -Force |
        Remove-Item -Recurse -Force
    Write-Host "Cleared generated files from '$($script:dist_root)'. Source posts were kept."
}

function Show-Usage {
    Write-Host "$($script:global_software_name) v$($script:global_software_version)"
    Write-Host "Usage: .\pp.ps1 command [options] [filename]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  post [-html] [filename]  Create a post or edit a source under posts."
    Write-Host "  edit [-n|-f] filename    Edit a source post under posts."
    Write-Host "  delete filename          Delete a source post and rebuild dist."
    Write-Host "  rebuild                  Build all source posts into dist."
    Write-Host "  reset                    Clear dist only; posts are preserved."
    Write-Host "  list                     List generated posts in dist."
    Write-Host "  tags [-n]                List generated tags."
}

function Save-BlogBackup {
    $html = @(Get-ChildItem -LiteralPath $script:dist_root -File -Filter "*.html")
    if (-not $html.Count) { return }
    $backupPath = Join-Path $script:dist_root ".backup.zip"
    $yesterdayPath = Join-Path $script:dist_root ".yesterday.zip"
    Compress-Archive -LiteralPath $html.FullName -DestinationPath $backupPath -Force
    if (-not (Test-Path -LiteralPath $yesterdayPath) -or
        (Get-Item $yesterdayPath).LastWriteTime.Date -ne (Get-Date).Date) {
        Copy-Item $backupPath $yesterdayPath -Force
    }
}

function Invoke-PpMain {
    param([string[]]$Arguments)

    global_variables
    Import-PpConfig
    Initialize-PpPaths
    Find-Markdown
    global_variables_check

    if (-not $Arguments.Count) { Show-Usage; return }
    $command = $Arguments[0].ToLowerInvariant()
    if ($command -notin @("post", "edit", "delete", "rebuild", "reset", "list", "tags")) {
        Show-Usage
        throw "Unknown command '$command'."
    }
    if ($command -eq "list" -or $command -eq "tags") {
        Push-Location $script:dist_root
        try {
            if ($command -eq "list") { List-Posts }
            else { List-Tags -ByCount:($Arguments -contains "-n") }
        }
        finally { Pop-Location }
        return
    }
    if ($command -eq "reset") { Reset-Blog; return }

    Push-Location $script:dist_root
    try {
        Save-BlogBackup
        Create-Css
        Create-Includes
        $draftSaved = $false
        switch ($command) {
            "post" {
                $htmlMode = $Arguments -contains "-html"
                $inputFile = $Arguments | Where-Object { $_ -ne "post" -and $_ -ne "-html" } | Select-Object -First 1
                $draftSaved = Write-Entry -InputFile $inputFile -Html:$htmlMode
            }
            "edit" {
                $file = $Arguments | Where-Object { $_ -notin @("edit", "-n", "-f") } | Select-Object -First 1
                if (-not $file) { throw "Please specify a valid .md or .html file to edit." }
                $mode = if ($Arguments -contains "-f") { "full" } elseif ($Arguments -contains "-n") { "new" } else { "keep" }
                Edit-Post -Path $file -Mode $mode
            }
            "delete" {
                $file = $Arguments | Select-Object -Skip 1 | Select-Object -First 1
                if (-not $file) { throw "Please specify a post source file to delete." }
                $sourcePath = if ([IO.Path]::IsPathRooted($file)) { $file } else { Join-Path $script:posts_root $file }
                if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
                    throw "Source post '$file' was not found in '$($script:posts_root)'."
                }
                Assert-PathWithinDirectory -Path $sourcePath -Directory $script:posts_root -Description "Post source"
                Remove-Item -LiteralPath $sourcePath -Force
            }
        }
        if ($draftSaved) { return }
        Build-SourcePosts
        if ($script:about_page) {
            $profiles = @(Get-PpProfiles)
            New-AboutPage -Profiles $profiles
        }
        else {
            $manifestPath = Join-Path $script:dist_root ".pp-posts.json"
            $sourceOutputs = if (Test-Path -LiteralPath $manifestPath) {
                @(Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json)
            }
            else { @() }
            $aboutPath = Join-Path $script:dist_root $script:about_file
            if ($script:about_file -notin $sourceOutputs -and (Test-Path -LiteralPath $aboutPath)) {
                Remove-Item -LiteralPath $aboutPath -Force
            }
        }
        Rebuild-Tags
        Rebuild-Index
        New-ArchivePage
        New-ArchivePage -Tags
        Make-Rss
    }
    finally {
        try { Delete-Includes }
        finally { Pop-Location }
    }
}

if ($MyInvocation.InvocationName -ne ".") {
    try {
        Invoke-PpMain -Arguments $args
    }
    catch {
        Write-Error $_
        exit 1
    }
}
