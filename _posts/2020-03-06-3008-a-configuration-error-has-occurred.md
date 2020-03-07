---
published: true
layout: post
title: 3008 A configuration error has occurred
author: John Smith
tags:
  - dotnet
  - iis
  - web
---
A static HTML website I look after is hosted on a Windows Server 2012R2 instance running IIS, it makes use of a `web.config` file as it has some settings that allow this site to be served from behind an Amazon Web Services Elastic Load Balancer.

Today it kept crashing with the thousands of these events in event viewer:

```powershell
Event code: 3008
Event message: A configuration error has occurred.
Event time: 05/03/2020 09:15:49
Event time (UTC): 05/03/2020 09:15:49
Event ID: 83032f1dc8d9486e95dfc13f9f88a22d
Event sequence: 1
Event occurrence: 1
Event detail code: 0
Application information:
    Application domain: /LM/W3SVC/6/ROOT-1789-132278733487264657
    Trust level: Full
    Application Virtual Path: /
    Application Path: C:\Sites\your-website.com\static\
    Machine name: PRODUCTION-WEB-
Process information:
    Process ID: 2104
    Process name: w3wp.exe
    Account name: IIS APPPOOL\your-website.com
Exception information:
    Exception type: ConfigurationErrorsException
    Exception message: Unrecognized attribute 'targetFramework'. Note that attribute names are case-sensitive. (C:\Sites\your-website.com\static\web.config line 4)
Request information:
    Request URL: http://www.your-website.com/default.aspx
    Request path: /default.aspx
    User host address: 172.31.38.122
    User:
    Is authenticated: False
    Authentication Type:
    Thread account name: IIS APPPOOL\your-website.com
Thread information:
    Thread ID: 5
    Thread account name: IIS APPPOOL\your-website.com
    Is impersonating: False
    Stack trace:
   at System.Web.HttpRuntime.HostingInit(HostingEnvironmentFlags hostingFlags)
Custom event details:
```

![EventViewer](https://i.imgur.com/tO2yXq5.png "EventViewer")

The fix was to change the websites application pool to use .NET CLR Version 4 rather than .NET CLR Version 2

So, open **IIS**, choose **Application Pools** from the left-hand navigation, Choose your app pool and click **basic settings** to open the dialog to change which .NET CLR Version to use.

![AppPool](https://i.imgur.com/UuKgIM7.png "AppPool")

Once this was done the errors stopped and the site stopped crashing

Success 🎉
