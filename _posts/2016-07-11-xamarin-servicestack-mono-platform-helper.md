---
layout: post
title: "Xamarin Studio and a Platform Helper for Mac and Mono"
author: "John Smith"
tags:
- "#xamarin"
- "#cross-platform"
- "#ide"
---

Since I decided to move away from [Microsoft Windows](http://www.microsoft.com/en-gb/windows) with the purchase of my [Macbook Pro](http://www.apple.com/uk/macbook-pro/) around 4 years go I have been a big fan of not having to spin up a virtual machine with Windows on just to run [Microsoft Visual Studio](https://www.visualstudio.com/). 

Now I have used Visual Studio all the way back to the VBScript ASP and Visual Basic days and it is without doubt a fantastic IDE. 

But then [MonoDevelop](http://www.monodevelop.com/) came along and the [Mono framework](http://www.mono-project.com/) and I no longer had to exclusively stay in Visual Studio all day. 

Fast forward many years and we now have the quite amazing Xamarin Studio. An IDE that rivals Visual Studio and can run natively on the Mac and even allow you to alongside ASP.NET MVC websites, Console Apps, Windows Services (via TopShelf) also build iOS and Android apps. Even Windows mobile apps if you want to waste your time ;)


So yes. If you have not checked it out do kick the tyres of [Xamarin Studio](https://www.xamarin.com/studio)

---

Now, one issue I have at the moment and it's probably a config error but something that's not high on my list of things to fix is [NLog](https://github.com/ServiceStack/ServiceStack/wiki/Logging#nlog) on the Mac. 

It works on Windows but not the Mac.

So to fix that and to explore some C# features I have a `PlatformHelper.cs` class that tells me if I am running on Mac or Windows.

I then set the [ServiceStack](https://github.com/ServiceStack/) LogFactory to use a ConsoleLogger rather than try to write it elsewhere. 

And again, I really have to say how complete, fast and so nice to use the [ServiceStack Framework](https://servicestack.net/) is. 

---

Feel free to use the code I am using:

{% gist solrevdev/ecc2c13f2fa9476a8328a3074e714988 %}






