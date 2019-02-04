---
layout: post
title: 'Locked out of Windows Server 2012'
tags: ['windows server', 'rdp']
---
An issue I had a while back was a development lab version of Microsoft Windows Server 2012 locking me out via RDP or any other means due to RDP licensing and a grace period expiring. 

It was not a server in my room but a proper rack mounted headless server. 

Diagnosing what was wrong took ages but it turns out the fix was to delete a registry key and rebooting the server. 

Being a good devops guy I scheduled a task to delete that key again and reboot the server so this would not happen again. 

All good! 

---

Then today the same thing happened. **nightmare** 

What happened to my my scheduled task? 

Well I had a `reg delete` batch file which was also configured to run with elevated privalages so everything was setup to run correctly, however the kicker was on rebooting, the admin account I was using lost it's full control access to the registry hive. 

For now with an elevated `regedit` I gave the admin account full control to the parent node and this should be enough. 

Later I will look at setting the permissions via the batch script before running the `reg delete` command but i will check the next time it reboots. 

So for those looking for the key to delete here it is: 

```
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod" /f
```

It is a [known bug](https://support.software.dell.com/vworkspace/kb/113932) it seems. 

I have a blog post road map but this was such a gotcha I wanted to document it!

Cheers
