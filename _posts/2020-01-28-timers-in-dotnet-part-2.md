---
published: false
layout: post
title: Timers in .NET Part 2
author: John Smith
tags:
  - .net
  - csharp
  - dotnetcore
  - timers
---
I have started to cross post to the [Dev Community](https://dev.to/) website as well as on my [solrevdev blog](https://solrevdev.com).

My previous post about [Timers in .NET](https://dev.to/solrevdev/timers-in-net-omd) recevied an interesting reply from [Katie Nelson](https://dev.to/katnel20) who asked about what do do with Cancellation Tokens. 

So, I span up a new `dotnet new worker` project which have async StartAsync and StopAsync methods that take in a CancellationToken in the method signature.

After some tinkering with my original class and some research on stackoverflow I came across [this post](https://stackoverflow.com/a/56666084/2041) which I used as the basis as a new improved Timer 

Here is a .NET Core background service that makes uses of a CancellationToken within the a DoWork method. 

{% gist 60f58cc72b3576617486162470c50280 Worker.cs%}

Here is the full gist with the rest of the project for future referencefuture reference

{% gist 60f58cc72b3576617486162470c50280 %}

Success 🎉
