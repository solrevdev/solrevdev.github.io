---
layout: post
title: Creating a .NET Core Global Tool
description: How to create a .NET Core Global Tool
tags:
- dotnet-global-tools
- dotnet-global-tool
- csharp
- dotnetcore

---
I have now built my first .NET Core Global Tool!  

**Overview** ☀

A .NET Core Global Tool is special NuGet package that contains a console application that is installed globally on your machine and is installed in a default directory that is added to the PATH environment variable. 

You can invoke the tool from any directory on the machine without specifying its location.

**The Application** 🌱

So, rather than the usual _Hello World_ example to install as a global tool I wanted a tool that would be useful to me. 

I wanted to build a tool that will create a folder named after either a Trello card reference or the current Date in a YYYY-MM-DD format followed by the folder name and to then also copy some default standard dotfiles over in that folder

For example:

`MO-818_create-dotnet-tool`

`2020-09-29_create-dotnet-tool`

It will also copy the following dotfiles over:

* .dockerignore
* .editorconfig
* .gitattributes
* .gitignore
* .prettierignore
* .prettierrc
* omnisharp.json

I won't explain how this code was written; you can view the [source code](https://github.com/solrevdev/seedfolder "source code") over at GitHub to understand how this was done. 

The important thing to note is that the application is a standard .NET Core console application that you can create as follows: 

```powershell
dotnet new console -n yourconsoleapp
```

**Metadata** 📖

What sets a standard .NET Core console application and a global tool apart is some important metadata in the \`.csproj\` file.

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>netcoreapp3.1</TargetFramework>
    <PackAsTool>true</PackAsTool>
    <ToolCommandName>yourtoolname</ToolCommandName>
    <PackageOutputPath>./nupkg</PackageOutputPath>
    <NoDefaultExcludes>true</NoDefaultExcludes>
    
    <Version>1.0.0</Version>
    <Title>your project name</Title>
    <Description>A nice description of your tool</Description>
    <PackageDescription>A nice description of your tool</PackageDescription>
    <Authors>your github username</Authors>
    <Company>your github username</Company>
    <RepositoryUrl>https://github.com/username/projectname</RepositoryUrl>
    <PackageProjectUrl>https://github.com/username/projectname</PackageProjectUrl>
    <PackageReleaseNotes>https://github.com/username/projectname</PackageReleaseNotes>
    <PackageLicenseExpression>MIT</PackageLicenseExpression>
    <RepositoryType>git</RepositoryType>
    <PackageTags>dotnetcore;;dotnet;csharp;dotnet-global-tool;dotnet-global-tools;</PackageTags>
  </PropertyGroup>
</Project>
```

Installation ⚙

How to install here

Publish to NuGet 🚀

How to publish to NuGet

**Find More** 🔍

Search the [NuGet](https://www.nuget.org/) website by using the ".NET tool" package type filter or see the list of tools in the [natemcmaster/dotnet-tools](https://github.com/natemcmaster/dotnet-tools) GitHub repository.

Success! 🎉