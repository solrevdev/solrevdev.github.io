---
published: true
layout: post
title: 'The imported project "/usr/lib/mono/xbuild/15.0/Microsoft.Common.props" was not found'
author: John Smith
tags:
  - '#dotnetcore'
  - '#aspnetcore'
  - '#mono'
  - '#vscode'
  - '#vscode-insiders'
  - '#msbuild'
  - '#omnisharp'
  - '#intellisense'
  - '#linux'
  - '#ubuntu'
---

On my Ubuntu disco dingo laptop, There was a bug affecting VS Code's IntelliSense that I had just been putting up with for a good few days.


> The imported project "/usr/lib/mono/xbuild/15.0/Microsoft.Common.props" was not found


There was no such problem on macOS or Windows however as I like to write code on my Linux daily driver laptop it became harder and harder to ignore.

It's a bug that I [raised over on GitHub](https://github.com/OmniSharp/omnisharp-vscode/issues/3049) and while the full logs and environment details are over there in more detail, for brevity I will show what I believe is the main problem here:

```powershell
[warn]: OmniSharp.MSBuild.ProjectManager
        Failed to load project file '/home/solrevdev/Code/scratch/testconsole/testconsole.csproj'.
/home/solrevdev/Code/scratch/testconsole/testconsole.csproj(1,1)
Microsoft.Build.Exceptions.InvalidProjectFileException: The imported project "/usr/lib/mono/xbuild/15.0/Microsoft.Common.props" was not found. Confirm that the path in the <Import> declaration is correct, and that the file exists on disk.
```

Despite the error showing up in the OmniSharp logs I actually think the problem is with the version or build of mono that I had installed not having the assets needed for MSBuild.

So fed up of not getting IntelliSense in either VS Code or VS Code insiders I decided to try something I perhaps should have tried on day one.

That was to re-install or update my version of Mono from the official [download page](https://www.mono-project.com/download/stable/#download-lin-ubuntu).

The instructions for doing this I borrowed and adapted are from there and are as follows:

```powershell
sudo apt install gnupg ca-certificates
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
sudo apt update

sudo apt install mono-devel
```

🎉 This seems to have worked!

I now have IntelliSense again and the warning has gone away!

As I mentioned in the GitHub issue I will leave the bug open for a while as while the commands worked for me they may not persist and there may be more to it than that.

In fact, I've just read a [similar issue](https://github.com/OmniSharp/omnisharp-vscode/issues/2604#issuecomment-429814128)  that suggests that OmniSharp shouldn't be using the MSBuild assets from mono and should be using the dotnet sdk version instead.

That makes sense to me. So reinstalling mono while apparently working may not be the top solution.

I may try using [this command](https://github.com/OmniSharp/omnisharp-vscode/issues/2604#issuecomment-429814128) at some point but for now, as I said everything seems to work ok.

This post is here in case this happens again, it's nice to google a problem and find your own blog has the answer plus if anyone else benefits then even better.  👌
