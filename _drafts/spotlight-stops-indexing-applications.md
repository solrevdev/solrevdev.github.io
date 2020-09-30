---
layout: post
title: Spotlight stops indexing Applications
description: How to fix the Spotlight stops indexing Applications issue
tags:
  - bash
  - mojave
  - spotlight
  - macos
published: true
---
All of a sudden spotlight on my macOS Mojave macmini stopped working...

  
The fix after some Google Fu and some trial and error was as follows:

```powershell

sudo mdutil -a -i off  
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist  
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist  
sudo mdutil -a -i on

```

Hopefully this won't happen too often but if it does at least I have a fix!

  
Success? 🎉
