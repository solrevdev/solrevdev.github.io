---
published: true
layout: post
title: Remove page or site from Google search results
description: How to remove a page or site from Google search results
tags:
  - google
  - SEO
  - www
---

**Background**

What do you do when you have a website that you do not want Google or other search engines to index and therefore NOT display in search results?

**Robots!** 🤖

In the past, you have simply been able to add a [robots.txt](https://www.robotstxt.org/robotstxt.html) file.

This is a file that website owners could use to inform web crawlers and robots such as the [Googlebot](https://support.google.com/webmasters/answer/182072?hl=en) about whether you wanted your site indexed or not and if so which parts of your site.

If you wanted to stop all robots from indexing your site you created a file called `robots.txt` in your site root with the following content

```text
User-agent: *
Disallow: /
```

While still used, it is no longer the recommended way to block or remove a URL or site from Google.

**Google's Removal Tool** ✂

Your first step should be to head over to the [Google Search Removal Tool](https://search.google.com/search-console/removals?resource_id=sc-domain%3Awww.yourdomain.com) and enter your page or site into the tool and submit.

For more information you can [read about it here](https://support.google.com/webmasters/answer/9689846?hl=en).

Doing this will remove your page or site for up to 6 months.

![](https://i.imgur.com/LsyvpRu.png)

**Meta Tags** 📓

To permanently remove it you will need to tell Google not to index your page using the [robots meta tag](https://developers.google.com/search/reference/robots_meta_tag).

You add this into any page that you do not want Google to index.
```html
<meta name="robots" content="noindex">
```

For example:

```html
<!DOCTYPE html>
<html>
<head>
    <meta name="robots" content="noindex" />
    <title>Robots</title>
</head>
<body>
You do not want Google to index this page
</body>
</html>
```

**Inspect** 🔎

Once you have removed your page or site using the removal tool and used meta tags to stop it being indexed again in the future you will want to keep an eye on your domain and inspect the page(s) or site you removed.

To view your pending removals login to the [Google Search Console](https://search.google.com/search-console/about) and choose the Removals tab.

From here you can submit new pages for removal and generally inspect your website and how it is managed by Google's index.

![](https://i.imgur.com/lm5LXBD.png)

**Summary**

To recap, when you want to remove a page or site from Google search index you need to...

- Use the [Google Search Removal Tool](https://search.google.com/search-console/removals?resource_id=sc-domain%3Awww.yourdomain.com) to remove temporarily.
- Permanently remove using [robots meta tag](https://developers.google.com/search/reference/robots_meta_tag)

Hope this helps others or me from the future!

Success 🎉
