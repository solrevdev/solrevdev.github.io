---
layout: post
title: "ServiceStack OrmLite transaction support"
author: "John Smith"
tags:
- "#servicestack"
- "#gist"
- "#orm"
---

I am a big fan of the [ServiceStack OrmLite](https://github.com/ServiceStack/ServiceStack.OrmLite) framework. 

To quote from them directly :

>OrmLite's goal is to provide a convenient, DRY, config-free, RDBMS-agnostic typed wrapper that retains a high affinity with SQL, exposing intuitive APIs that generate predictable SQL and maps cleanly to (DTO-friendly) disconnected POCO's. 

>This approach makes easier to reason about your data access making it obvious what SQL is getting executed at what time, whilst mitigating unexpected behaviour, implicit N+1 queries and leaky data access prevalent in Heavy ORMs.

I have  been working on a fairly big project and have abstracted the data access away into a separate class library and wanted to have a `Commit()` method that allowed multiple repositories's to do their thing and to save across tables in a transactional way.

So here is an example of how I have done that:

{% gist solrevdev/d714238fb9b6b17a9f7a89463aa09f29 %}

The ServiceStack OrmLite API is very nice and maps to the `IDbConnection`   interface nicely. Do check it out. 

![alt text](https://raw.githubusercontent.com/ServiceStack/Assets/master/img/ormlite/OrmLiteApi.png "ServiceStack OrmLite Interface Image")





