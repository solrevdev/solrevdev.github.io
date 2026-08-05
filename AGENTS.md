# AGENTS.md

Repository-specific guidance for AI agents working on this Jekyll blog.

## Project Overview

This is the source for `solrevdev.com`, a Jekyll-based static blog using the
Hyde theme with custom styling.

## Blog Posts

Blog posts live in `_posts/` and use standard Jekyll front matter. New posts
should include:

```yaml
---
published: false
layout: post
title: Post Title
description: One concise SEO description.
summary: One concise home-page teaser.
cover_image: /images/post-cover.svg
image: /images/post-cover.png
tags:
- dotnet
- csharp
---
```

Keep `published: false` while drafting unless the user explicitly asks to
publish the article.

## Drafting Workflow

- Before finalizing a draft, ask the user what publication date they want.
- Drafts live in `_posts/` with `published: false`. This repo has no `_drafts/`
  folder, so keep the file where it is and flip the flag when it goes live.
- When publishing, rename the file to `_posts/YYYY-MM-DD-slug.md` and make sure
  any `date:` front matter, if present, matches that filename date.
- Do not silently publish an article by removing `published: false`.
- Prefer `published: false` with the intended date over a future date. Setting a
  future date does hold a post back, but it fails silently and needs a manual
  step later. See the section below before choosing it.
- If the user asks for a PR, keep the PR focused on the article and its related
  assets unless they explicitly ask for wider site changes.

## Queuing A Post With A Future Date

A future date works as a queue, but it does not publish anything by itself.
Understand the mechanism before using it.

`_config.yml` sets no `future` key, so Jekyll defaults to `future: false` and
excludes any post dated later than the build. This site is a legacy GitHub Pages
build: there is no Actions workflow, `_site` is gitignored, and GitHub runs
Jekyll server-side only when something pushes. Nothing rebuilds on a schedule.

So merging a future-dated post does nothing on the day it is due. The post stays
invisible, with no error anywhere, until a build runs on or after its date.

**If you use a future date, a rebuild must be triggered on or after that date.**
Request one through the Pages build API, which avoids an empty commit:

```bash
gh api -X POST repos/solrevdev/solrevdev.github.io/pages/builds
```

Do not run that before the date. A build run early just rebuilds the site
without the post and changes nothing.

Verify locally first. If the post does not appear in a plain build, it will not
appear on GitHub either:

```bash
# no --future flag, so this mirrors what GitHub Pages does
bundle exec jekyll build --destination /tmp/jekyll-check --quiet
ls /tmp/jekyll-check/YYYY/MM/DD/
```

Then trigger the build and confirm it landed:

```bash
gh api -X POST repos/solrevdev/solrevdev.github.io/pages/builds
gh api repos/solrevdev/solrevdev.github.io/pages/builds/latest --jq '.status'
curl -s -o /dev/null -w '%{http_code}\n' https://solrevdev.com/YYYY/MM/DD/slug.html
```

`status` should reach `built`, and the URL should return `200`. The CDN can lag a
few minutes after a successful build.

Checks worth running before triggering, in this order:

1. Today is on or after the post date.
2. The post file exists and has no `published: false`.
3. The branch is `master` and the post is pushed. Pages builds `master`.
4. A local build without `--future` includes the post.

A fuller script that wraps all of the above lives outside this repo in the
maintainer's notes folder. The commands above are the whole mechanism, so the
script is a convenience rather than a requirement.

## Writing Style

- Match the tone of recent posts: practical, first-person, direct, and focused
  on what was built, why it exists, how it works, and what comes next.
- Prefer concrete implementation details over generic marketing copy.
- Use the existing section rhythm when it fits the topic, for example:
  `Overview`, `The Problem`, `What I Built`, `Implementation Highlights`,
  `Testing Strategy`, and `What's Next`.
- Keep code examples runnable or clearly illustrative.
- Avoid em dashes in new prose. Use commas, colons, parentheses, or separate
  sentences.
- New posts should normally end with the established sign-off:

```markdown
Success! 🎉
```

## Cover Images and Social Images

New technical posts should normally have both a visible SVG cover and a PNG
social image.

1. Create a deterministic SVG cover in `/images/`.
   - Use an 800x400 canvas.
   - Match the existing style: simple full-canvas background, restrained
     gradients, terminal or tool UI motifs, clear title text, and a short
     subtitle.
   - Keep the SVG local, lightweight, and hand-editable.
   - Avoid remote image hosts.

2. Add `cover_image` front matter that points to the SVG:

   ```yaml
   cover_image: /images/example-cover.svg
   ```

3. Generate a 1200x630 PNG social image from the SVG using local
   macOS/Homebrew tools:

   ```bash
   rsvg-convert -h 630 images/example-cover.svg -o /tmp/example-cover-1260x630.png
   magick /tmp/example-cover-1260x630.png -gravity center -crop 1200x630+0+0 +repage images/example-cover.png
   ```

4. Add `image` front matter that points to the generated PNG:

   ```yaml
   image: /images/example-cover.png
   ```

5. Verify the generated HTML includes the expected metadata:
   - canonical URL
   - `meta name="description"`
   - `og:image` using the PNG file
   - `twitter:card` set to `summary_large_image`
   - the PNG image is 1200x630

Both keys are needed, because two different consumers read them:

| Key | Value | Read by | Result |
| --- | --- | --- | --- |
| `cover_image` | the 800x400 SVG | `_layouts/post.html` and `_layouts/page.html` | the visible image at the top of the page |
| `image` | the 1200x630 PNG | the `jekyll-seo-tag` plugin, via `{% seo %}` in `_includes/head.html` | `og:image` and `twitter:image` |

No layout in this repo reads `image`, and the plugin does not read `cover_image`.
Setting only `cover_image` emits no `og:image` at all and quietly downgrades
`twitter:card` from `summary_large_image` to `summary`, so the post loses its
large social preview with nothing in the build output to warn you. There is no
site-wide fallback image in `_config.yml`.

Every post since August 2025 sets both, as do `about/index.md` and
`uses/index.md`. Posts before that set neither and are fine left alone.

The post layout uses the page title as cover image alt text.

`public/css/custom.scss` caps the visible cover at 400px tall on desktop, 250px
below 768px, and 200px below 480px. Keep the SVG under 50KB.

## SEO Metadata

- Every post should have an accurate `title`, `description`, `summary`, and
  useful `tags`.
- Do not make SEO changes that are only keyword stuffing. Prefer accurate
  titles, descriptions, tags, and useful cover/social metadata.
- Use a concise `summary:` so the home page does not leak large code blocks or
  overly long paragraphs.

## Styling

- Custom styles live in `public/css/custom.scss`.
- The site uses SCSS through Jekyll compilation.
- Existing responsive breakpoints include 768px for tablet and 480px for mobile.
- Cover images have responsive sizing and hover effects; preserve that behavior
  unless the user asks for a design change.

## Listing Pages

When creating or editing posts, verify that the article works in all three
public contexts:

- Home page post listing: `index.html` uses `summary:` or `description:` before
  falling back to body text.
- Archive listing: `archive/index.md` shows the post date and truncated title.
- Individual post page: `_layouts/post.html` renders `cover_image`, title, date,
  and full content.

## Local Development

Run the Jekyll server for visual checks:

```bash
bundle exec jekyll serve --host=localhost --livereload
```

A `published: false` post is skipped by that build. Preview one with
`--unpublished`. The `--drafts` flag renders a `_drafts/` folder instead, which
this repo does not have, so it will not show the post:

```bash
bundle exec jekyll serve --unpublished --host=localhost --livereload
```

Add `--future` too if the post is dated later than today.

Then inspect:

- `http://localhost:4000/`
- `http://localhost:4000/archive/`
- the post URL

During local development, images may fail if opened directly with `file://` and
absolute paths such as `/images/example.svg`. Use the Jekyll server for reliable
testing.

Build before finishing:

```bash
bundle exec jekyll build
```

## Visual QA

- Test representative widths when changing post layout or cover-image CSS:
  375px mobile, 768px tablet, and 1200px or wider desktop.
- Confirm cover images scale without cropping important content.
- Confirm posts without cover images still render normally.
- Confirm the home page excerpt remains readable and compact.
- Confirm the archive title is not awkwardly truncated.

Which browser tool to drive is a machine-level choice, not a repo one, so it
lives in the global agent instructions rather than here. Follow whatever order
those set out. This file only says what to look at.

## Site Structure

```text
_posts/           Blog posts, including unpublished ones
_layouts/         Jekyll layouts
_includes/        Jekyll includes
public/css/       SCSS stylesheets
images/           Blog post cover and social images
README.md         Human maintainer workflow
AGENTS.md         AI agent workflow, the single source
CLAUDE.md         Pointer to AGENTS.md
.github/copilot-instructions.md   Pointer to AGENTS.md
```

`AGENTS.md` is the only agent guidance in this repo. `CLAUDE.md` and
`.github/copilot-instructions.md` exist because those tools look for those
paths; both just point here. Add new guidance to this file, not to them.
