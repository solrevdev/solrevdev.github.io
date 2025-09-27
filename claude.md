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
- **Supported formats**: SVG (preferred), PNG, JPG - all handled gracefully by CSS
- **Size handling**: CSS automatically scales images responsively:
  - Desktop: max-height 400px
  - Tablet: max-height 250px
  - Mobile: max-height 200px
- **Recommended dimensions**: 800x400px aspect ratio for optimal display
- **File size**: Keep under 50KB for performance (SVG typically 2-5KB)
- **Alt text**: Automatically uses page title for accessibility
- **Storage**: Place images in `/images/` directory

### Testing Results (Production Ready)
- ✅ Images scale gracefully across all device sizes
- ✅ Posts without cover images display normally
- ✅ Performance impact minimal (2.3KB SVG)
- ✅ All image formats (SVG, PNG, JPG) supported
- ✅ Responsive breakpoints working properly