---
published: false
layout: post
title: Timers in .NET
author: John Smith
tags:
  - .net
  - csharp
  - dotnetcore
  - timers
---
A current C# project of mine required a timer where every couple of seconds a method would fire and a potentially fairly long-running process would run.

With .NET we have a few built-in options for timers: 

`System.Web.UI.Timer`

Available in the [.NET Framework 4.8](https://docs.microsoft.com/en-us/dotnet/api/system.web.ui.timer?redirectedfrom=MSDN&view=netframework-4.8&viewFallbackFrom=netcore-3.1) which performs asynchronous or synchronous Web page postbacks at a defined interval and was used back in the older WebForms days.

`System.Windows.Forms.Timer`

This timer is optimized for use in [Windows Forms](https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.timer?view=netcore-3.1) applications and must be used in a window.

`System.Timers.Timer` 

Generates an event after a set interval, with an option to generate recurring events. This [timer](https://docs.microsoft.com/en-us/dotnet/api/system.timers.timer?redirectedfrom=MSDN&view=netcore-3.1) is almost what I need however this has quite a few [stackoverflow posts](https://stackoverflow.com/questions/46176486/system-timers-timer-crashes-on-exception-thrown) where exceptions get swallowed. 

`System.Threading.Timer`

Provides a mechanism for [executing a method on a thread pool thread](https://docs.microsoft.com/en-us/dotnet/api/system.threading.timer?redirectedfrom=MSDN&view=netcore-3.1) at specified intervals and is the one I decided to go with. 

**Issues**

I came across a couple of minor issues the first being that even though I held a reference to my Timer object in my class and disposed of it in a Dispose method the timer would stop ticking after a while suggesting that the garbage collector was sweeping up and removing it. 

My Dispose method looks like the first method below and I suspect it is because I am using the [conditional access shortcut](https://www.c-sharpcorner.com/code/275/conditional-access-in-C-Sharp-6-0.aspx) feature from C# 6 rather than explicitly checking for null first.

```cs
public void Dispose()
{ 
	// conditional access shortcut
    	_timer?.Dispose(); 
} 

public void Dispose()
{ 
    	// null check
	if(_timer != null)
	{
		_timer.Dispose(); 
	}
} 
```
A workaround is to tell the garbage collector to not collect this reference by using this line of code in timer's elapsed method.

```cs
GC.KeepAlive(_timer);
```

The next issue was that my TimerTick event would fire and before the method that was being called could finish another tick event would fire.  

This required a [stackoverflow](https://stackoverflow.com/a/13267259/2041) search where the following code fixed my issue.

```cs
// private field
private readonly object _locker = new object();

// this in TimerTick event
if (Monitor.TryEnter(_locker))
{
	try
	{
		 // do long running work here
	 	DoWork();
	 }
	 finally
	 {
	 	Monitor.Exit(_locker);
	 }
}
```
And so with these two fixes in place, my timer work was behaving as expected. 

Here is a sample class with the above code all in context for future reference

{% gist 60f58cc72b3576617486162470c50280 %}

Success 🎉
