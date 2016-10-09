---
layout: post
title: "Force SSL on IIS hosted ASP.NET website under AWS ELB"
author: "John Smith"
tags:
- "#aws"
- "#iis"
- "#elb"
---

How to force HTTPS / SSL on ASP.NET websites behind AWS ELB

I love HTTPS / SSL and think that all websites should be served this way. Including this blog which I am working on. 

It is currently hosted on GitHub Pages so that is my current barrier to getting this done. 

However whereas once it was a premium expensive service it is getting easier and cheaper and one way 
is to use Amazon Web Services and the [Certificate Manager](https://aws.amazon.com/certificate-manager/) service 
where you can provision a wildcard certificate. 

Once I set that up I pointed my SSL certificate to an [Amazon Elastic Load Balancer](https://aws.amazon.com/elasticloadbalancing/) which then 
routes traffic to an EC2 instance. 

One nice thing you may want to do is to then force HTTPS/SSL on all requests. 

For ASP.NET websites hosted on IIS you can add some rewrite rules into the Web.Config file that will do that for you. 

As I will need to use this code snippet again I will leave it here for myself and others to use.  

---

Add this xml rewrite rule to your Web.Config file bearing in mind you may aleady have the system.webServer node in your config file.

{% gist solrevdev/8e1de4ce29c4d356c43dc3e91f1d3b71 %}





