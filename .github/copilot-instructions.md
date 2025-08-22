# Jekyll Blog Site - solrevdev.github.io

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

Bootstrap, build, and test the repository:
- `sudo gem install bundler` -- Install bundler if not available (takes 2 seconds)
- `bundle config set path 'vendor/bundle'` -- Configure local bundle path
- `bundle install --path vendor/bundle` -- takes 30 seconds. NEVER CANCEL. Set timeout to 60+ minutes.
- `bundle update github-pages` -- takes 2 seconds. Update GitHub Pages gem
- `bundle exec jekyll build` -- takes 3 seconds. NEVER CANCEL. Set timeout to 10+ minutes.
- `bundle exec htmlproofer ./_site --disable-external --checks Scripts` -- takes 1 second. Validates site build
- `chmod +x ./script/cibuild` -- Make CI build script executable
- `./script/cibuild` -- Run CI build (but HTML proofer syntax is outdated, use command above instead)

## Development Server

Run the development server:
- ALWAYS run the bootstrapping steps first
- `bundle exec jekyll serve --host=localhost` -- Default development server on http://localhost:4000
- `bundle exec jekyll serve --host=localhost --livereload` -- Development server with live reload
- `bundle exec jekyll serve --drafts` -- Include draft posts
- `bundle exec jekyll serve --baseurl ''` -- For testing without base URL

## Validation

- Always manually test the site by accessing http://localhost:4000 after starting the server
- ALWAYS run `curl -s http://localhost:4000/ | head -20` to verify the site is loading correctly
- Test content by checking for "solrevdev" and "John Smith" in the homepage: `curl -s http://localhost:4000/ | grep -i "solrevdev\|John Smith"`
- Build times: Bundle install ~30 seconds, Jekyll build ~3 seconds, HTML proofer ~1 second
- The site should load with the title "solrevdev tech radar" and author "John Smith"
- Always run HTML proofer validation before making changes: `bundle exec htmlproofer ./_site --disable-external --checks Scripts`

## Common Tasks

### Building and Testing
- `bundle exec jekyll build --verbose` -- Verbose build for debugging
- `rm -rf _site && bundle exec jekyll build` -- Clean build
- `bundle exec jekyll build --incremental` -- Incremental build for faster development

### Available Rake Tasks
- `bundle exec rake -T` -- List all available rake tasks
- `bundle exec rake post:create` -- Create a new blog post
- `bundle exec rake page:create` -- Create a new page  
- `bundle exec rake site:serve` -- Alternative way to serve the site
- `bundle exec rake site:watch` -- Serve with auto-regeneration
- **NOTE**: `rake site:build` and `rake site:deploy` are broken due to missing config, use Jekyll commands instead

### Repository Structure
- `_posts/` -- Blog posts (92 content files total, 4302 lines in markdown files)
- `_config.yml` -- Jekyll configuration
- `Gemfile` -- Ruby dependencies
- `Rakefile` -- Build automation tasks (some broken)
- `script/cibuild` -- CI build script (uses outdated HTML proofer syntax)
- `public/` -- Static assets (CSS, images)
- `_includes/` -- Reusable template components  
- `_layouts/` -- Page templates
- `vendor/bundle/` -- Local gem installation directory

### Key Technologies
- **Framework**: Jekyll 3.10.0 static site generator
- **Theme**: Hyde theme based on Poole, with Jekyll Theme Cayman
- **Ruby Version**: 3.2.3 (works with latest Ruby)
- **Bundler**: 2.7.1
- **GitHub Pages**: Version 232 compatible
- **Dependencies**: 119 gems including jekyll-feed, jekyll-sitemap, jekyll-seo-tag, html-proofer

### CI/CD Information
- **Travis CI**: Configured in `.travis.yml` (Ruby 2.5.8, may be outdated)
- **CircleCI**: Basic configuration in `.circleci/config.yml`
- **HTML Proofer**: Version 5.0.10 (syntax different from legacy version in script/cibuild)

### Important File Locations
- Main configuration: `_config.yml`
- Theme overrides: `public/css/hyde.css`, `public/css/custom.css`
- Blog posts: `_posts/` (naming format: YYYY-MM-DD-title.md)
- About page: `about/index.md`
- Archive page: `archive/index.md`
- Uses page: `uses/index.md`

### Troubleshooting
- If "bundle: command not found": Run `sudo gem install bundler`
- If permission errors during bundle install: Use `--path vendor/bundle` flag
- If HTML proofer fails: Use new syntax `--checks Scripts` instead of `--checks-to-ignore`
- If images don't load in development: Use `--host=localhost` instead of default 127.0.0.1
- If rake tasks fail: Use direct Jekyll commands instead

### Content Management
- Posts use YAML front matter with layout, title, author, tags, published status
- Site supports canonical URLs via `canonical_url` front matter
- SEO managed via jekyll-seo-tag plugin
- Sitemap auto-generated via jekyll-sitemap plugin
- RSS feed auto-generated via jekyll-feed plugin

### Performance Notes
- Site builds very quickly (~3 seconds for full build)
- Development server starts in ~2 seconds
- HTML validation completes in ~1 second
- Bundle operations are the slowest part (30 seconds for fresh install)

NEVER CANCEL any build or bundle commands. Bundle install may take up to 30 seconds. Always wait for completion.