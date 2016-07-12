---
layout: post
title: "Xamarin Studio and ServiceStack.Text IsMono update"
author: "John Smith"
tags:
- "#xamarin"
- "#servicestack"
- "#mono"
---

In my [last post]({% post_url 2016-07-12-xamarin-servicestack-mono-platform-helper %}) I [tweeted](https://twitter.com/solrevdev/status/752628079776919552) out a link about me using a custom `IsRunninOnMono()` method and enjoying using the Service Stack library with Xamarin on a Mac to develop on. 


Well, happily I got a great reply from [@demisbellot](http://mythz.servicestack.net) from Service Stack who pointed out the`ServiceStack.Text` library has an alternative to my my solution baked in. 

> [@solrevdev](https://twitter.com/) FYI you can also
> use 

> `if (Env.IsMono) {}` 

> which already provides this

Thanks for the [reply](https://twitter.com/demisbellot/status/752630173497864193) [@demisbellot](http://mythz.servicestack.net)!

I shall use that later today as it is a much better solution and the base `Env.*` class has loads of useful methods that I have missed. 

For reference here is the [source code](https://github.com/ServiceStack/ServiceStack.Text/blob/master/src/ServiceStack.Text/Env.cs#L20) used.

![alt text](http://static.solrevdev.com.s3.amazonaws.com/blog/service-stack-dot-text-is-mono_1.png "ServiceStack-Text IsMono Image")

---

Again, this blog post has been written on my mobile phone using the following tools in addition to my **Jekyll** driven, **Git** stored and **GitHub** static hosted website. 

- This post was been written in [Octopage for iOS](Octopage - Blogging with Jekyll, Markdown and GitHub pages by Huang Tuo
https://appsto.re/gb/rk9UM.i) using `Markdown`

- Images hosted on S3 uploaded via [CloudCat](http://appcrawlr.com/ios/cloudcat-your-aws-s3-in-your-po)

- Text checked by [Ginger](http://www.gingersoftware.com/grammarcheck)

Its faster to write on an actual computer but it does make coming up with draft blog posts as soon as you have the idea easy. 

It is really good for taking a screenshot on your phone, using the phones image editing tools then uploading to Amazon S3 then finishing off the blog post when you would normally be checking twitter or social media. 

I am hoping this will drive me to write more blog posts this year than I did when it was hosted on **blogger** and eventually my writing will improve with the benefit of more traffic and better SEO. 

Open Source and contributing to projects is another challenge for me this yesr including releasing some of the projects I have been working on. 






