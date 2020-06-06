---
published: true
layout: post
title: Adding TypeScript to an existing aspnetcore project
description: How to add TypeScript to an ASP.NET Core Razor Pages site
tags:
  - typescript
  - aspnetcore
  - aspnet
  - dotnetcore
  - dotnet
  - vue
---

## Background

So, I have a small [ASP.NET Core Razor Pages](https://docs.microsoft.com/en-us/aspnet/core/razor-pages/?view=aspnetcore-3.1) application that I recently enhanced by adding [Vue](https://vuejs.org/) in the same way that I once would add [jQuery](https://jquery.com/) to an existing application to add some interactivity to an existing page.

Not all websites need to be [SPA's](https://en.wikipedia.org/wiki/Single-page_application) with full-on JavaScript frameworks and build processes and just like with jQuery back in the day I was able to add Vue by simply adding a `<script>` tag to my page.

```html
<environment include="Development">
    <script src="~/lib/vue/vue.js"></script>
</environment>
<environment exclude="Development">
    <script
        src="https://cdnjs.cloudflare.com/ajax/libs/vue/2.6.10/vue.min.js"
        asp-fallback-src="~/lib/vue/vue.min.js"
        asp-fallback-test="window.Vue"
        integrity="sha256-chlNFSVx3TdcQ2Xlw7SvnbLAavAQLO0Y/LBiWX04viY="
        crossorigin="anonymous">
    </script>
</environment>
```

The one issue I did have was that my accompanying code used the latest and greatest JavaScript features which ruled out the page working on some older browsers.

This needed fixing!

## TypeScript to the rescue

One of the reasons I prefer Vue over React and other JavaScript frameworks is that it's so easy to simply add Vue to an existing project without going all in.

You can add as little or as much as you want.

[TypeScript](https://www.typescriptlang.org/) I believe is similar in that you can add it bit by bit to a project.

And not only do you get type safety as a benefit but it can also transpile TypeScript to older versions of JavaScript.

Exactly what I wanted!

So for anyone else that wants to do the same and for future me wanting to know how to do this here we are!

### Install TypeScript NuGet package

First you need to install the [Microsoft.TypeScript.MSBuild ](https://www.nuget.org/packages/Microsoft.TypeScript.MSBuild/3.9.2?_src=template) nuget package into your ASP.NET Core website project.

This will allow you to build and transpile from your IDE, the command line or even a build server.

### Create tsconfig.json

Next up create a `tsconfig.json` file in the root of your website project. This tells the TypeScript compiler what to do and how to behave.

```json
{
    "compilerOptions": {
        "lib": ["DOM", "ES2015"],
        "target": "es5",
        "noEmitOnError": true,
        "strict": false,
        "module": "es2015",
        "moduleResolution": "node",
        "outDir": "wwwroot/js"
    },
    "include": ["Scripts/**/*"],
    "compileOnSave": true
}
```

- **target** : The target is es5 which is the JavaScript version I want to support and transpile down to.
- **noEmitOnError**: This will stop the script wiping any existing code if the TypeScript errors.
- **outDir**: I want the source TypeScript to put the JavaScript in the same place I was putting my original code
- **include**: This says take all the TypeScript in this folder and transpile into .js files of the same name into **outDir** above
- **compileOnSave**: This is a productivity booster!

### Create Folders

Now create a `Scripts` folder alongside `Pages` to store the TypeScript files.

### Create first TypeScript file

Add the following to `Scripts/site.ts` and then save the file to kick off the TypeScript compiler.

```typescript
export {};

if (window.console) {
    let message: string = 'site.ts > site.js > site.js.min';
    console.log(message);
}
```

### Save And Build!

If all has gone well there should be a `site.js` file in the `wwwroot\js` folder.

Now whenever the project is built every `.ts` file you add to `Scripts` will be transpiled to a file with the same name but with a `.js` extension in the `wwwroot\js` folder.

And best of all you should notice that it has taken the `let` keyword in the source TypeScript file and transpiled that to `var` in the destination site.js JavaScript file.

**Before**

```typescript
export {};

if (window.console) {
    let message: string = 'site.ts > site.js > site.js.min';
    console.log(message);
}
```

**After**

```javascript
if (window.console) {
    var message = 'site.ts > site.js > site.js.min';
    console.log(message);
}
```

## TypeScript with Vue, jQuery and Lodash

However, while site.js is a nice simple example, my project as I mentioned above uses Vue (and jQuery and Lodash) and if you try and build that with TypeScript you may get errors related to those external libraries.

One fix would be to import the types for those libraries however, I wanted to keep my project simple and do not want to try and import types for my external libraries.

So, the following example shows how to tell TypeScript that your code is using Vue, jQuery and Lodash while keeping the codebase light and not having to import any types.

You will not get full intellisense for these as TypeScript does not have the type definitions for them however you will not get any errors because of them.

That for me was fine.

```typescript
export { };

declare var Vue: any;
declare var _: any;
declare var $: any;

const app = new Vue({
  el: '#app',
  data: {
    message: 'Hello Vue!'
  },
  created: function () {
      const form = document.getElementById('form') as HTMLFormElement;
      const email = (document.getElementById('email') as HTMLInputElement).value;
      const button = document.getElementById('submit') as HTMLInputElement;
  },
});

$(document).ready(function () {
    setTimeout(function () {
        $(".jqueryExample").fadeTo(1000, 0).slideUp(1000, function () {
            $(this).remove();
        });
    }, 10000);
});
```

Another common error is that TypeScript may not know about HTML form elements.

As in the example above you can fix this by declaring your form variables as the relevant types.

In my case the common ones were `HTMLFormElement` and `HTMLInputElement`.

And that is it basically!

## More TypeScript?

So, for now, this is the right amount of TypeScript for my needs.

I did not have to bring too much ceremony to my application but I still get some type checking and more importantly I can code using the latest language features but still have JavaScript that works in older browsers.

If the project grows I will see how else I can improve it with TypeScript!

Success 🎉
