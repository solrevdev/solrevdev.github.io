---
published: true
layout: post
title: VueJS GistPad Interactive Playground
author: John Smith
tags:
  - '#vscode'
  - '#vuejs'
  - '#gistpad'
  - '#api'
  - '#policedata'
---
Recently I installed a VS Code extension called [GistPad](https://marketplace.visualstudio.com/items?itemName=vsls-contrib.gistfs) about which the marketplace docs go on to say:

	GistPad is a Visual Studio Code extension that allows you to manage GitHub Gists entirely within the editor. You can open, create, delete, fork, star and clone gists, and then seamlessly begin editing files as if they were local.

It is a great extension and I am using Gists way more now. 

![2020-01-16_11-23-46_gistpad.png]({{site.baseurl}}/media/2020-01-16_11-23-46_gistpad.png)


**Install**

To install the extension launch VS Code Quick Open (<kbd>Ctrl</kbd>+<kbd>P</kbd>), paste the following command, and press enter.

`ext install vsls-contrib.gistfs`

The [marketplace docs](https://marketplace.visualstudio.com/items?itemName=vsls-contrib.gistfs) are a great place to start learning about what it can do.

**GistPad Interactive Playgrounds**

Another neat feature is interactive playgrounds which again the marketplace docs explain :

	If you're building web applications, and want to create a quick playground environment in order to experiment with HTML, CSS or JavaScript (or Sass/SCSS, Less, Pug and TypeScript), you can right-click the Your Gists node and select New Playground or New Secret Playground. This will create a new gist, seeded with an HTML, CSS and JavaScript file, and then provide you with a live preview Webview, so that you can iterate on the code and visually see how it behaves.

I am a big fan of [VueJS](https://vuejs.org) so I decided to spin up a new interactive playground choosing VueJS from the menu that appears.

That produces a nice hello world style template that you can use to get started with.

![2020-01-16_11-24-59_gistpad_playground.png]({{site.baseurl}}/media/2020-01-16_11-24-59_gistpad_playground.png)

**UK Police Data**

Rather than displaying weather data or some random dummy data in my playground, I decided to use crime data for Oxfordshire from [Data.Police.UK](https://data.police.uk/docs/) which seemed an interesting dataset to play around with.

I started by reading the docs and looking at the example request which takes pairs of lat/long coordinates to describe an area:

`https://data.police.uk/api/crimes-street/all-crime?poly=52.268,0.543:52.794,0.238:52.130,0.478&date=2017-01`

I then found [this site](https://www.doogal.co.uk/polylines.php) which allowed me to draw an area and then get those lat/lon coordinates.

Then looking at the sample JSON response back from the API I then had enough to get started on my VueJS GistPad Interactive Playground:

```json
[
    {
        "category": "anti-social-behaviour",
        "location_type": "Force",
        "location": {
            "latitude": "52.640961",
            "street": {
                "id": 884343,
                "name": "On or near Wharf Street North"
            },
            "longitude": "-1.126371"
        },
        "context": "",
        "outcome_status": null,
        "persistent_id": "",
        "id": 54164419,
        "location_subtype": "",
        "month": "2017-01"
    },
    {
        "category": "anti-social-behaviour",
        "location_type": "Force",
        "location": {
            "latitude": "52.633888",
            "street": {
                "id": 883425,
                "name": "On or near Peacock Lane"
            },
            "longitude": "-1.138924"
        },
        "context": "",
        "outcome_status": null,
        "persistent_id": "",
        "id": 54165316,
        "location_subtype": "",
        "month": "2017-01"
    },
    ...
]
```

**VueJS GistPad Interactive Playground**

Right-clicking in the GistPad tab in VSCode showed me a menu allowing me to create either a public or private interactive playground.

The generated template is plenty to get started with.

It gives you 3 files to edit and a preview pane that refreshes whenever you make a change which is an excellent developer inner loop.

So after some trial and error, these were my 3 files all [associated with a GitHub Gist](https://gist.github.com/solrevdev/41a7adb028bb10c741153f58b36d01fe)

{% gist 41a7adb028bb10c741153f58b36d01fe %}


**The end result**

The GistPad toolbar has an icon that allows you to open a console to view the output of your `console.log` statements and I soon had a working version.

If you would like to see my Police Data sample try this link:

[https://gist.github.com/solrevdev/41a7adb028bb10c741153f58b36d01fe](https://gist.github.com/solrevdev/41a7adb028bb10c741153f58b36d01fe)


If VueJS isn't your thing then react.js is an option and typescript versions of these two are also available.  

The extension is open for more templates to be added to it and can be submitted to them.

All in all, it's an excellent experience.

Success 🎉
