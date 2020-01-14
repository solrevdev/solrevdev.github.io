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

So today, I raised a [GitHub issue](https://github.com/OmniSharp/omnisharp-vscode/issues/3477) because after I had opened the result of `dotnet new mvc` in VSCode the problems window would have approximately 120 issues and the code editor window would be full of red squiggles.

![](https://pbs.twimg.com/media/EMJhNcRXkAEgE_-.jpg)

---

I was running the very [latest version of dotnetcore](https://dotnet.microsoft.com/download/dotnet-core/3.0)

![](https://pbs.twimg.com/media/EMJhyLSWwAIxryE.png)

---

And the very latest version of [VSCode](https://code.visualstudio.com/)

![](https://pbs.twimg.com/media/EMJiAp1WoAA5Y6-.png)

---

I had not changed anything in the .csproj file. It was fresh from running `dotnet new mvc` from the terminal.


![](https://pbs.twimg.com/media/EMOFqFlX0AA2KFt.jpg)

---

So, I raised an issue over on [GitHub](https://github.com/OmniSharp/omnisharp-vscode/issues/3477).

![github-issue-3477.png]({{site.baseurl}}/media/github-issue-3477.png)

---

Big thanks to the rapid response and answer from [@filipw](https://github.com/filipw), who discovered that it was the [homebrew](https://brew.sh/) [cellar](https://docs.brew.sh/Formula-Cookbook) version of mono that was the issue and that intstalling the [stable version of mono](https://www.mono-project.com/download/stable/) was the fix.

![](https://pbs.twimg.com/media/EMOMjtmXkAA6BG7.png)


![](https://pbs.twimg.com/media/EMOMjtiW4AAKpZ2.png)

---

Success 🎉
