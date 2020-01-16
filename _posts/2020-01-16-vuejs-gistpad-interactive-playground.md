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
Recently I installed a VS Code extension called [GistPad](https://marketplace.visualstudio.com/items?itemName=vsls-contrib.gistfs) which from the marketplace docs says:

	GistPad is a Visual Studio Code extension that allows you to manage GitHub Gists entirely within the editor. You can open, create, delete, fork, star and clone gists, and then seamlessly begin editing files as if they were local.

It is a great extension and I am using Gists way more now. 

**Install**

To install launch VS Code Quick Open (<kbd>Ctrl</kbd>+<kbd>P</kbd>), paste the following command, and press enter.

`ext install vsls-contrib.gistfs`

The [marketplace docs](https://marketplace.visualstudio.com/items?itemName=vsls-contrib.gistfs) are a great place to start reading up about it.

**GistPad Interactive Playgrounds**

Another neat feature is the interactive playgrounds which again from the marketplace docs explain :

	If you're building web applications, and want to create a quick playground environment in order to experiment with HTML, CSS or JavaScript (or Sass/SCSS, Less, Pug and TypeScript), you can right-click the Your Gists node and select New Playground or New Secret Playground. This will create a new gist, seeded with an HTML, CSS and JavaScript file, and then provide you with a live preview Webview, so that you can iterate on the code and visually see how it behaves.

I am a big fan of VueJS so I decided to spin up a new interactive playground choosing VueJS from the menu that appears.

There is a nice hello world style template that you can use to get started with.

**UK Police Data**

Rather than displaying weather data or random data, I decided to use crime data for Oxfordshire from [Data.Police.UK](https://data.police.uk/docs/) which seemed an interesting dataset to play around with.

I started by reading the docs and looking the example request which takes pairs of lat/long coordinates to describe an area:

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

The template is plenty to get started with.

It gives you 3 files to edit and preview pane that refreshes whenever you make a change which is an excellent developer inner loop.

![2020-01-16_11-23-46_gistpad.png]({{site.baseurl}}/media/2020-01-16_11-23-46_gistpad.png)

![2020-01-16_11-24-59_gistpad_playground.png]({{site.baseurl}}/media/2020-01-16_11-24-59_gistpad_playground.png)

So after some trial and error, these were my 3 files all [associated with a GitHub Gist](https://gist.github.com/solrevdev/41a7adb028bb10c741153f58b36d01fe)

**index.html**

```html
<div id="app">
    <h2>Police data for Oxfordshire</h2>
    <p>Using data from <a href="https://data.police.uk/docs/method/crime-street/">https://data.police.uk/docs/method/crime-street/</a></p>
    <p>Built using <a href="https://vuejs.org/">vue.js</a> and <a href="https://marketplace.visualstudio.com/items?itemName=vsls-contrib.gistfs">gistpad</a></p>
    <p>Dataset source <a href="https://data.police.uk/api/crimes-street/all-crime?poly=51.85110973276099,%20-1.4057047320491165:51.86298424914946,%20-1.1282999468928665:51.71262569681858,%20-1.1241800738459915:51.70241375059155,%20-1.3905985308772415:51.850261433101906,%20-1.4043314410334915">https://data.police.uk/api/crimes-street/all-crime?poly=51.85110973276099,%20-1.4057047320491165:51.86298424914946,%20-1.1282999468928665:51.71262569681858,%20-1.1241800738459915:51.70241375059155,%20-1.3905985308772415:51.850261433101906,%20-1.4043314410334915</a></p>
    <p>Sample data: <a href="sample.json">sample.json</a></p>
    <button @click="clearData">Clear data</button>
    <button @click="loadData">Fetch data</button>
    <hr>
    <div id="records" v-for="record in records" key="record.id">
        <p>[{{record.month}}] | {{record.category}} | {{record.location.street.name}}<span v-if="record.outcome_status != null">| {{record.outcome_status}}</span> </p>
    </div>
</div>
```

**style.css**

```css
body {
    font-family: Arial, Helvetica, sans-serif;
    background-color: #eee
}
```

**script.js**

```javascript
new Vue({
    el: "#app",
    data: {
        records : []
    },
    methods: {
        async loadData() {
            console.clear();
            const json = await this.fetchData();
            this.records = json;
            console.log(this.records[0]);
        },
        async fetchData() {
            const response = await fetch("https://data.police.uk/api/crimes-street/all-crime?poly=51.85110973276099,%20-1.4057047320491165:51.86298424914946,%20-1.1282999468928665:51.71262569681858,%20-1.1241800738459915:51.70241375059155,%20-1.3905985308772415:51.850261433101906,%20-1.4043314410334915");
            const json = response.json();
            return json;
        },
        clearData() {
            console.clear();
            const records = document.getElementById("records");
            if(records) {
                records.innerHTML = "";
            }
        }
    }
});
```

**The end result**

The GistPad toolbar has an icon that allows you to open a console to view the output of your `console.log` statements and I soon had a working version.

If you would like to see my Police Data sample try this link:

[https://gist.github.com/solrevdev/ffeea859dc82ebb95636cb13833c050b](https://gist.github.com/solrevdev/ffeea859dc82ebb95636cb13833c050b)

{% gist ffeea859dc82ebb95636cb13833c050b %}


All in all, it's an excellent experience.

If VueJS isn't your thing then react and typescript versions of these are available and it's open for more templates to be submitted to them.

Success 🎉
