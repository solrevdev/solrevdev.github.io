---
published: true
layout: post
title: 'Fetch won't send or receive any cookies 🍪'
author: John Smith
tags:
  - '#dotnetcore'
  - '#aspnetcore'
  - '#session'
  - '#cookies'
  - '#fetch'
  - '#worksonmymachine'
---

Today I think I have fixed a bug that has niggled away at me for ages. 🍪

A severe case of  ['works on my machine'](https://blog.codinghorror.com/the-works-on-my-machine-certification-program/)

I have some code that consumes an external API that once authenticated would then, later on, make another API call to fetch the end users recent images.

This worked great...

Except for some users who reported they once logged on would not see their images.

However, for the longest time, I could not recreate this. It worked on my machine, It worked on macOS, Windows and Linux, It worked on safari, chrome and firefox. It worked on an iPhone 6s.

So, I added [logging](https://github.com/serilog/serilog-aspnetcore), then more logging. I even signed up for a trial [Browserstack](https://www.browserstack.com/) account to try as many different browsers and devices I could and still could not recreate the issue.

Then eventually while testing something else out I managed to recreate the bug using Apple's iOS simulator using an iPhone 6S running iOS 11.2.

Being able to recreate the bug really is half the battle when it comes to bug fixing code.

So, armed with some breakpoints and a clearer idea of what was going on, I was eventually able to get the bug fixed and a working app pushed out to production.

The bug?

Well, I am not 100% sure how to explain it but the front end has some JavaScript code that uses the [fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API) to call an [ApiController](https://docs.microsoft.com/en-us/aspnet/core/web-api/?view=aspnetcore-2.2) that checks for a session variable and based on that value returns data back to the front end client.

For most browsers and my development environment, the following code was enough to make that call and get the correct data back:

```javascript
fetch(this.apiUrl)
```
But, then for some browsers, I needed to modify the fetch API call to specify that cookies and credentials must be sent along with the request also.

This is the code that does this and is what I committed as the fix.

```javascript
fetch(this.apiUrl, {
        method: 'GET',
        credentials: 'include'
      })
```

The documentation for fetch does point to the issue somewhat


> By default, **fetch won't send or receive any cookies** from the server, resulting in unauthenticated requests if the site relies on maintaining a user session (to send cookies, the credentials init option must be set).

> Since Aug 25, 2017. The spec changed the default credentials policy to same-origin. Firefox changed since 61.0b13.

> -- [Using Fetch](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch)

Why this was only needed for certain browsers I am unsure but my fix seems to work.


Success 🎉
