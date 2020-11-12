---
layout: post
description: How to migrate from .NET Core 3.1 to .NET Core 5.0
tags:
- aspnetcore
- dotnet5
- csharp
- dotnetcore

---
## How to migrate from .NET Core 3.1 to .NET Core 5.0

The very latest version of .NET Core was launched at [.NET Conf](https://www.dotnetconf.net/).

I decided to wait until the upgrade was available in all the various package managers such as homebrew on macOS and apt-get on Ubuntu and chocolatey on Windows.

This ensured that my operating systems were upgraded from .NET Core 3.1 to .NET Core 5.0 for me almost automatically.

The next task was to update my software to use the latest and greatest version.

The [migrate from .NET Core 3.1 to 5.0](https://docs.microsoft.com/en-us/aspnet/core/migration/31-to-50?view=aspnetcore-5.0&tabs=visual-studio-code) document over at Microsoft should help you as it did me.

But for those that want to know what I had change here goes:

## An ASP.NET Core Razor Pages App

The main change is to the Target Framework property.in the .csproj file however, instead I had to change it in my Directory.Build.Props file which covers all of the projects in my solution.

\** Directory.Build.Props: **

```diff
- TargetFramework>netcoreapp3.1</TargetFramework>
+<TargetFramework>net5.0</TargetFramework>
```

Next up I had to make a change to prevent a new build error that cropped up in an extension method of mine:

\** HttpContextExtensions.cs **

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

\** .vscode/launch.json **

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

This particular project has its source code hosted at Bitbucket and my pipelines file needed the following change.

\** bitbucket-pipelines.yml **

```diff
- image: mcr.microsoft.com/dotnet/core/sdk:3.1
+ image: mcr.microsoft.com/dotnet/sdk:5.0
pipelines:
    default:
        - step:
```

A related change was that I needed to make a change to my Dockerfile

\** Dockerfile **

```diff
- FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
+ FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build

- FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS runtime
+ FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS runtime
```

I then ran a tool called [dotnet outdated](https://github.com/dotnet-outdated/dotnet-outdated) which then upgraded all my NuGet packages including the needed Microsoft one's going from 3.1 to 5.0 for example:

\** dotnet outdated **

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

\** web.csproj **

```diff
- <PackageReference Include="Microsoft.AspNetCore.Mvc.NewtonsoftJson" Version="3.1.9" />
+ <PackageReference Include="Microsoft.AspNetCore.Mvc.NewtonsoftJson" Version="5.0.0" />
```

And finally, one thing I forgot once I tried to deploy was that in my project, I use [Visual Studio Publish Profiles](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/visual-studio-publish-profiles?view=aspnetcore-5.0) to automatically deploy the site via MsBuild

\**/Properties/PublishProfiles/deploy.pubxml **

```diff
-    <PublishFramework>netcoreapp3.1</PublishFramework>
+    <PublishFramework>net5.0</PublishFramework>
-    <TargetFramework>netcoreapp3.1</TargetFramework>
+    <TargetFramework>net5.0</TargetFramework>
     <SelfContained>false</SelfContained>
     <_IsPortable>true</_IsPortable>
```

And with that I was done. A fairly large and complex application was ported.

Success 🥳