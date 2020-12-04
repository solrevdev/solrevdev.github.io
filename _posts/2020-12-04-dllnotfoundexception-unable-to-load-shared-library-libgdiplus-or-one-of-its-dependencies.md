---
layout: post
description: How to fix DllNotFoundException Unable to load shared library libgdiplus
  or one of its dependencies
tags:
- aspnetcore
- macos
- csharp
- dotnetcore
title: Unable to load shared library libgdiplus or one of its dependencies

---
**Overview** ☀

While testing a feature locally on my macmini I was uploading an image when I got the following error:

**Unable to load shared library 'libgdiplus' or one of its dependencies**

![](https://i.imgur.com/bctzWAR.png)

**Dependencies** 🌱

So, after a quick google the following was suggested to me:

**mono-libgdiplus**

```powershell
brew install mono-libgdiplus
```

I already had this installed but I re-installed just in case

![](https://i.imgur.com/tCZONkD.png)

That did not work so the next option available was to add a reference to a NuGet package that allows you to use System.Drawing on macOS

**runtime.osx.10.10-x64.CoreCompat.System.Drawing**

```xml
<PackageReference Include="runtime.osx.10.10-x64.CoreCompat.System.Drawing" Version="5.8.64" />
```

And with that all was working again. 

Success 🥳