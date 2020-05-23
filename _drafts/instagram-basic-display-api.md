---
published: true
layout: post
title: Instagram Basic Display API
tags:
  - aspnetcore
  - dotnet
  - instagram
  - api
  - nuget
---

**Background**

A while ago I was working on a project that consumed the [Instagram Legacy API Platform](https://www.instagram.com/developer/). 

![](https://i.imgur.com/PHCXZXK.png)

To make things easier there was fantastic libray called [InstaSharp](http://instasharp.github.io/InstaSharp/) which wrapped the HTTP calls to the Instagram API endpoints.

![](https://i.imgur.com/YgLkx4K.png)

However, Instagram began disabling the [Instagram Legacy API Platform](https://www.instagram.com/developer/) and on June 29, 2020 any remaining endpoints will no longer be available.

The replacements to the [Instagram Legacy API Platform](https://www.instagram.com/developer/) are the [Instagram Graph API](https://developers.facebook.com/docs/instagram-graph-api) and the [Instagram Basic Display API](https://developers.facebook.com/docs/instagram-basic-display-api).

So, If my project was to continue to work I needed to migrate over to the [Instagram Basic Display API](https://developers.facebook.com/docs/instagram-basic-display-api) before the deadline. 

I decided to build and release an open source library, A  wrapper around the [Instagram Basic Display API](https://developers.facebook.com/docs/instagram-basic-display-api) in the same was as [InstaSharp](http://instasharp.github.io/InstaSharp/) did for the original.

**Solrevdev.InstagramBasicDisplay** 

And so began [Solrevdev.InstagramBasicDisplay](https://github.com/solrevdev/instagram-basic-display),  a [netstandard2.0](https://docs.microsoft.com/en-us/dotnet/standard/net-standard) library that consumes the new [Instagram Basic Display API](https://developers.facebook.com/docs/instagram-basic-display-api/).

![](https://i.imgur.com/Te7DLdK.png)

It is also available on [nuget](https://www.nuget.org/packages/Solrevdev.InstagramBasicDisplay/) so you can add this functionality to your own .NET projects.

![](https://i.imgur.com/FWeRqgo.png)

**Getting Started**

todo:// 

Success 🎉
