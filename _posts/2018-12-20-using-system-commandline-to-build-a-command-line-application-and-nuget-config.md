---
layout: post
title: "Using System.CommandLine to build a command line application. Nuget.Config"
author: "John Smith"
tags:
- "#dotnetcore"
- "#nuget"
- "#myget"
- "#system.commandline"
- "#bitbucketpiplines"
---

Using System.CommandLine to build a command line application. Nuget.Config

I am writing a command line application and in order to parse arguments and display output to the console I found an
experimental library called [System.Commandline](https://github.com/dotnet/command-line-api) written by the dotnet team that works really well. 

The point for this post was that while this worked great locally I had a brain freeze when it came to getting 
[bitbucket pipelines](https://bitbucket.org/product/features/pipelines) to build this properly due to it having a custom MyGet feed for the as yet unreleased library.

So here is the sample Nuget.Config file I had to create alongside the solution file to get bitbucket pipelines to build 
this correctly.

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageRestore>
    <add key="enabled" value="True" />
    <add key="automatic" value="True" />
  </packageRestore>
  <packageSources>
    <add key="nuget" value="https://api.nuget.org/v3/index.json" />
    <add key="dotnet-core" value="https://dotnet.myget.org/F/dotnet-core/api/v3/index.json" />
    <add key="system-commandline" value="https://dotnet.myget.org/F/system-commandline/api/v3/index.json" />
  </packageSources>
  <disabledPackageSources />
  <activePackageSource>
    <add key="All" value="(Aggregate source)" />
  </activePackageSource>
</configuration>
```

Borrowing from the [wiki](https://github.com/dotnet/command-line-api/wiki) this is really how simple this is to use.

```c#
class Program
{
    /// <param name="intOption">An option whose argument is parsed as an int</param>
    /// <param name="boolOption">An option whose argument is parsed as a bool</param>
    /// <param name="fileOption">An option whose argument is parsed as a FileInfo</param>
    static void Main(int intOption = 42, bool boolOption = false, FileInfo fileOption = null)
    {
        Console.WriteLine($"The value for --int-option is: {intOption}");
        Console.WriteLine($"The value for --bool-option is: {boolOption}");
        Console.WriteLine($"The value for --file-option is: {fileOption?.FullName ?? "null"}");
    }
}
```


```shell
> dotnet run -- --int-option 123
The value for --int-option is: 0
The value for --bool-option is: False
The value for --file-option is: null
```

The dotnet team have done some really great work this year 🙌
