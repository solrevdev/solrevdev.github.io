---
layout: post
title: Host ASP.NET Core on Windows with IIS
author: John Smith
tags:
  - '#dotnetcore'
  - '#aspnetcore'
  - '#iis'
  - '#windows'
published: true
---

A recent push to production broke an ASP.NET Core application I have running and it took me a while to find out the underlying problem. 

The error was ```502 - Web server received an invalid response while acting as a gateway or proxy server``` with nothing obvious in the logs that helped me.

First I published a last known good version of my application by creating a new branch in git and resetting it to the last known good commit I had. 

The idea being I can deploy from this branch while I investigated and once fixed I could delete the branch.

```shell
git reset e64c51bf1c3bdde753ff2d8fd8b18d4d902b8b5b --hard
```

Then digging around the changes between branches in git I noticed that either Visual Studio and/or my MSBuild based deployment script had added a property pointing to ```hostingModel="InProcess"``` to my web.config and a property referencing ```AspNetCoreModuleV2``` to my .csproj file. 

So with some time spent on both StackOverflow and the [ASP.NET Core documentation](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/aspnet-core-module?view=aspnetcore-2.2) sites it was apparent that in order to have the more performant```InProcess``` hosting model via the ```AspNetCoreModuleV2``` module the [.NET Core 2.2 Runtime & Hosting Bundle for Windows (v2.2.2)](https://dotnet.microsoft.com/download/thank-you/dotnet-runtime-2.2.2-windows-hosting-bundle-installer) needs to be installed.

After many combinations and deployments, I ended up with this successful combination of settings.

**Project File**

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>netcoreapp2.2</TargetFramework>
    <AspNetCoreHostingModel>InProcess</AspNetCoreHostingModel>
    <AspNetCoreModuleName>AspNetCoreModuleV2</AspNetCoreModuleName>      
    <TieredCompilation>true</TieredCompilation>
    <LangVersion>latest</LangVersion>
  </PropertyGroup> 
  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.App" />
  </ItemGroup>   
</Project>
```

**Web.Config**

```xml
<configuration>
  <!--
    Configure your application settings in appsettings.json. Learn more at http://go.microsoft.com/fwlink/?LinkId=786380
  -->
  <system.webServer>
    <rewrite>
      <rules>
        <rule name="HTTPS rewrite behind ELB rule" stopProcessing="true">
          <match url="^(.*)$" ignoreCase="false" />
          <conditions>
            <add input="{HTTP_X_FORWARDED_PROTO}" pattern="^http$" ignoreCase="false" />
          </conditions>
          <action type="Redirect" redirectType="Found" url="https://{SERVER_NAME}{URL}" />
        </rule>
      </rules>
    </rewrite>
    <handlers>
      <add name="aspNetCore" path="*" verb="*" modules="AspNetCoreModuleV2" resourceType="Unspecified" />
    </handlers>
    <aspNetCore processPath="dotnet" arguments=".\web.dll" stdoutLogEnabled="false" stdoutLogFile=".\logs\stdout" forwardWindowsAuthToken="false" hostingModel="InProcess" />
  </system.webServer>
</configuration>
```

So after the install of [.NET Core 2.2 Runtime & Hosting Bundle for Windows (v2.2.2)](https://dotnet.microsoft.com/download/thank-you/dotnet-runtime-2.2.2-windows-hosting-bundle-installer) and one reboot later all was well again.  🙌

Success 
