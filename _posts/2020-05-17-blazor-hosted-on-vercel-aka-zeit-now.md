---
published: true
layout: post
title: Blazor hosted on vercel aka zeit now.sh
tags:
  - dotnetcore
  - dotnet
  - blazor
  - vercel
  - zeit
  - now
---
So, I decided it was time to play with Blazor WebAssembly which is in preview for ASP.NET Core 3.1. I decided I wanted to publish the sample on Zeit's now.sh platform which has now been [rebranded Vercel](https://vercel.com/blog/zeit-is-now-vercel)

If you want to follow along this was my [starting point](https://docs.microsoft.com/en-us/aspnet/core/blazor/get-started?view=aspnetcore-3.1&tabs=netcore-cli)

I use Visual Studio Code and for IDE support with vscode you will want to follow the [instructions on this page](https://docs.microsoft.com/en-gb/aspnet/core/blazor/debug?tabs=visual-studio-code&view=aspnetcore-3.1#vscode)

Firstly make sure you have [.NET Core 3.1](https://dotnet.microsoft.com/download/dotnet-core/3.1) SDK installed.

Optionally install the Blazor WebAssembly preview template by running the following command:

```powershell
dotnet new -i Microsoft.AspNetCore.Components.WebAssembly.Templates::3.2.0-rc1.20223.4
```

Make any changes to the template that you like then when you are ready to publish enter the following command

```powershell
dotnet publish -c Release
```

This will build and publish the assets you can deploy to the folder:

```powershell
bin/Release/netstandard2.1/publish/wwwroot
```

Make sure you have the now.sh command line tool installed.

```powershell
npm i -g vercel
now login
```

Navigate to this folder and run the now command line tool for deploying.

```powershell
cd bin/Release/netstandard2.1/publish/wwwroot
now --prod
```

Now you have deployed you app to vercel/now.sh. This is my deployment [https://blazor.now.sh/](https://blazor.now.sh/)

You may notice that if you navigate to a page like [https://blazor.now.sh/counter] then hit <kbd>F5</kbd> to reload you get a 404 not found error.

To fix this we need to create a configuration file to tell vercel to redirect 404's to index.html.

Create a file in your project named vercel.json that will match the publish path

```powershell
publish/wwwroot/vercel.json
```

![](https://i.imgur.com/TIElEzb.png)

Use the following vercel.json configuration to tell the now.sh platform to redirect 404's to the index.html page and let Blazor handle the routing

```json
{
    "version": 2,
    "routes": [{"handle": "filesystem"}, {"src": "/.*", "dest": "/index.html"}]
}

```

Next we need to tell .NET Core to publish that file so open your .csproj file and add the following

```xml
  <ItemGroup>
    <None Include="publish/wwwroot/vercel.json"  CopyToPublishDirectory="PreserveNewest" />
  </ItemGroup>

```

Finally you can create a `deploy.sh` file that can publish and deploy all in one command.

```powershell
#!/usr/bin/env bash

dotnet publish -c Release
now --prod bin/Release/netstandard2.1/publish/wwwroot/
```

To run this make sure it has the correct permissions
```powershell
chmod +x deploy.sh
./deploy.sh
```

And with that I can deploy Blazor WebAssembly to vercel's now.sh platform at [https://blazor.now.sh/](https://blazor.now.sh/)

![](https://i.imgur.com/rZ0wCta.png)

Next up I am thinking of deploying a Web API backend for it to talk to. Maybe a docker based deployment over at [fly.io](https://fly.io/docs/)?

Success 🎉
