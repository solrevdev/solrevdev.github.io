# Claude Development Notes

## Blog Cover Images

### Implementation
- Added `cover_image` front matter field to blog posts
- Updated `_layouts/post.html` to display cover images when present
- Added responsive CSS styles in `public/css/custom.scss` for proper display across devices

### Image URL Behavior During Local Development

**Key Finding**: When developing locally, images sometimes do not display properly due to path resolution issues.

**Working Solutions**:
1. **Relative paths** (`./images/filename.svg`) - ✅ Works with file:// protocol
2. **File protocol** (`file:///full/path/to/image`) - ✅ Works for local testing
3. **Jekyll server** with localhost/127.0.0.1 - ✅ Works when Jekyll server is running

**Non-working Solutions**:
1. **Absolute paths** (`/images/filename.svg`) - ❌ Fails with file:// protocol
2. **localhost URLs** without server - ❌ Connection refused when Jekyll isn't running
3. **127.0.0.1 URLs** without server - ❌ Connection refused when Jekyll isn't running

### Development Workflow
For local development, either:
1. Use Jekyll server: `bundle exec jekyll serve --host 127.0.0.1 --port 4000`
2. Use relative paths in Jekyll templates with `{{ site.baseurl }}` prefix
3. Test with file:// protocol using relative paths for quick validation

### CSS Implementation
- Responsive design with different max-heights for desktop (400px), tablet (250px), and mobile (200px)
- Hover effects with subtle scale transform
- Proper shadow and border-radius for visual appeal
- Mobile-specific margin adjustments for better display

### Cover Image Guidelines
- Use SVG format for scalable graphics where possible
- Recommended dimensions: 800x400px for optimal display
- Include descriptive alt text for accessibility
- Store images in `/images/` directory