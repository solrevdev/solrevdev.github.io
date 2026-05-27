---
layout: page
title: Archive
description: Browse the solrevdev tech radar archive of posts about C#, ASP.NET Core, .NET, developer tools, AI-assisted development, web development, and DevOps.
---

## Blog Posts

{% for post in site.posts %}
  * {{ post.date | date_to_string }} &raquo; [ {{ post.title | strip_html | remove: '|' | truncatewords:10}} ]({{ post.url }})
{% endfor %}
