---
published: true
layout: post
title: Upgrade bootstrap and jquery in ASP.NET Core 3.1 with libman
author: John Smith
tags:
  - aspnnetcore
  - dotnet
  - libman
  - bootstrap
  - jquery
---
Building server-rendered HTML websites is a nice experience these days with ASP.NET Core. 

The new [Razor Pages](https://docs.microsoft.com/en-us/aspnet/core/tutorials/razor-pages/razor-pages-start?view=aspnetcore-3.1) paradigm is a wonderful addition and improvement over MVC in that it tends to keep all your feature logic grouped rather than having your logic split over many folders.

The standard `dotnet new` template does a good job of giving you what you need to get started. 

It bundles in bootstrap and jquery for you which is great but it's not obvious how you manage to add new client-side dependencies or indeed how to upgrade existing ones such as bootstrap and jquery.

In the dark old days, Bower used to be the recommended way but that has since been [depreacted](https://devblogs.microsoft.com/aspnet/what-happened-to-bower/) in favour of a new tool called [LibMan](https://docs.microsoft.com/en-us/aspnet/core/client-side/libman/?view=aspnetcore-3.1).

![LibMan](https://i.imgur.com/JoaMpl0.png "LibMan")

LibMan is like most things from Microsoft these days [open source](https://github.com/aspnet/LibraryManager).

Designed as a replacement for Bower and npm, LibMan helps to find and fetch client-side libraries from most external sources or any file system library catalogue.

There are tutorials for how to [use LibMan with ASP.NET Core in Visual Studio](https://docs.microsoft.com/en-us/aspnet/core/client-side/libman/libman-vs?view=aspnetcore-3.1) and to [use the LibMan CLI with ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/client-side/libman/libman-cli?view=aspnetcore-3.1).

The magic is done via a file in your project root called `libman.json` which describes what files, from where and to where they need to go basically.

I needed to upgrade the version of jquery and bootstrap in a new `dotnet new` project so here is the libman.json file that will replace bootstrap and jquery bundled with ASP.NET Core with the latest versions.

{% gist 59023acd7cce43f96ae2a3b9da826a8b %}

I was using Visual Studio at the time and this will manage this for you but if like me who mostly codes in Visual Studio Code on macOS or Linux then you can achieve the same result by installing and using the [LibMan Cli](https://docs.microsoft.com/en-us/aspnet/core/client-side/libman/libman-cli?view=aspnetcore-3.1).

Success 🎉
