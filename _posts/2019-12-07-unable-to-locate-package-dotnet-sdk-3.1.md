---
published: false
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

Every time there is a new release of [dotnetcore](https://dotnet.microsoft.com/download) I need to get it updated on the three environments where I develop and deploy code. 

I develop and deploy on macOS, Windows and Linux (Ubuntu) and homebrew and chocolatey will update the version of dotnetcore for me, sometimes there is a delay but they will update them.

However, each release of dotnetcore I always have to manually intervene and install it manually.

If you follow the instructions over at [https://docs.microsoft.com/en-gb/dotnet/core/install/linux-package-manager-ubuntu-1904](https://docs.microsoft.com/en-gb/dotnet/core/install/linux-package-manager-ubuntu-1904]) you will get the following error message:


*Unable to locate package dotnet-sdk-3.1*

The issue that page targets 19.04 and I am running 19.10

So, If you are me from the future wanting to know how to get the latest version installed and not want the waffle here is what you need to do 


```bash
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo apt-add-repository https://packages.microsoft.com/ubuntu/19.10/prod
sudo apt-get update
sudo apt-get install dotnet-sdk-3.1
```

Success 🎉
