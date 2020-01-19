---
published: false
layout: post
title: Ubuntu Arc Menu Upgrade Error
author: John Smith
tags:
  - '#ubuntu'
  - '#arc'
  - '#gnome'
  - '#linux'
---
Tonight a desktop notification popped up on my Ubuntu 19.10 desktop to remind me that my [Arc Menu](https://extensions.gnome.org/extension/1228/arc-menu/) [Gnome Extension](https://extensions.gnome.org/) had an update.

Here is the [Arc Menu](https://extensions.gnome.org/extension/1228/arc-menu/) in action:

![2020-01-19_22-03-15_arc_menu.png]({{site.baseurl}}/media/2020-01-19_22-03-15_arc_menu.png)


Normally I can update it via either Google Chrome or Firefox using the Gnome Extensions website](https://extensions.gnome.org/) however tonight when I tried the update an error occurred. 

Literrally an `Error`!

![2020-01-19_20-52-06_arc_error.png]({{site.baseurl}}/media/2020-01-19_20-52-06_arc_error.png)

The menu was missing and I tried to reinstall, reboot and all the usual turn it off and back on again tricks but to no avail. 

After some duckduckgo'ing (I am trying [duckduckgo](https://duckduckgo.com/) as my default search these days over the evil Google), I came across the solution of restarting Gnome. 

So for anyone else that needs this solution or for me if/when this happens again here is what to do when you see the error. 

Press <kbd><kbd>Alt</kbd>+<kbd>F2</kbd></kbd> to bring up a dialog then type <kbd>r</kbd>

![2020-01-19_22-03-14_restart_gnome.png]({{site.baseurl}}/media/2020-01-19_22-03-14_restart_gnome.png)

After a refresh, the menu should be working and the error was gone.

![2020-01-19_20-53-27_arc_success.png]({{site.baseurl}}/media/2020-01-19_20-53-27_arc_success.png)


Success 🎉
