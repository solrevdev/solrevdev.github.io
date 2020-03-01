---
published: true
layout: post
title: Restart Omnisharp process within Visual Studio Code
author: John Smith
tags:
  - dotnet
  - vscode
  - omnisharp
---
Another quick one for today, Every now and again my intellisense get's confused in Visual Studio Code displaying errors and warnings that should not exist.

The fix for this is to restart the Omnisharp process.

So first off get the commmand pallette up:

<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>

Then type:

`>omnisharp:restart omnisharp`

Everything was then back to normal.

Success 🎉