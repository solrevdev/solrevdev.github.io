---
published: true
layout: post
title: Timers in .NET Part 2
author: John Smith
tags:
  - .net
  - csharp
  - dotnetcore
  - timers
---
I have started to cross-post to the [Dev Community](https://dev.to/) website as well as on my [solrevdev blog](https://solrevdev.com).

A previous post about [Timers in .NET](https://dev.to/solrevdev/timers-in-net-omd) received an interesting reply from [Katie Nelson](https://dev.to/katnel20) who asked about what do do with [Cancellation Tokens](https://docs.microsoft.com/en-us/dotnet/api/system.threading.cancellationtoken?view=netcore-3.1). 

**TimerCallBack**

The [System.Threading.Timer](https://docs.microsoft.com/en-us/dotnet/api/system.threading.timer?view=netcore-3.1) class has been in the original .NET Framework almost from the very beginning and the [TimerCallback](https://docs.microsoft.com/en-us/dotnet/api/system.threading.timercallback?view=netcore-3.1) delegate has a method signature that does not handle CancellationTokens nativly.

**Trial and error**

So, I span up a new `dotnet new worker` project which has StartAsync and StopAsync methods that take in a CancellationToken in their method signatures and seemed like a good place to start.

After some tinkering with my original class and some research on StackOverflow, I came across [this post](https://stackoverflow.com/a/56666084/2041) which I used as the basis as a new improved Timer.

**Improvements** 

Firstly I was able to improve on my [original TimerTest class](https://gist.github.com/solrevdev/60f58cc72b3576617486162470c50280) by replacing the field level locking object combined with its's calls to `Monitor.TryEnter(_locker)` by using the Timer's built-in  [Change](https://docs.microsoft.com/en-us/dotnet/api/system.threading.timer.change?view=netcore-3.1) method. 

Next up I modified the original TimerCallback DoWork method so that it called my new `DoWorkAsync(CancellationToken token)` method that with a CancellationToken as a parameter does check for `IsCancellationRequested` before doing my long-running work.

The class is a little more complicated than the original but it does handle <kbd>ctrl</kbd><kbd>c</kbd> gracefully.

**Source** 

So, here is the new and improved Timer class. 

{% gist f28ab81363e9875d25b3f3453339a556 Worker.cs%}

And here is the full gist with the rest of the project files for future reference.

{% gist f28ab81363e9875d25b3f3453339a556 %}

Success 🎉
