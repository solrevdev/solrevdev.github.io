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

**Overview** ☀

I have now built my first .NET Core Global Tool!

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
dotnet new console -n solrevdev.seedfolder
```

**Metadata** 📖

What sets a standard .NET Core console application and a global tool apart is some important metadata in the \`.csproj\` file.

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>netcoreapp3.1</TargetFramework>
    
    <PackAsTool>true</PackAsTool>
    <ToolCommandName>seedfolder</ToolCommandName>
    <PackageOutputPath>./nupkg</PackageOutputPath>
    <NoDefaultExcludes>true</NoDefaultExcludes>    
    <Version>1.0.0</Version>
    
    <Title>solrevdev.seedfolder</Title>
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

The extra tags from  `PackAsTool` to `Version`  are required fields while the `Title` to `PackageTags` are useful to help describe the package in NuGet and help get it discovered.

**Packaging and Installation** ⚙

Once I was happy that my console application was working the next step was to create a NuGet package by running the [dotnet pack](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-pack "dotnet pack") command:

```powershell
dotnet pack
```

This produces a _nupkg_ package.  This nupkg NuGet package is what the .NET Core CLI uses to install the global tool.

So, to package and install locally without publishing to NuGet which will be needed while you are still testing you need the following:

```powershell
dotnet pack
dotnet tool install --global --add-source ./nupkg solrevdev.seedfolder
```

Your tool should now be in your path accessible from any folder. You call your tool whatever was in the ToolCommandName property in your .csproj file

```xml
<ToolCommandName>seedfolder</ToolCommandName>
```

You may find you need uninstall and instal while you debug.

To uninstall you need to do as follows:

```powershell
dotnet tool uninstall -g solrevdev.seedfolder
```

Once you are happy with your tool and you have installed in globally and tested it you can now publish this to NuGet.

**Publish to NuGet** 🚀

Head over to NuGet and [create an API Key](https://www.nuget.org/account/apikeys "create an API Key")

![NuGet API Keys](/media/2020-10-03_2020-10-03_14-27-10_nuget-api-keys.png "NuGet API Keys")

Once you have this key go to your GitHub Project and under settings and secrets create a new secret named `NUGET_API_KEY` with the value you just created over at NuGet.

![Github Secrets](/media/2020-10-03_2020-10-03_14-35-47_github-secrets.png "Github Secrets")

Finally create a new workflow like the one below which will check out the code, build and package the .NET Core console application as a NuGet package then using the API key we just created we will automatically publish the tool to NuGet.

Each time you commit do not forget to bump the version tag e.g. `<Version>1.0.0</Version>`

```yml
name: CI

on:
    push:
        branches:
            - master
            - release/*
    pull_request:
        branches:
            - master
            - release/*

jobs:
    build:
        runs-on: windows-latest

        steps:
            - name: checkout code
              uses: actions/checkout@v2           

            - name: setup .net core sdk
              uses: actions/setup-dotnet@v1
              with:
                  dotnet-version:  '3.1.x' # SDK Version to use; x will use the latest version of the 3.1 channel

            - name: dotnet build
              run: dotnet build solrevdev.seedfolder.sln --configuration Release
            
            - name: dotnet pack
              run: dotnet pack solrevdev.seedfolder.sln -c Release --no-build --include-source --include-symbols

            - name: setup nuget
              if: github.event_name == 'push' && github.ref == 'refs/heads/master'
              uses: NuGet/setup-nuget@v1.0.2
              with:
                  nuget-version: latest

            - name: Publish NuGet
              uses: rohith/publish-nuget@v2.1.1
              with:
                PROJECT_FILE_PATH: src/solrevdev.seedfolder.csproj # Relative to repository root
                NUGET_KEY: ${{secrets.NUGET_API_KEY}} # nuget.org API key
                PACKAGE_NAME: solrevdev.seedfolder
```

**Find More** 🔍

Now that you have built and published a .NET Core Global Tool you may wish to find some others for inspiration.

Search the [NuGet](https://www.nuget.org/ "NuGet") website by using the ".NET tool" package type filter or see the list of tools in the [natemcmaster/dotnet-tools](https://github.com/natemcmaster/dotnet-tools "natemcmaster/dotnet-tools") GitHub repository.

Success! 🎉