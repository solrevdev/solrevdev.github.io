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
# Thin: a three-command fix and little else, so Google reported this as a
# Soft 404 on 20 Sept 2026. The post stays live and linked from /archive/; it
# just leaves the index and the sitemap. Remove both keys if it is expanded.
robots: noindex, follow
sitemap: false

---
Every time `apt-get upgrade` upgrades my local MySQL instance on my Ubuntu laptop I get the following error:

```bash
(1698, "Access denied for user 'root'@'localhost'")
```

The fix each time is the following, so here it is for me next time save me wasting time googling the error every time.

```bash
sudo mysql -u root

use mysql;

update user set plugin='mysql_native_password' where User='root';

flush privileges;
```

And with that all is well again!

Success? 🎉