---
published: true
layout: post
title: MySQL server has gone away
author: John Smith
tags:
  - mysql
  - macos
  - terminal
---
Another quick one for today.

After a little while developing on and against Windows, I am back developing on the lovely macOS.

I have a local install of MySQL and when I connected to it via my terminal using `mysql -u root` I would connect ok but as soon as I tried to do anything I would get the following error.


```powershell
ERROR 2006 (HY000): MySQL server has gone away
No connection. Trying to reconnect...
ERROR 2013 (HY000): Lost connection to MySQL server at 'reading initial communication packet', system error: 102
ERROR:
Can't connect to the server
```

![screenshot](https://i.imgur.com/GZILrCL.png)

This turned out to be an easy fix, one of the first debugging steps was to restart the MySQL service on my machine followed by restarting the MySQL process.

```powershell
sudo killall mysqld
mysql.server start
```

I was then able to connect via `mysql -uroot`!

Success 🎉

