---
published: false
layout: post
title: aspnetcore 3.1.2 windows hosting bundle caused 503 services unavailable
author: John Smith
tags:
  - aspnetcore
  - dotnet
  - iis
---
Today [NET Core 3.1.200 SDK - March 16, 2020](https://github.com/dotnet/core/blob/master/release-notes/3.1/3.1.2/3.1.200-sdk.md) was installed on my development and production boxes.

With a new release, I tend to also install the Windows hosting bundle associated with each release, and in this case, it was [ASP.NET Core Runtime 3.1.2](https://dotnet.microsoft.com/download/dotnet-core/thank-you/runtime-aspnetcore-3.1.2-windows-hosting-bundle-installer)

However, on installing it, the next request to the website showed a 503 Service Unavailable error:

![](https://i.imgur.com/yqh8IS3.png)

Debugging the w3 process in Visual Studio showed this error:

```powershell
Unhandled exception at 0x53226EE9 (aspnetcorev2.dll) in w3wp.exe: 0xC000001D: Illegal Instruction.
```

Event Viewer had entries such as this:

![](https://i.imgur.com/KoDAVk2.png)

I tried IISRESET and uninstalling the hosting bundle but that did not help.

I noticed that the application pool was stopped for my website, Restarting it would result in the same unhandled exception as above.

As a troubleshooting exercise, I created a new application pool and pointed my website to that one and deleted the old one.

![](https://i.imgur.com/le8MZAZ.png)

This seems to fixed things for now.

Success? 🎉
