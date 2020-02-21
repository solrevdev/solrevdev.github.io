---
published: false
layout: post
title: Assembly with same name is already loaded
author: John Smith
tags:
  - dotnet
  - nuget
  - git
  - versioning
---
I am in the process of building and publishing my first ever NuGet package and while I am not ready to go into that today I can post a quick tip about fixing an error I had with a library I am using to help with git versioning. 

The library is [Nerdbank.GitVersioning](https://github.com/AArnott/Nerdbank.GitVersioning) and the error I got was when I tried to upgrade from an older version to the current one. 

The error?

```text
The "Nerdbank.GitVersioning.Tasks.GetBuildVersion" task could not be loaded from the assembly 

Assembly with same name is already loaded Confirm that the <UsingTask> declaration is correct, that the assembly and all its dependencies are available, and that the task contains a public class that implements Microsoft.Build.Framework.ITask
```

And the fix was to run the following command, thanks to [this issue](https://github.com/AArnott/Nerdbank.GitVersioning/issues/374) over on GitHub


```powershell
dotnet build-server shutdown
nbgv install
```

Success 🎉
