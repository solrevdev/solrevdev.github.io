# GitHub Copilot Instructions

## Project Overview
This is a Jekyll-based static blog for solrevdev.com using the Hyde theme with custom modifications.

## Key Development Guidelines

### Blog Posts
- Located in `_posts/` directory
- Use Jekyll front matter with these fields:
  - `layout: post`
  - `title: [Post Title]`
  - `description: [SEO description]`
  - `summary: [Brief summary]`
  - `cover_image: [/images/filename.ext]` (optional)
  - `tags: [array of tags]`

### Cover Images
- Store in `/images/` directory
- Use `cover_image: /images/filename.ext` in front matter
- Supported formats: SVG (preferred), PNG, JPG
- Recommended dimensions: 800x400px
- Automatically responsive across desktop, tablet, and mobile

### Local Development Image Issues
**Important**: During local development, images may not display properly due to URL resolution:

**Solutions**:
1. **Use Jekyll server**: `bundle exec jekyll serve --host 127.0.0.1 --port 4000`
2. **Use localhost domain**: `http://localhost:4000` or `http://127.0.0.1:4000`
3. **Relative paths work**: with file:// protocol for testing

**Don't use**:
- Absolute paths (`/images/...`) with file:// protocol - will fail
- localhost URLs without running Jekyll server

### Styling
- Custom styles in `public/css/custom.scss`
- Uses SCSS with Jekyll compilation
- Responsive breakpoints: 768px (tablet), 480px (mobile)
- Cover images have hover effects and responsive sizing

### File Structure
```
├── _posts/           # Blog posts
├── _layouts/         # Jekyll layouts
├── _includes/        # Jekyll includes
├── public/css/       # SCSS stylesheets
├── images/           # Blog post images
├── claude.md         # Claude development notes
└── .github/          # GitHub configuration
```

### Testing
- Use `test-cover-image.html` for image URL testing
- Test responsive design at 375px (mobile), 768px (tablet), 1200px+ (desktop)
- Screenshots saved in `.playwright-mcp/` directory