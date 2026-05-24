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
tags:
- dotnet
- csharp
---
```

Keep `published: false` while drafting unless the user explicitly asks to
publish the article.

## Drafting Workflow

- Before finalizing a draft, ask the user what publication date they want.
- If the post is not ready to publish, keep it in `_posts/` with
  `published: false` or use `_drafts/` if the user asks for a true Jekyll draft.
- When publishing, rename the file to `_posts/YYYY-MM-DD-slug.md` and make sure
  any `date:` front matter, if present, matches that filename date.
- Do not silently publish an article by removing `published: false`.
- If the user asks for a PR, keep the PR focused on the article and its related
  assets unless they explicitly ask for wider site changes.

## Writing Style

- Match the tone of recent posts: practical, first-person, direct, and focused
  on what was built, why it exists, how it works, and what comes next.
- Prefer concrete implementation details over generic marketing copy.
- Use the existing section rhythm when it fits the topic, for example:
  `Overview`, `The Problem`, `What I Built`, `Implementation Highlights`,
  `Testing Strategy`, and `What's Next`.
- Keep code examples runnable or clearly illustrative.
- New posts should normally end with the established sign-off:

```markdown
Success! 🎉
```

## Cover Images

- New technical posts should normally have a cover image.
- Use AI image generation when a suitable existing asset is not already present.
- Match the visual style of recent generated blog covers in `images/`, including
  the topic-specific illustration, simple composition, and readable 800x400
  treatment.
- Store cover images in `images/`.
- Use `cover_image: /images/filename.ext` in front matter.
- SVG is preferred when the cover is simple and generated as code; PNG or JPG is
  fine for raster artwork.
- Recommended dimensions are 800x400.
- Keep file size modest; under 50 KB is preferred when practical.
- The post layout uses the page title as cover image alt text.

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

Use a concise `summary:` so the home page does not leak large code blocks or
overly long paragraphs.

## Local Development

Prefer running the Jekyll server for visual checks:

```bash
bundle exec jekyll serve --host=localhost --livereload
```

For drafts:

```bash
bundle exec jekyll serve --drafts --host=localhost --livereload
```

Then inspect:

- `http://localhost:4000/`
- `http://localhost:4000/archive/`
- the post URL

During local development, images may fail if opened directly with `file://` and
absolute paths such as `/images/example.svg`. Use the Jekyll server for reliable
testing.

## Visual QA

- Test representative widths when changing post layout or cover-image CSS:
  375px mobile, 768px tablet, and 1200px or wider desktop.
- Confirm cover images scale without cropping important content.
- Confirm posts without cover images still render normally.
- Confirm the home page excerpt remains readable and compact.
- Confirm the archive title is not awkwardly truncated.

## Site Structure

```text
_posts/           Blog posts
_drafts/          Optional unpublished drafts
_layouts/         Jekyll layouts
_includes/        Jekyll includes
public/css/       SCSS stylesheets
images/           Blog post images
README.md         Human maintainer workflow
AGENTS.md         AI agent workflow
```
