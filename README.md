# solrevdev.github.io

[![GitHub last commit](https://img.shields.io/github/last-commit/solrevdev/solrevdev.github.io)](https://github.com/solrevdev/solrevdev.github.io) [![Build Status](https://travis-ci.org/solrevdev/solrevdev.github.io.svg?branch=master)](https://travis-ci.org/solrevdev/solrevdev.github.io) [![CircleCI](https://circleci.com/gh/solrevdev/solrevdev.github.io.svg?style=svg)](https://circleci.com/gh/solrevdev/solrevdev.github.io) [![Twitter Follow](https://img.shields.io/twitter/follow/solrevdev?label=Follow&style=social)](https://twitter.com/solrevdev)


Static [Jekyll](http://jekyllrb.com) driven website to replace solrevdev.com blogger account

## Testing the site locally


```powershell
bundle install
bundle update github-pages
bundle exec jekyll serve --baseurl ''
bundle exec jekyll serve --drafts --baseurl ''
bundle exec jekyll serve --drafts --baseurl '' 2>/dev/null

bundle exec jekyll serve --drafts 2>/dev/null
```

To get rid of warnings you can use this

```powershell
bundle exec jekyll serve --drafts --baseurl '' 2>/dev/null

bundle exec jekyll serve --drafts 2>/dev/null
```

Now open your browser and go to : `http://localhost:4000` <http://localhost:4000>


```powershell
gem install github-pages
gem update github-pages
jekyll build
jekyll serve
```
Now open your browser and go to <http://localhost:4000>

## Testing on Apple Silicon

I had to add `gem 'webrick'` to the GemFile plus had to update nokogiri  `gem update nokogiri` and had to remove the Gemfile.lock file
to get it working but then all seems well for testing again.

```bash
bundle install
bundle update github-pages

bundle exec jekyll build

# this is what I tested with
bundle exec jekyll serve

# these are from before and do not know if they work but am leaving them here for now
bundle exec jekyll serve --drafts --baseurl '' 2>/dev/null
bundle exec jekyll serve --drafts 2>/dev/null
```

Now open your browser and go to : `http://localhost:4000` <http://localhost:4000>

## SEO Improvements

To enhance SEO and address Google Search Console issues, we've implemented the ability to control the canonical URL and robots meta tags on a per-post basis using Jekyll front matter.

### Canonical URL

A canonical URL is specified to prevent duplicate content issues and to consolidate page ranking for similar content. In the `_includes/head.html` file, we've added the following snippet to insert a canonical link element when the `canonical_url` variable is set in a post's front matter:

```html
{% if page.canonical_url %}
<link rel="canonical" href="{{ page.canonical_url }}" />
{% endif %}
```

This allows individual posts to define their canonical URL in the front matter like so:

```yaml
---
canonical_url: 'https://solrevdev.com/2011/10/10/amazoncom-really-want-me-don-they.html'
---
```

### Robots Tag

To further direct search engine indexing behavior, the `robots` meta tag can be included. This is useful for specifying pages that should not be indexed or followed by search engine crawlers. The following snippet in `_includes/head.html` checks for a `robots` variable:

```html
{% if page.robots %}
<meta name="robots" content="{{ page.robots }}">
{% endif %}
```

In a post's front matter, you can control the robots tag like this:

```yaml
---
robots: "noindex, follow"
---
```

### Updating Old Content

For outdated content that no longer provides SEO value, we've introduced a standard update notice. This notice directs users to more relevant sections of the site and is included at the top of such posts:

```html
<h1>Update</h1>
<p>This page's content is no longer relevant. However, we have plenty of updated information on related topics:</p>
<ul>
    <li><a href="/">Home</a></li>
    <li><a href="/about">About</a></li>
    <li><a href="/archive/">Archive</a></li>
    <li><a href="/uses/">Uses</a></li>
    <li><a href="https://github.com/solrevdev/solrevdev.github.io">GitHub project</a></li>
</ul>
```

These changes aim to improve the overall SEO of the site and resolve specific issues flagged by Google Search Console.



## Hyde theme


It is a brazen two-column  theme that pairs a prominent sidebar with uncomplicated content. It's based on [Poole](http://getpoole.com), the Jekyll butler.

![Hyde screenshot](https://f.cloud.github.com/assets/98681/1831228/42af6c6a-7384-11e3-98fb-e0b923ee0468.png)


## Contents

- [solrevdev.github.io](#solrevdevgithubio)
  - [Testing the site locally](#testing-the-site-locally)
  - [Testing on Apple Silicon](#testing-on-apple-silicon)
  - [SEO Improvements](#seo-improvements)
    - [Canonical URL](#canonical-url)
    - [Robots Tag](#robots-tag)
    - [Updating Old Content](#updating-old-content)
  - [Hyde theme](#hyde-theme)
  - [Contents](#contents)
  - [Usage](#usage)
  - [Options](#options)
    - [Sidebar menu](#sidebar-menu)
    - [Sticky sidebar content](#sticky-sidebar-content)
    - [Themes](#themes)
    - [Reverse layout](#reverse-layout)
  - [Development](#development)
  - [Jekyll commands used to get setup](#jekyll-commands-used-to-get-setup)
  - [Travis and Github custom domain resources](#travis-and-github-custom-domain-resources)
  - [Prose](#prose)
  - [Author](#author)
  - [License](#license)


## Usage

Hyde is a theme built on top of [Poole](https://github.com/poole/poole), which provides a fully furnished Jekyll setup—just download and start the Jekyll server. See [the Poole usage guidelines](https://github.com/poole/poole#usage) for how to install and use Jekyll.


## Options

Hyde includes some customizable options, typically applied via classes on the `<body>` element.


### Sidebar menu

Create a list of nav links in the sidebar by assigning each Jekyll page the correct layout in the page's [front-matter](http://jekyllrb.com/docs/frontmatter/).

```
---
layout: page
title: About
---
```

**Why require a specific layout?** Jekyll will return *all* pages, including the `atom.xml`, and with an alphabetical sort order. To ensure the first link is *Home*, we exclude the `index.html` page from this list by specifying the `page` layout.


### Sticky sidebar content

By default Hyde ships with a sidebar that affixes it's content to the bottom of the sidebar. You can optionally disable this by removing the `.sidebar-sticky` class from the sidebar's `.container`. Sidebar content will then normally flow from top to bottom.

```html
<!-- Default sidebar -->
<div class="sidebar">
  <div class="container sidebar-sticky">
    ...
  </div>
</div>

<!-- Modified sidebar -->
<div class="sidebar">
  <div class="container">
    ...
  </div>
</div>
```


### Themes

Hyde ships with eight optional themes based on the [base16 color scheme](https://github.com/chriskempson/base16). Apply a theme to change the color scheme (mostly applies to sidebar and links).

![Hyde in red](https://f.cloud.github.com/assets/98681/1831229/42b0b354-7384-11e3-8462-31b8df193fe5.png)

There are eight themes available at this time.

![Hyde theme classes](https://f.cloud.github.com/assets/98681/1817044/e5b0ec06-6f68-11e3-83d7-acd1942797a1.png)

To use a theme, add anyone of the available theme classes to the `<body>` element in the `default.html` layout, like so:

```html
<body class="theme-base-08">
  ...
</body>
```

To create your own theme, look to the Themes section of [included CSS file](https://github.com/poole/hyde/blob/master/public/css/hyde.css). Copy any existing theme (they're only a few lines of CSS), rename it, and change the provided colors.

### Reverse layout

![Hyde with reverse layout](https://f.cloud.github.com/assets/98681/1831230/42b0d3ac-7384-11e3-8d54-2065afd03f9e.png)

Hyde's page orientation can be reversed with a single class.

```html
<body class="layout-reverse">
  ...
</body>
```


## Development

Hyde has two branches, but only one is used for active development.

- `master` for development.  **All pull requests should be submitted against `master`.**
- `gh-pages` for our hosted site, which includes our analytics tracking code. **Please avoid using this branch.**

## Jekyll commands used to get setup

```powershell
sudo chown -R $(whoami) /usr/local

sudo chown -R $(whoami) /Library/Ruby

brew install ruby

gem install bundler

gem install rouge

gem update --system

sudo gem cleanup

bundle install

bundle exec jekyll serve

bundle exec jekyll serve --baseurl ''

bundle exec jekyll serve --drafts


gem install jekyll-import

ruby -rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Blogger.run({
      "source"                => "_blogger.xml",
      "no-blogger-info"       => false, # not to leave blogger-URL info (id and old URL) in the front matter
      "replace-internal-link" => false, # replace internal links using the post_url liquid tag.
    })'


bundle exec htmlproofer ./_site

bundle exec htmlproofer ./_site --check-html --disable-external --checks-to-ignore ImageCheck,LinkCheck, HtmlCheck

bundle exec htmlproofer ./_site --disable-external --checks-to-ignore ImageCheck,LinkCheck,HtmlCheck

htmlproofer ./_site


```

## Travis and Github custom domain resources

* http://sgoettschkes.me/p/deploying-a-jekyll-website-to-github-pages-using-travisci.html
* http://intenseagile.com/2015/04/27/running-jekyll-on-codeanywhere.html
* http://www.steveklabnik.com/automatically_update_github_pages_with_travis_example/
* http://awestruct.org/auto-deploy-to-github-pages/
* https://github.com/mbonaci/mbo-storm/wiki/Integrate-Travis-CI-with-your-GitHub-repo
* https://travis-ci.org/profile/solrevdev
* https://docs.travis-ci.com/user/for-beginners
* https://docs.travis-ci.com/user/getting-started/
* https://help.github.com/articles/troubleshooting-custom-domains/#dns-configuration-errors
* https://help.github.com/articles/setting-up-a-www-subdomain/
* https://tinypress.co/settings
* https://github.com/blog/2100-github-pages-now-faster-and-simpler-with-jekyll-3-0
* https://github.com/solrevdev/solrevdev.github.io
* https://dnsimple.com/dashboard
* https://help.github.com/articles/troubleshooting-jekyll-builds/
* https://gist.github.com/razor-x/8166421
* https://github.com/mfenner/jekyll-travis

## Prose

I am using the following [Prose](http://prose.io/) config

```yaml
prose:
  siteurl: 'https://solrevdev.com'
  media: 'media'
```


## Author

**Mark Otto**
- <https://github.com/mdo>
- <https://twitter.com/mdo>

**John Smith**
- <https://github.com/solrevdev>
- <https://twitter.com/solrevdev>


## License

Open sourced under the [MIT license](LICENSE.md).

<3
