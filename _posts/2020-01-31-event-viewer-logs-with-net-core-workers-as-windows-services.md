---
published: true
layout: post
title: Event Viewer Logs with .NET Core Workers as Windows Services
author: John Smith
tags:
  - dotnet
  - dotnetcore
  - csharp
  - windowsservices
---
Back in the older classic windows only .NET Framework days, I would use a cool framework called [TopShelf](http://topshelf-project.com/) to help turn a console application during development into a running windows service in production.

Today instead I was able to install and run a windows service by modifying a [.NET Core Worker project](https://devblogs.microsoft.com/aspnet/net-core-workers-as-windows-services/) by just using .NET Core natively.

Also, I was able to add some logging to the Windows Event Viewer Application Log.

First, I created a .NET Core Worker project:

```powershell
mkdir tempy && cd $_
dotnet new worker
```

Then I added some references:

```powershell
dotnet add package Microsoft.Extensions.Hosting.WindowsServices
dotnet add package Microsoft.Extensions.Logging.EventLog
```

Next up I made changes to Program.cs, In my project I am adding a HttpClient to make external Web Requests to an API.

```csharp
public static class Program
{
    public static void Main(string[] args)
    {
        var builder = CreateHostBuilder(args);
        builder.ConfigureServices(services =>
        {
            services.AddHttpClient();
        });

        var host = builder.Build();
        host.Run();
    }

    public static IHostBuilder CreateHostBuilder(string[] args) =>
        Host.CreateDefaultBuilder(args)
            .UseWindowsService()
            .ConfigureLogging((_, logging) => logging.AddEventLog())
            .ConfigureServices((_, services) => services.AddHostedService<Worker>());
}
```


The key line for adding Windows Services support is :

```csharp
.UseWindowsService()
```

**Logging to Event Viewer**

I also wanted to log to the Application Event Viewer log so notice the line:

```csharp
.ConfigureLogging((_, logging) => logging.AddEventLog())
```

Now for a little gotcha, this will only log events `Warning` and higher so the Worker template's `logger.LogInformation()` statements will display when debugging in the console but not when installed as a windows service.

To fix this make this change to appsettings.json, note the `EventLog` section where the levels have been dialled back down to `Information` level.

```json
{
    "Logging": {
        "LogLevel": {
            "Default": "Information",
            "Microsoft": "Warning",
            "Microsoft.Hosting.Lifetime": "Information"
        },
        "EventLog": {
            "LogLevel": {
                "Default": "Information",
                "Microsoft.Hosting.Lifetime": "Information"
            }
        }
    }
}
```

**Publishing and managing the service**

So with this done, I then needed to first publish, then install, start and have means to stop and uninstall the service.

I was able to manage all of this from the command line, using the [SC tool](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/cc754599(v=ws.11)) (Sc.exe) that should already be installed on windows for you and be in your path already.

Publish:

```powershell
cd C:\PathToSource\
dotnet publish -r win-x64 -c Release -o C:\PathToDestination
```

Install:

```powershell
sc create "your service name" binPath=C:\PathToDestination\worker.exe
```

Start:

```powershell
sc start "your service name"
```

Stop:

```powershell
sc stop "your service name"
```

Uninstall:

```powershell
sc delete "your service name"
```

Once I saw that all was well I was able to dial back the logging to the Event Viewer by making a change to appsettings.json, In the `EventLog` section I changed the levels back up to `Warning` level.

This means that anything important will indeed get logged to the Windows Event Viewer but most `Information` level noise will not.


Success 🎉
