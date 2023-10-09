---
layout: post
title: "ServiceStack OrmLite transaction support"
author: "John Smith"
tags:
- "#servicestack"
- "#gist"
- "#orm"
canonical_url: 'https://solrevdev.com/2016/07/09/servicestack-transactions.html'
---

I am a big fan of the [ServiceStack OrmLite](https://github.com/ServiceStack/ServiceStack.OrmLite) framework.

I have  been working on a fairly big project and have abstracted the data access away into a separate class library and wanted to have a `Commit()` method that allowed multiple repositories's to do their thing and to save across tables in a transactional way.

So here is an example of how I have done that:

{% gist solrevdev/d714238fb9b6b17a9f7a89463aa09f29 %}

The ServiceStack OrmLite API is very nice and maps to the `IDbConnection`   interface nicely. Do check it out.

![alt text](https://raw.githubusercontent.com/ServiceStack/Assets/master/img/ormlite/OrmLiteApi.png "ServiceStack OrmLite Interface Image")





