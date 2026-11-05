# PowershellPost

PowershellPost is a small, single-script blog publisher for Windows PowerShell. Write source posts in `posts`; generated HTML, CSS, RSS, and supporting pages are written to `dist`. The `posts` directory is never used as the publication output.

## Requirements

- Windows PowerShell 5.1 or PowerShell 7.
- No extra Markdown software is required. If the script finds `Markdown.pl` with Perl or a `markdown` command on `PATH`, it uses that; otherwise it uses its built-in PowerShell converter.
- An editor for interactive `post` and `edit`. Notepad is the default. Set `EDITOR` to the editor executable path to use another editor.

## Project layout

Run the script from the project directory, where `.pp.conf` is located:

```text
my-blog/
|-- pp.ps1
|-- .pp.conf          # optional settings
|-- posts/
|   |-- first-post.md
|   |-- about.html
|   |-- images/
|   |   `-- photo.jpg
|   `-- drafts/          # optional; not scanned or copied
`-- dist/             # created/updated by the script
```

Only direct `.md` and `.html` files in `posts` are built as posts. Other non-hidden files beneath `posts` are copied to the matching relative path in `dist` (for example, `posts/images/photo.jpg` becomes `dist/images/photo.jpg`). The `posts/drafts` directory is excluded from both post scanning and asset copying. Source files use this format:

```markdown
The post title

The post body goes here.

Tags: windows, powershell
```

The first non-empty line is the title. For Markdown sources, put the tags line in the Markdown source as shown. HTML sources use ordinary HTML for the body, for example:

```html
My HTML post

<p>Body text.</p>
<p>Tags: windows, powershell</p>
```

Tags must be the final post metadata paragraph and use the configured `template_tags_line_header` text. The generated filename is based on the title by default.

The built-in converter supports paragraphs, headings, bold and italic text, inline and fenced code, links, images, blockquotes, horizontal rules, and simple ordered or unordered lists. Raw HTML lines are passed through. For full CommonMark support, install a compatible `markdown` command or provide `Markdown.pl` and Perl.

## Usage

From PowerShell in the project directory:

```powershell
.\pp.ps1 rebuild
.\pp.ps1 list
.\pp.ps1 tags
.\pp.ps1 tags -n
.\pp.ps1 post
.\pp.ps1 post first-post.md
.\pp.ps1 edit first-post.md
.\pp.ps1 delete first-post.md
.\pp.ps1 reset
```

- `rebuild` reads every source post from `posts` and regenerates the site in `dist`. It also refreshes the index, archive, tag pages, and RSS feed.
- `post` opens a new post in the editor. To publish or edit an existing source, pass its filename, for example `.\pp.ps1 post 1.md`. Choose `P` to publish or `D` to save the edited entry under `posts/drafts` without rebuilding the site.
- `post -html` creates or edits an HTML source even when a Markdown converter is available.
- `edit` opens a source post in `posts`; `-n` and `-f` are accepted for compatibility. Changing a title changes the generated filename on the next build.
- `delete` removes a source file from `posts` and rebuilds the site.
- `list` and `tags` inspect the generated site in `dist`.
- `reset` asks for confirmation and clears `dist` only. It never removes source posts.

If `EDITOR` is not set, Notepad is used. To select a different editor executable for the current PowerShell session:

```powershell
$env:EDITOR = "notepad.exe"
```

Generated files can be previewed by opening `dist/index.html` in a browser. Configure `global_url` in `.pp.conf` when publishing so generated links and social metadata use the public blog URL.

## Configuration

`.pp.conf` is an optional UTF-8 text file in the project root. Use one `name=value` setting per line; blank lines and lines beginning with `#` are ignored. Wrap values in single or double quotes if desired. Lists are comma-separated:

```text
global_title=My Windows blog
global_description=Notes about PowerShell
global_url=https://example.com/blog
global_author=Alex Example
global_author_url=https://example.com/about
global_twitter_username=example
global_source_url=https://github.com/your-name/your-blog
global_email=alex@example.com
number_of_index_articles=8
number_of_feed_articles=10
posts_dir=posts
dist_dir=dist
css_include=main.css,blog.css
html_exclude=legal.html,contact.html
```

The main configurable settings are:

| Setting | Purpose |
|---|---|
| `posts_dir`, `dist_dir` | Source and generated-output directories. Relative paths resolve from the project root. |
| `global_title`, `global_description`, `global_url` | Blog identity, description, and public base URL. Set `global_url=false` or `global_url=no` to omit absolute public URLs; internal navigation remains relative. |
| `global_author`, `global_author_url`, `global_source_url`, `global_email`, `global_license` | Author and footer information. Set either URL setting to `false` or `no` to show the corresponding name as plain text rather than a link. |
| `index_file`, `archive_index`, `tags_index`, `blog_feed` | Generated index, archive, tags index, and RSS filenames. |
| `number_of_index_articles`, `number_of_feed_articles` | Maximum number of recent posts in the home page and feed. |
| `cut_do`, `cut_line`, `cut_tags`, `template_read_more` | Optional home-page/feed excerpt behavior. |
| `prefix_tags`, `staticpage_tag`, `template_tags_line_header` | Tag-page naming and post tag metadata. |
| `css_include`, `html_exclude`, `non_blogpost_files` | CSS references and files to exclude from post listings. Lists are comma-separated. |
| `header_file`, `footer_file`, `body_begin_file`, `body_end_file`, `body_begin_file_index` | Optional custom page fragments. Relative paths resolve from the project root. |
| `global_twitter_username`, `global_twitter_card_image`, `global_twitter_cookieless` | Optional social metadata and sharing controls. Set the username to `false` or `no` to omit Twitter integration, or the card image to `false` or `no` to omit that image. |
| `global_disqus_username` | Optional Disqus comments integration. |
| `global_feedburner` | Optional alternate subscription URL. |
| `date_format`, `date_format_full`, `date_format_timestamp`, `date_allposts_header` | Display and feed date formats. The defaults use `strftime`-style tokens such as `%B`, `%d`, `%Y`, `%H`, `%M`, `%S`, and `%z`. |
| `save_markdown` | Retained for compatibility; source files are preserved in `posts` so they can be rebuilt. |

Directory settings can be absolute paths or paths relative to the project root. They must point to different directories.

For URL-valued settings, `false`, `no`, and `0` (case-insensitive) all mean “disabled.”

## Output and safety

The script keeps a `.pp-posts.json` manifest inside `dist` to remove generated post pages that correspond to source posts which were deleted or renamed. Other files in `dist` are not tracked by that manifest. Backups of existing generated HTML are written to `dist/.backup.zip` and `dist/.yesterday.zip`.

Google Analytics configuration and embedding are not included.
