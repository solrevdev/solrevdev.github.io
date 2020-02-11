---
published: true
layout: post
title: Windows does not remember git password
author: John Smith
tags:
  - windows
  - git
  - ssh
  - cli
---
Today I was writing a Windows batch script that would at some stage run `git pull`. 

When I ran the script it paused and displayed the message:

`Enter passphrase for key: 'c/Users/Administrator/.ssh/id_rsa'`

![2020-02-11_09_22_25.png]({{site.baseurl}}/media/2020-02-11_09_22_25.png)

No matter how many times I entered the passphrase Windows would not remember it and the prompt would appear again.

So, after some time on Google and some trial and error, I was able to fix the issue and so for anyone else that has the same issue or indeed for me from the future here are those steps.

**Enable the OpenSSH Authentication Agent service and make it start automatically.**

![2020-02-11_09_36_02.png]({{site.baseurl}}/media/2020-02-11_09_36_02.png)

**Add your SSH key to the agent with `ssh-add` at `C:\Users\Administrator\.ssh`.**

![2020-02-11_09_37_39.png]({{site.baseurl}}/media/2020-02-11_09_37_39.png)

**Test git integration by doing a `git pull` from the command line and enter the passphrase**

Enter your passphrase when asked during a `git pull` command.

**Add an environment variable for GIT_SSH**

```bash
setx GIT_SSH C:\Windows\System32\OpenSSH\ssh.exe
```

![2020-02-11_09_41_45.png]({{site.baseurl}}/media/2020-02-11_09_41_45.png)

Once these steps were done all was fine and no prompt came up again.

Success 🎉
