---
published: true
layout: post
author: John Smith
tags:
  - '#dotnetcore'
  - '#aspnetcore'
  - '#linux'
  - '#ubuntu'
  - '#apt'
  - '#unabletolocatepackge'
---
## Unable to locate package dotnet-sdk-3.1

Every time there is a new release of [dotnetcore](https://dotnet.microsoft.com/download) I need to get it updated on the three environments where I develop and deploy code: macOS, Windows and Linux (Ubuntu).

[Homebrew](https://brew.sh/) and [Chocolatey](https://chocolatey.org/) update the version of dotnetcore for me automatically, sometimes there is a delay but they will eventually update them.

However, for Linux each release of [dotnetcore](https://dotnet.microsoft.com/download) I always have to manually intervene and install it manually.

If you follow the [instructions](https://docs.microsoft.com/en-gb/dotnet/core/install/linux-package-manager-ubuntu-1904]) from Microsoft  you will get the following error message:

```text
Unable to locate package dotnet-sdk-3.1
```

The issue is that page targets Ubuntu version 19.04 and I am running Ubuntu version 19.10 (Eoan Ermine).

So, If you are me from the future wanting to know how to get the latest version installed  here is what you need to do:

```bash
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo apt-add-repository https://packages.microsoft.com/ubuntu/19.10/prod
sudo apt-get update
sudo apt-get install dotnet-sdk-3.1
```

Success 🎉
