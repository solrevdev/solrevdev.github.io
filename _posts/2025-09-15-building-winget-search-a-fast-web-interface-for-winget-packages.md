---
published: true
layout: post
title: Building Winget Search - A fast web interface for Windows Package Manager
description: >-
  How I built a GitHub Pages-hosted search interface for winget packages to solve my machine setup workflow
cover_image: /images/winget-search-cover.svg
tags:
  - python
  - javascript
  - winget
  - github-actions
  - github-pages
---

## Background

When setting up a new Windows machine, I used to rely on [Scoop](https://scoop.sh/) and [Chocolatey](https://chocolatey.org/) for package management. Both are excellent tools, but when Microsoft introduced [Windows Package Manager (winget)](https://learn.microsoft.com/en-us/windows/package-manager/), I decided to give it a try on my latest machine setup.

The problem? Finding winget package IDs was tedious. While `winget search` works, I wanted something faster - a web interface where I could quickly search, find packages, and copy installation commands. That's how [winget-search](https://github.com/solrevdev/winget-search) was born.

## The Challenge

Winget packages are stored in Microsoft's [winget-pkgs repository](https://github.com/microsoft/winget-pkgs) with over 30,000 YAML manifest files. The repository structure follows a pattern: `manifests/publisher/package_name/version/` with separate files for different locales and installers.

I needed to:
- Extract package metadata from thousands of YAML files
- Handle multiple versions and keep only the latest
- Filter for English descriptions only
- Build a fast, searchable web interface
- Keep data fresh with automated updates

## The Solution

### Architecture Overview

I built a three-part system:

1. **Python extraction script** - Parses YAML manifests and generates JSON
2. **Static HTML search interface** - Client-side search with instant results
3. **GitHub Actions automation** - Daily updates and deployment

### Data Extraction

The Python script (`extract_packages.py`) does the heavy lifting:

```python
def extract_package_info(manifest_dir):
    """Extract comprehensive package info from a manifest directory"""
    package_info = {
        "id": None,
        "name": None,
        "description": None,
        "publisher": None,
        "version": None,
        "tags": [],
        "homepage": None,
        "license": None
    }

    # Process version manifest first
    version_file = next((f for f in yaml_files if not '.locale.' in f), None)
    if version_file:
        with open(os.path.join(manifest_dir, version_file), encoding="utf-8") as f:
            doc = yaml.safe_load(f)
            package_info["id"] = doc.get("PackageIdentifier")
            package_info["version"] = doc.get("PackageVersion")

    # Look for English locale file
    locale_file = next((f for f in yaml_files if '.locale.en-US.' in f), None)
    if locale_file:
        with open(os.path.join(manifest_dir, locale_file), encoding="utf-8") as f:
            doc = yaml.safe_load(f)
            package_info["name"] = doc.get("PackageName")
            package_info["publisher"] = doc.get("Publisher")
            package_info["description"] = doc.get("Description")
```

The script handles version comparison using Python's `packaging` library to ensure we only keep the latest version of each package:

```python
def parse_version(ver_str):
    """Parse version string for proper comparison"""
    try:
        return version.parse(ver_str)
    except:
        return version.parse("0.0.0")  # Fallback for non-standard versions
```

### Web Interface

The search interface is pure vanilla JavaScript - no frameworks needed. It loads a ~5MB JSON file containing all package data and performs client-side search for instant results:

```javascript
function showResults(query) {
    const q = query.trim().toLowerCase();

    let results;
    if (!q) {
        results = packages.slice(0, 50);
    } else {
        results = packages.filter(pkg => {
            const idMatch = pkg.id?.toLowerCase().includes(q);
            const nameMatch = pkg.name?.toLowerCase().includes(q);
            const descMatch = pkg.description?.toLowerCase().includes(q);
            const publisherMatch = pkg.publisher?.toLowerCase().includes(q);
            const tagMatch = pkg.tags?.some(tag =>
                tag && typeof tag === 'string' && tag.toLowerCase().includes(q)
            );

            return idMatch || nameMatch || descMatch || publisherMatch || tagMatch;
        }).slice(0, 100);
    }

    // Render results...
}
```

Each search result includes a one-click copy button for the winget install command:

```javascript
function copyCommand(button, cmd) {
    navigator.clipboard.writeText(cmd).then(() => {
        const originalHtml = button.innerHTML;
        button.classList.add('success');
        button.innerHTML = `
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polyline points="20 6 9 17 4 12"/>
            </svg>
            Copied!
        `;

        setTimeout(() => {
            button.classList.remove('success');
            button.innerHTML = originalHtml;
        }, 2000);
    });
}
```

### Automation with GitHub Actions

The magic happens in the GitHub Actions workflow that runs daily at 2 AM UTC:

```yaml
name: Build and Deploy
on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM UTC
  workflow_dispatch:

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Cache winget-pkgs
        uses: actions/cache@v4
        with:
          path: winget-pkgs
          key: winget-pkgs-${{ github.run_id }}
          restore-keys: winget-pkgs-

      - name: Clone winget-pkgs repository
        run: |
          if [ ! -d "winget-pkgs" ]; then
            git clone --depth 1 https://github.com/microsoft/winget-pkgs.git
          else
            cd winget-pkgs && git pull origin main
          fi

      - name: Extract packages
        run: python extract_packages.py winget-pkgs/manifests/ packages.json

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: .
```

## Technical Highlights

### Performance Optimizations

- **Client-side search**: No server required, instant results
- **Debounced input**: 300ms delay prevents excessive filtering
- **Result limiting**: Shows max 100 results for smooth scrolling
- **Caching**: GitHub Actions caches the large winget-pkgs repository

### User Experience Features

- **Keyboard shortcuts**: Press `/` to focus search, `Esc` to clear
- **Dark mode**: Automatic theme based on system preferences
- **Mobile-friendly**: Responsive design works on all devices
- **Copy feedback**: Visual confirmation when commands are copied

### Data Quality

- **English-only**: Filters for `.locale.en-US.yaml` files
- **Latest versions**: Semantic version comparison ensures freshness
- **Type safety**: Handles edge cases like non-string tags
- **Error resilience**: Continues processing even if individual manifests fail

## Deployment

The entire deployment is automated through GitHub Pages. The workflow:

1. Clones the microsoft/winget-pkgs repository (1GB+, hence the caching)
2. Extracts package data using Python script
3. Generates a `packages.json` file with ~30,000 packages
4. Deploys everything to GitHub Pages using `peaceiris/actions-gh-pages`

No manual intervention needed - just push code and GitHub Actions handles the rest!

## Results

The end result is a fast, searchable interface hosted at GitHub Pages that:

- Loads 30,000+ packages in under 3 seconds
- Provides instant search results
- Generates copy-ready `winget install` commands
- Updates automatically every day
- Costs nothing to host

Perfect for when you need to quickly find that package ID for your setup scripts!

## Future Improvements

Some ideas I'm considering:

- **Package categories** - Group by software type
- **Fuzzy search** - Better matching for typos
- **PowerShell commands** - Alternative to cmd syntax
- **Package details modal** - Show more metadata
- **Search history** - Remember recent searches

## Live Demo

Check out the live site: [https://solrevdev.github.io/winget-search/](https://solrevdev.github.io/winget-search/)

The source code is available on [GitHub](https://github.com/solrevdev/winget-search) under the MIT license.

Success 🎉