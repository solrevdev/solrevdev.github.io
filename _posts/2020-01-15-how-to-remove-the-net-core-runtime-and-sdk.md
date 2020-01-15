---
published: true
layout: post
title: How to remove the .NET Core Runtime and SDK
author: John Smith
tags:
  - '#dotnetcore'
  - '#aspnetcore'
  - '#sdk'
  - '#dotnet-core-uninstall'
---
Today I noticed a windows machine that I look after had absolutely loads of versions of the dotnetcore framework installed on it. 

It seemed like every major and minor version from 1.0 to the latest 3.1 and many previews in-between had been installed.

To see if your machine is the same try this command in your terminal:

```powershell
dotnet --list-sdks
```

Microsoft has a page titled [How to remove the .NET Core Runtime and SDK](https://docs.microsoft.com/en-us/dotnet/core/versions/remove-runtime-sdk-versions?tabs=windows) which explains how to remove older versions.

There is also a [tool to help uninstall these versions](https://docs.microsoft.com/en-us/dotnet/core/additional-tools/uninstall-tool?tabs=windows)  available that is worth a look.

So I downloaded and installed the tool and ran a command to see list what could be uninstalled for me.

```powershell
dotnet-core-uninstall list
```

![2020-01-15_12_27_19.png]({{site.baseurl}}/media/2020-01-15_12_27_19.png)

The tool is smart in that it knows which versions are required by Visual Studio.

So I began to uninstall the undeeded and safe to remove dotnetcore SDK's on the system.

I started by removing all preview versions of the dotnetcore sdk.

```powershell
dotnet-core-uninstall --sdk --all-previews
```

![2020-01-15_12_27_48.png]({{site.baseurl}}/media/2020-01-15_12_27_48.png)


I then re-ran the tool to ensure that these were uninstalled and to see what versions were left.

```powershell
dotnet-core-uninstall list
```

Then I built and ran my final command to remove the older versions that were not needed by Visual Studio.

```powershell
dotnet-core-uninstall remove --sdk 2.2.300 2.2.102 2.2.100 2.1.801 2.1.701 2.1.700 2.1.604 2.1.602 2.1.601 2.1.600 2.1.511 2.1.509 2.1.508 2.1.507 2.1.505 2.1.504 2.1.503 2.1.502 2.1.500 2.1.403 2.1.402 2.1.401 2.1.400 2.1.302 2.1.301 2.1.300 2.1.201 2.1.200 2.1.104 2.1.103 2.1.102 2.1.101 2.1.100 2.1.4 2.1.3 2.1.2 1.1.7
```

![2020-01-15_12_42_37.png]({{site.baseurl}}/media/2020-01-15_12_42_37.png)


One final check...

```powershell
dotnet-core-uninstall list
```

![2020-01-15_13_17_44.png]({{site.baseurl}}/media/2020-01-15_13_17_44.png)



Success 🎉
