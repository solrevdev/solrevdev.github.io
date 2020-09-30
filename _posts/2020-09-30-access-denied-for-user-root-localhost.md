---
layout: post
title: Access denied for user root'@'localhost
description: How to resolve the Access denied for user root'@'localhost MySQL error
  message
tags:
- dotnet
- dotnetcore
- ubuntu
- mysql

---
Every time `apt-get upgrade` upgrades my local MySQL instance on my Ubuntu laptop I get the following error:

```powershell   
(1698, "Access denied for user 'root'@'localhost'")
```

The fix each time is the following, so here it is for me next time save me wasting time googling the error every time.

```powershell
sudo mysql -u root

use mysql;

update user set plugin='mysql_native_password' where User='root';

flush privileges;
```

And with that all is well again!

Success? 🎉