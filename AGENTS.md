# Repository Instructions

## Blog Post Cover Images and SEO Metadata

When creating or updating a blog post, use the same cover-image pattern as recent posts:

1. Create a deterministic SVG cover in `/images/`.
   - Use an 800x400 canvas.
   - Match the existing style: simple full-canvas background, restrained gradients, terminal or tool UI motifs, clear title text, and a short subtitle.
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

5. Make sure each post has useful SEO front matter:

   ```yaml
   title: Clear post title with the main topic
   description: One concise search-friendly sentence describing the post.
   summary: Optional longer summary for homepage excerpts.
   tags:
   - dotnet
   - csharp
   ```

6. Verify the generated HTML includes the expected metadata:
   - canonical URL
   - `meta name="description"`
   - `og:image` using the PNG file
   - `twitter:card` set to `summary_large_image`
   - the PNG image is 1200x630

7. Build before finishing:

   ```bash
   bundle exec jekyll build
   ```

## Writing Style

- Avoid em dashes in new prose. Use commas, colons, parentheses, or separate sentences.
- Keep technical writing practical and direct.
- Do not make SEO changes that are only keyword stuffing. Prefer accurate titles, descriptions, tags, and useful cover/social metadata.
