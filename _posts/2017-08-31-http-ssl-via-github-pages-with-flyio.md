---
layout: post
title: "HTTP/SSL via this GitHub Pages site with Fly.io"
author: "John Smith"
tags:
- "#https"
- "#ssl"
- "#github"
- "#github pages"
- "#adm"
---

HTTP/SSL via this GitHub Pages site with Fly.io

For a while now anything I host on Amazon Web Services I use Amazon's fantastic certificate manager to generate an SSL certificate on my behalf for free then associate that with an Elastic Load Balancer ensuring that all traffic to sites I host on AWS are being served from HTTPS and SSL. 

I also host a site on Firebase and that also comes with a free SSL/HTTPS certificate even for custom domains. 

However, this blog and [https://thedrunkfist.com/](https://thedrunkfist.com/) are both blogs that use Jekyll and Github Pages for hosting. 

That in itself isn't a problem as long as you don't have a custom domain which I do for these. 

So, for a while, I've had the choice of waiting for Github to come up with a solution, use CloudFlare to host all my DNS or take another look at let's encrypt. 

And I have been WAY too busy to set any of that up. 

Unfortunately, this has not only been nagging me as I do not practise why I preach but [time is ticking](https://www.troyhunt.com/life-is-about-to-get-harder-for-websites-without-https) in terms of how browsers are going to treat non-secure sites moving forward.

But yesterday while waiting for an engineer to come I came across a site called [https://fly.io/](https://fly.io/) which I think works like CloudFlare but seemed way easier to use as within 5 minutes on my phone I had pointed an ALIAS record to this GitHub hosted blog and it was done!

I then added some middle-where to enforce HTTP/SSL (redirect HTTP to HTTPS) and then added my Google Analytics code for tracking and by then DNS had propagated and each page was secure. 

Very impressed! 

The only issue I had was with my other site where I had a staic.thedrunkfist.com CNAME record pointing to an AWS S3 bucket for uploaded images and assets which if I changed the image URL from HTTP to HTTPS had a different Amazon SSL certificate therefore not coming from my domain. 

But with some small changes to how I linked to that all was fixed. 

I.E http://static.domain.com/1.jpg to https://s3.amazonaws.com/static.domain.com/1.jpg

I cannot recommend [https://fly.io/](https://fly.io/) enough. 

I was able to port 2 blogs hosted on GitHub Pages to HTTPS for free in 10 minutes total without giving control of all my DNS records. 
