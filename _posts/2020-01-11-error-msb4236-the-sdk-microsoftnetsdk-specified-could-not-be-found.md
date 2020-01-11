---
published: false
layout: post
author: John Smith
tags:
  - '#dotnetcore'
  - '#aspnetcore'
  - '#msbuild'
---
## error MSB4236 The SDK Microsoft.NET.Sdk specified could not be found


### Background

Recently I was working on a website built before dotnetcore was even a thing It was targeting an older version of the original .NET Framework. 

I am slowly modernising it. Firstly I upgraded the nuget packages and re-targeted it to .NET Framework version 4.8.

Next, as the solution was split into many projects I was able to migrate many of these projects to be netstandard. 

The idea is that all that is left is to think about upgrading the website to a Razor Pages aspnetcore project from the classic model view controller website. 

### Missing SDK Build Error

While I was doing this a build script was failing. 

![Screenshot 2020-01-11 15.00.04.png]({{site.baseurl}}/_posts/media/Screenshot 2020-01-11 15.00.04.png)

The error was *error MSB4236 The SDK Microsoft.NET.Sdk specified could not be found* and is because the project now includes dotnetcore projects that need building.

### The solution

After some googling the answer was to upgrade the `Microsoft Visual Studio 2019 Build Tools` installed on that server. 

![Screenshot 2020-01-11 14.57.39.png]({{site.baseurl}}/_posts/media/Screenshot 2020-01-11 14.57.39.png)

Select `.NET Core Build Tools` and/or `Web development build tools` and install

![Screenshot 2020-01-11 14.59.06.png]({{site.baseurl}}/_posts/media/Screenshot 2020-01-11 14.59.06.png)

Once this was done the build worked.

Success 🎉
