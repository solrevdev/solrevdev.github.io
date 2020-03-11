---
published: true
layout: post
title: >-
  ERR_HTTP2_INADEQUATE_TRANSPORT_SECURITY error on down-level windows operating
  systems
author: John Smith
tags:
  - '#dotnetcore'
  - '#aspnetcore'
  - '#IIS'
  - '#SSL'
  - '#WindowsServer2012R2'
  - '#HTTP/2'
---

The other day I was going to test and debug some code on a Windows Server 2012RC machine.

When running my asp.net core 3.1 razor pages website I encountered the exception:

> ERR_HTTP2_INADEQUATE_TRANSPORT_SECURITY

This site worked fine elsewhere so to try and narrow down the problem I created a brand new asp.net core website to see if it was something in my code that was the issue but I had the same error showing up in google chrome.

After some googling, I tried to reset the servers self-signed SSL certificate by using the following closing the browser in between but that had no effect:

```powershell
dotnet dev-certs https --clean
dotnet dev-certs https --trust
```

I created a [github issue](https://github.com/aspnet/AspNetCore.Docs/issues/16434) and the ever-helpful [@guardrex](https://github.com/guardrex) came to my rescue again and pointed me in the right direction.

It is a [known bug](https://github.com/dotnet/aspnetcore/issues/16811) and there is an open Github issue for it.

**Workaround**

So here for others and me if this happens again is my workaround:

A specific down-level machine (Windows Server 2012R2) was causing the exception and because I knew which machine, I had access to its `Environment.MachineName` which I use later to programmatically decide which `ListenOptions.Protocols` Kestrel should load.

HTTP/1 on the down-level machine but HTTP/2 elsewhere.

So, I created an `appsettings.{the-environment.machinename-value-here}.json` file alongside `appsettings.Development.json` with the following HTTP/1 settings rather than the default HTTP/2 settings that are loaded by default elsewhere.

**appsettings.machinename.json**

```json
{
  "Kestrel": {
    "EndpointDefaults": {
      "Protocols": "Http1"
    }
  }
}
```

Then in Program.cs I modified `CreateHostBuilder` to read the above custom appsettings.json file.

Note the line containing: `config.AddJsonFile($"appsettings.{Environment.MachineName}.json", optional: true);`


**Program.cs**

```csharp

public static IHostBuilder CreateHostBuilder (string[] args)
{
    return Host
        .CreateDefaultBuilder (args)
        .ConfigureAppConfiguration ((hostingContext, config) =>
        {
            config.AddJsonFile ($"appsettings.{Environment.MachineName}.json", optional : true);
            config.AddCommandLine (args);
        })
        .ConfigureWebHostDefaults (webBuilder => webBuilder.UseStartup<Startup> ());
}

```

Success 🎉
