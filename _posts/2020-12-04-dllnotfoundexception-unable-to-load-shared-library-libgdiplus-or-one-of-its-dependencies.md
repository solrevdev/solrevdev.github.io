
---
layout: post
description: How to fix DllNotFoundException Unable to load shared library libgdiplus or one of its dependencies
tags:
- aspnetcore
- macos
- csharp
- dotnetcore
title: Unable to load shared library libgdiplus or one of its dependencies
---


**Overview** ☀

Even though I am sure this was working before today whilst testing a feature locally by uploading an image I got the
the following error:

**Unable to load shared library 'libgdiplus' or one of its dependencies**

![](https://i.imgur.com/bctzWAR.png)

**Dependacies** 🌱

I was developing on my macOS so after a quick google the following was suggested to me:

**mono-libgdiplus**

```powershell
brew install mono-libgdiplus
```

I already had this installed but I re-installed just in case

![](https://i.imgur.com/tCZONkD.png)

**runtime.osx.10.10-x64.CoreCompat.System.Drawing**

So, in my case I needed to add a reference to the nuget package that allows you to use System.Drawing on macOS

```xml
<PackageReference Include="runtime.osx.10.10-x64.CoreCompat.System.Drawing" Version="5.8.64" />
```

And with that all was working again. In my case it was the additional nuget package that worked for me.


Success 🥳