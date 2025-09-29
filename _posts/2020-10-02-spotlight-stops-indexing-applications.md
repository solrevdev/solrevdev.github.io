---
layout: post
title: Spotlight stops indexing Applications
description: How to fix the Spotlight stops indexing Applications issue
tags:
- bash
- mojave
- spotlight
- macos

---
All of a sudden spotlight on my macOS Mojave macmini stopped working...

There is a process called `mdutil` which manages the metadata stores used by Spotlight and was the culprit for my issue. 

The fix after some Google Fu and some trial and error was to restart this process as follows:

```bash
sudo mdutil -a -i off  
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist  
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist  
sudo mdutil -a -i on
```

Hopefully this won't happen too often but if it does at least I have a fix!

Success? 🎉