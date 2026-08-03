---
published: true
layout: post
title: 'homebrews cellar version of mono breaks omnisharp'
author: John Smith
tags:
  - '#dotnetcore'
  - '#aspnetcore'
  - '#homebrew'
  - '#omnisharp'
  - '#mono'
---

> **Note, August 2026:** this post is from December 2019. The screenshots were
> originally hotlinked from Twitter's image CDN. They are now served from this
> site so the post does not break if those links stop working. The text and the
> images are otherwise unchanged.

So today, I raised a [GitHub issue](https://github.com/OmniSharp/omnisharp-vscode/issues/3477) because after I had opened the result of `dotnet new mvc` in VSCode the problems window would have approximately 120 issues and the code editor window would be full of red squiggles.

![VSCode showing HomeController.cs covered in red squiggles, with the problems panel reporting 119 errors such as "The type or namespace name 'System' could not be found"]({{site.baseurl}}/media/2019-12-20-omnisharp-119-problems.jpg)

---

I was running the very [latest version of dotnetcore](https://dotnet.microsoft.com/download/dotnet-core/3.0)

![Terminal output from dotnet --info showing .NET Core SDK 3.1.100 on Mac OS X 10.14]({{site.baseurl}}/media/2019-12-20-dotnet-info.png)

---

And the very latest version of [VSCode](https://code.visualstudio.com/)

![The Visual Studio Code about dialog showing version 1.41.0]({{site.baseurl}}/media/2019-12-20-vscode-version.png)

---

I had not changed anything in the .csproj file. It was fresh from running `dotnet new mvc` from the terminal.


![MvcApp.csproj open in VSCode, unchanged and targeting netcoreapp3.1, while the problems panel still reports 120 errors]({{site.baseurl}}/media/2019-12-20-mvcapp-csproj-unchanged.jpg)

---

So, I raised an issue over on [GitHub](https://github.com/OmniSharp/omnisharp-vscode/issues/3477).

![The GitHub issue raised against the omnisharp-vscode repository]({{site.baseurl}}/media/github-issue-3477.png)

---

Big thanks to the rapid response and answer from [@filipw](https://github.com/filipw), who discovered that it was the [homebrew](https://brew.sh/) [cellar](https://docs.brew.sh/Formula-Cookbook) version of mono that was the issue and that intstalling the [stable version of mono](https://www.mono-project.com/download/stable/) was the fix.

![Terminal output from mono --version showing the Mono JIT compiler at 6.4.0.198]({{site.baseurl}}/media/2019-12-20-mono-version.png)


![The same project open in VSCode after installing the stable Mono release, with the problems panel down to two minor style hints]({{site.baseurl}}/media/2019-12-20-omnisharp-fixed.png)

---

Success 🎉
