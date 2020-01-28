---
published: false
layout: post
title: Navigate into a newly created directory
author: John Smith
tags:
  - bash
  - shell
  - terminal
  - mkdir
---
Today I came across a fantastic command line trick.

Normally when I want to create a directory in the command line it tales multiple commands to start working in that directory. 

For example: 

```powershell
mkdir tempy
cd tempy
```

Well that can be shortened to a one liner!

```powershell
mkdir tempy && cd $_
```

This is why I love software development it does not matter how long you have been doing it you are always learning something new!

Success 🎉
