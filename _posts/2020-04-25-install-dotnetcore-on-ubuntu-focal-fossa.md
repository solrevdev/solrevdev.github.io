---
published: true
layout: post
title: Install .NET Core on Ubuntu 20.04 LTS Focal Fossa
tags:
  - dotnetcore
  - dotnet
  - ubuntu
  - linux
  - focalfossa
---
A couple of days ago Canonical the custodians of the Ubuntu Linux distribution released the latest long term support version of their desktop Linux operating system.

Codenamed *Focal Fossa* the 20.04 LTS release is the latest and greatest version. For more information about its new features head over to their [blog](https://ubuntu.com/blog/ubuntu-20-04-lts-arrives).

![](https://i.imgur.com/862L8Gb.gif)

For us .NET Core developers each new release of Ubuntu generally means that whenever we need to update the .NET Core version we need to alter our package manager location so that we get the correct version.

Microsoft has now updated the dedicated page titled ["Ubuntu 20.04 Package Manager - Install .NET Core"](https://docs.microsoft.com/en-us/dotnet/core/install/linux-package-manager-ubuntu-2004) which has instructions on how to use a package manager to install .NET Core on Ubuntu 20.04.

For those looking for a TLDR; here is the info copied from that page.

**Microsoft repository key and feed needed.**

```powershell
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
```

**Install the .NET Core SDK**

```powershell
sudo apt-get update
sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install dotnet-sdk-3.1
```

**Install the ASP.NET Core runtime**

```powershell
sudo apt-get update
sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install aspnetcore-runtime-3.1
```

**Install the .NET Core runtime**

```powershell
sudo apt-get update
sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install dotnet-runtime-3.1
```

I have not pulled the trigger yet. I am waiting for things to settle down and for my 19.10 distribution to tell me its time to upgrade.

However, for those who want to upgrade now and cannot wait you can force the issue by the following.

Press <kbd>ALT</kbd> + <kbd>F2</kbd> followed by
```powershell
update-manager -cd
````

The following dialog will then appear allowing you to then upgrade now.

![](https://i.imgur.com/GPOkbZb.png)

Success 🎉
