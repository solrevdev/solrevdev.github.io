---
layout: post
title: 'Visual Studio 2015 Update 3 install issue'
categories: ['visual studio', '.net core']
tags: ['visual studio', '.net core']
---
I am upgrading a project to use Visual Studio 2015 Community Edition and one of the updates it recommends was not installing with the following error:

```
    Setup has detected that Visual Studio 2015 Update 3 may not be completely installed. Please repair Visual Studio 2015 Update 3, then install this product again.
```


After some googling I came across [this fix from this site](https://swimmingpooldotnet.wordpress.com/2016/07/23/setup-has-detected-that-visual-studio-2015-update-3-may-not-be-completely-installed-please-repair-visual-studio-2015-update-3-then-install-this-product-again/) which works a treat so thank you very much internet!

```

"DotNetCore.1.0.0-VS2015Tools.Preview2.exe" SKIP_VSU_CHECK=1

```

As the original post mentions do run the `cmd.exe` process as an `administrator`.

Cheers!