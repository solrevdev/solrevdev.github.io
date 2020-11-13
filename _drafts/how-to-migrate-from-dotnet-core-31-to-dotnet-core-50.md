---
layout: post
description: How to migrate from .NET Core 3.1 to .NET Core 5.0
tags:
- aspnetcore
- dotnet5
- csharp
- dotnetcore
title: How to migrate from .NET Core 3.1 to .NET Core 5.0

---
The very latest version of .NET Core was launched at [.NET Conf](https://www.dotnetconf.net/).

It is the free, cross-platform and open source developer platform from Microsoft which includes the latest versions of ASP.NET and C#.

I decided to wait until the upgrade was available in all the various package managers such as [homebrew](https://brew.sh/) on macOS and [apt-get](https://linux.die.net/man/8/apt-get) on Ubuntu and [chocolatey](https://chocolatey.org/) on Windows before I upgraded my projects.

This ensured that my operating systems were upgraded from .NET Core 3.1 to .NET Core 5.0 for me almost automatically.

So, this post will hopefully document the steps needed to upgrade an ASP.NET Core 3.1 Razor Pages project from ASP.NET Core 3.1 to ASP.NET Core 5.0.

The [migrate from .NET Core 3.1 to 5.0](https://docs.microsoft.com/en-us/aspnet/core/migration/31-to-50?view=aspnetcore-5.0&tabs=visual-studio-code) document over at Microsoft should help you as it did me.

But for those that want to know what I had change here goes:

## Getting Started

The main change will be to the Target Framework property.in the website's .csproj file however, in my case I had to change it in my Directory.Build.Props file which covers all of the projects in my solution.

**Directory.Build.Props:**

```diff
- TargetFramework>netcoreapp3.1</TargetFramework>
+<TargetFramework>net5.0</TargetFramework>
```

Next up I had to make a change to prevent a new build error that cropped up in an extension method of mine, something I am sure worked fine under .NET Core 3.1:

**HttpContextExtensions.cs**

```diff
public static T GetHeaderValueAs<T>(this IHttpContextAccessor accessor, string headerName)
{
-   StringValues values;
+   StringValues values = default;

    if (accessor.HttpContext?.Request?.Headers?.TryGetValue(headerName, out values) ?? false)
    {
        var rawValues = values.ToString();
        if (!rawValues.IsNullOrWhitespace())
        {
            return (T)Convert.ChangeType(values.ToString(), typeof(T));
        }
    }

    return default;
}
```

Then I needed to make a change to ensure that Visual Studio Code (Insiders) would debug my project properly.

**.vscode/launch.json**

```diff
{
    "name": ".NET Core Launch (console)",
    "type": "coreclr",
    "request": "launch",
    "preLaunchTask": "build",
-   "program": "${workspaceRoot}/src/projectname/bin/Debug/netcoreapp3.1/projectname.dll",
+   "program": "${workspaceRoot}/src/projectname/bin/Debug/net5.0/projectname.dll",
    "args": [],
    "cwd": "${workspaceFolder}",
    "stopAtEntry": false,
    "console": "externalTerminal"
},
```

This particular project has its source code hosted at Bitbucket and my pipelines file needed the following change. [Bitbucket Pipelines](https://support.atlassian.com/bitbucket-cloud/docs/get-started-with-bitbucket-pipelines) is basically Atlassian's version of [Github Actions](https://github.com/features/actions).

**bitbucket-pipelines.yml**

```diff
- image: mcr.microsoft.com/dotnet/core/sdk:3.1
+ image: mcr.microsoft.com/dotnet/sdk:5.0
pipelines:
    default:
        - step:
```

A related change was that I needed to make a change to my Dockerfile so that it now uses the latest .NET 5 SDK and runtime.

**Dockerfile**

```diff
- FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
+ FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build

- FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS runtime
+ FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS runtime
```

I then ran a tool called [dotnet outdated](https://github.com/dotnet-outdated/dotnet-outdated) which then upgraded all my NuGet packages including the needed Microsoft one's going from 3.1 to 5.0 for example first I ran `dotnet-outdated`:

**dotnet outdated**

```powershell
dotnet tool install --global dotnet-outdated-tool
dotnet outdated -u

» web
  [.NETCoreApp,Version=v5.0]
  AWSSDK.S3                                          3.5.3.2       -> 3.5.4
  Microsoft.AspNetCore.Mvc.NewtonsoftJson            3.1.9         -> 5.0.0
  Microsoft.AspNetCore.Mvc.Razor.RuntimeCompilation  3.1.9         -> 5.0.0
  Microsoft.EntityFrameworkCore.Design               3.1.9         -> 5.0.0
  Microsoft.Extensions.Configuration.UserSecrets     3.1.9         -> 5.0.0
  Microsoft.VisualStudio.Web.CodeGeneration.Design   3.1.4         -> 5.0.0
  Microsoft.Web.LibraryManager.Build                 2.1.76        -> 2.1.113
```

This changed my website's csproj file to use the correct nuget packages for .NET 5. A much quicker way than doing it manually.

**web.csproj**

```diff
- <PackageReference Include="Microsoft.AspNetCore.Mvc.NewtonsoftJson" Version="3.1.9" />
+ <PackageReference Include="Microsoft.AspNetCore.Mvc.NewtonsoftJson" Version="5.0.0" />
```

## Deployments

And finally, one thing I forgot once I tried to deploy was that in my project, I use [Visual Studio Publish Profiles](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/visual-studio-publish-profiles?view=aspnetcore-5.0) to automatically deploy the site via MsBuild and I needed to change the Target Framework and Publish Framework versions before it would deploy correctly.

**/Properties/PublishProfiles/deploy.pubxml**

```diff
-    <PublishFramework>netcoreapp3.1</PublishFramework>
+    <PublishFramework>net5.0</PublishFramework>
-    <TargetFramework>netcoreapp3.1</TargetFramework>
+    <TargetFramework>net5.0</TargetFramework>
     <SelfContained>false</SelfContained>
     <_IsPortable>true</_IsPortable>
```

And with that I was done. A fairly large and complex application was ported over.

By all accounts .NET 5 has performance and allocation improvements all across the board so I am looking forward to seeing the results of all that hard work.

Success 🥳