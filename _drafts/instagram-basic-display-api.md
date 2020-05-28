---
published: true
layout: post
title: Instagram Basic Display API
description: How to consume the Instagram Basic Display API using a dotnetcore netstandard2.0 library which is also on nuget
tags:
  - aspnetcore
  - dotnet
  - instagram
  - api
  - nuget
---

### Background

A while ago I was working on a project that consumed the [Instagram Legacy API Platform](https://www.instagram.com/developer/).

![](https://i.imgur.com/PHCXZXK.png)

To make things easier there was fantastic library called [InstaSharp](http://instasharp.github.io/InstaSharp/) which wrapped the HTTP calls to the Instagram Legacy API endpoints.

![](https://i.imgur.com/YgLkx4K.png)

However, Instagram began disabling the [Instagram Legacy API Platform](https://www.instagram.com/developer/) and on June 29, 2020 any remaining endpoints will no longer be available.

The replacements to the [Instagram Legacy API Platform](https://www.instagram.com/developer/) are the [Instagram Graph API](https://developers.facebook.com/docs/instagram-graph-api) and the [Instagram Basic Display API](https://developers.facebook.com/docs/instagram-basic-display-api).

So, If my project was to continue to work I needed to migrate over to the [Instagram Basic Display API](https://developers.facebook.com/docs/instagram-basic-display-api) before the deadline.

I decided to build and release an open source library, A  wrapper around the [Instagram Basic Display API](https://developers.facebook.com/docs/instagram-basic-display-api) in the same way as [InstaSharp](http://instasharp.github.io/InstaSharp/) did for the original.

### Solrevdev.InstagramBasicDisplay

And so began [Solrevdev.InstagramBasicDisplay](https://github.com/solrevdev/instagram-basic-display),  a [netstandard2.0](https://docs.microsoft.com/en-us/dotnet/standard/net-standard) library that consumes the new [Instagram Basic Display API](https://developers.facebook.com/docs/instagram-basic-display-api/).

![](https://i.imgur.com/Te7DLdK.png)

It is also available on [nuget](https://www.nuget.org/packages/Solrevdev.InstagramBasicDisplay/) so you can add this functionality to your own .NET projects.

![](https://i.imgur.com/FWeRqgo.png)

### Getting Started

Before you begin you will need to create an Instagram  `client_id` and `client_secret` by creating a Facebook app and configuring it so that it knows your ***https only*** `redirect_url`.

### Facebook and Instagram Setup ![instagram logo](https://i.imgur.com/gFDtvYe.png)

Before you begin you will need to create an Instagram  `client_id` and `client_secret` by creating a Facebook app and configuring it so that it knows your `redirect_url`. There are full [instructions here](https://developers.facebook.com/docs/instagram-basic-display-api/getting-started).

#### Step 1 - Create a Facebook App

Go to [developers.facebook.com](https://developers.facebook.com), click **My Apps**, and create a new app. Once you have created the app and are in the App Dashboard, navigate to **Settings > Basic**, scroll the bottom of page, and click **Add Platform**.

![Step 1a - Create a Facebook App](https://i.imgur.com/kgnGHkv.png)

Choose **Website**, add your website's URL, and save your changes. You can change the platform later if you wish, but for this tutorial, use **Website**

![Step 1b - Create a Facebook App](https://i.imgur.com/1BFpWpQ.png)

#### Step 2 - Configure Instagram Basic Display

Click **Products**, locate the **Instagram** product, and click **Set Up** to add it to your app.

![Step 2a - Configure Instagram Basic Display](https://i.imgur.com/6sK3tkC.png)

Click **Basic Display**, scroll to the bottom of the page, then click **Create New App**.

![Step 2b - Configure Instagram Basic Display](https://i.imgur.com/Nq6V25f.png)

In the form that appears, complete each section using the guidelines below.

**Display Name**
Enter the name of the Facebook app you just created.

**Valid OAuth Redirect URIs**
Enter <https://localhost:5001/auth/oauth/> for your `redirect_url` that will be used later. **HTTPS must be used on all redirect urls**

**Deauthorize Callback URL**
Enter <https://localhost:5001/deauthorize>

**Data Deletion Request Callback URL**
Enter <https://localhost:5001/datadeletion>

**App Review**
Skip this section for now since this is just a demo.

#### Step 3 - Add an Instagram Test User

Navigate to **Roles > Roles** and scroll down to the **Instagram Testers section**. Click **Add Instagram Testers** and enter your Instagram account's username and send the invitation.

![Step 3a - Add an Instagram Test User](https://i.imgur.com/UWPx2NK.png)

Open a new web browser and go to [www.instagram.com](https://www.instagram.com/) and sign into your Instagram account that you just invited. Navigate to **(Profile Icon) > Edit Profile > Apps and Websites > Tester Invites** and accept the invitation.

![Step 3b - Add an Instagram Test User](https://i.imgur.com/Z25fBaq.png)

You can view these [invitations and applications](https://www.instagram.com/accounts/manage_access/) by navigating to **(Profile Icon) > Edit Profile > Apps and Websites**

![Step 3c - Add an Instagram Test User](https://i.imgur.com/oFqXPEG.png)

### Facebook and Instagram Credentials

Navigate to **My Apps > Your App Name > Basic Display**

![Navigate to My App](https://i.imgur.com/YoI2Wrm.png)

Make a note of the following Facebook and Instagram credentials:

**Instagram App ID**
This is going to be known as `client_id` later

**Instagram App Secret**
This is going to be known as `client_secret` later

**Client OAuth Settings > Valid OAuth Redirect URIs**
This is going to be known as `redirect_url` later

![Facebook and Instagram Credentials](https://i.imgur.com/k5H2JSN.png) *[go here for a full size screenshot](https://i.imgur.com/bSHOS5p.png)*

### User Token Generator

The Instagram User Token Generator is a tool you can use to quickly generate [long-lived Instagram User Access Tokens](https://developers.facebook.com/docs/instagram-basic-display-api/overview#instagram-user-access-tokens) for any of your public Instagram accounts. This is useful if you're testing your app and don't want to bother with implementing the [Authorization Window](https://developers.facebook.com/docs/instagram-basic-display-api/overview#authorization-window).

The tool works by triggering the Authorization Window, which you can sign into with a public Instagram account that you have designated as a [tester account](https://developers.facebook.com/docs/instagram-basic-display-api/overview#instagram-testers). After signing in, the tool will generate a long-lived access token that you can copy and paste. Note that tokens can only be generated for public Instagram accounts.

You can access the token generator in the **App Dashboard > Products > Instagram > Basic Display** tab.

![User Token Generator](https://i.imgur.com/ToqSQr7.png)

### Installation

To install via [nuget](https://www.nuget.org/packages/Solrevdev.InstagramBasicDisplay/) using the dotnet cli

```bash
dotnet add package Solrevdev.InstagramBasicDisplay
```

To install via [nuget](https://www.nuget.org/packages/Solrevdev.InstagramBasicDisplay/) using Visual Studio / Powershell

```powershell
Install-Package Solrevdev.InstagramBasicDisplay
```


### App Configuration

In your [.NET Core](https://docs.microsoft.com/en-us/dotnet/core/about) library or application create an `appsettings.json` file if one does not already exist and fill out the `InstagramSettings` section with your Instagram credentials such as client_id, client_secret and redirect_url as mentioned above.

**appsettings.json**

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft": "Warning",
      "Microsoft.Hosting.Lifetime": "Information"
    }
  },
  "AllowedHosts": "*",
  "InstagramCredentials": {
    "Name": "friendly name or your app name can go here - this is passed to Instagram as the user-agent",
    "ClientId": "client-id",
    "ClientSecret": "client-secret",
    "RedirectUrl": "https://localhost:5001/auth/oauth"
  }
}
```

### Common Uses

**Get an Instagram User Access Token and permissions from an Instagram user**

First, you send the user to Instagram to authenticate using the `Authorize` method, they will be redirected to the `RedirectUrl` set in `InstagramCredentials` so ensure that is set-up correctly in the Instagram app settings page.

Instagram will redirect the user on a successful login to the `RedirectUrl` page you configured in `InstagramCredentials` and this is where you can call `AuthenticateAsync` which exchanges the [Authorization Code](https://developers.facebook.com/docs/instagram-basic-display-api/overview#authorization-codes) for a [short-lived Instagram user access token](https://developers.facebook.com/docs/instagram-basic-display-api/overview#instagram-user-access-tokens) or optionally a [long-lived Instagram user access token](https://developers.facebook.com/docs/instagram-basic-display-api/guides/long-lived-access-tokens#get-a-long-lived-token).

You then have access to an `OAuthResponse` which contains your [access token](https://developers.facebook.com/docs/instagram-basic-display-api/reference/access_token) and a [user](https://developers.facebook.com/docs/instagram-basic-display-api/reference/user) which can be used to make further API calls.

```csharp
private readonly InstagramApi _api;

public IndexModel(InstagramApi api)
{
    _api = api;
}

public ActionResult OnGet()
{
    var url = _api.Authorize("anything-passed-here-will-be-returned-as-state-variable");
    return Redirect(url);
}
```

Then in your `RedirectUrl` page

```csharp
private readonly InstagramApi _api;
private readonly ILogger<IndexModel> _logger;

public IndexModel(InstagramApi api, ILogger<IndexModel> logger)
{
    _api = api;
    _logger = logger;
}

// code is passed by Instagram, the state is whatever you passed in _api.Authorize sent back to you
public async Task<IActionResult> OnGetAsync(string code, string state)
{
    // this returns an access token that will last for 1 hour - short-lived access token
    var response = await _api.AuthenticateAsync(code, state).ConfigureAwait(false);

    // this returns an access token that will last for 60 days - long-lived access token
    // var response = await _api.AuthenticateAsync(code, state, true).ConfigureAwait(false);

    // store in session - see System.Text.Json code below for sample
    HttpContext.Session.Set("Instagram.Response", response);
}
```

If you want to store the `OAuthResponse` in `HttpContext.Session` you can use the new `System.Text.Json` namespace like this

```csharp
using System.Text.Json;
using Microsoft.AspNetCore.Http;
public static class SessionExtensions
{
    public static void Set<T>(this ISession session, string key, T value)
    {
        session.SetString(key, JsonSerializer.Serialize(value));
    }

    public static T Get<T>(this ISession session, string key)
    {
        var value = session.GetString(key);
        return value == null ? default : JsonSerializer.Deserialize<T>(value);
    }
}
```

**Get an Instagram user's profile**

```csharp
private readonly InstagramApi _api;
private readonly ILogger<IndexModel> _logger;

public IndexModel(InstagramApi api, ILogger<IndexModel> logger)
{
    _api = api;
    _logger = logger;
}

// code is passed by Instagram, the state is whatever you passed in _api.Authorize sent back to you
public async Task<IActionResult> OnGetAsync(string code, string state)
{
    // this returns an access token that will last for 1 hour - short-lived access token
    var response = await _api.AuthenticateAsync(code, state).ConfigureAwait(false);

    // this returns an access token that will last for 60 days - long-lived access token
    // var response = await _api.AuthenticateAsync(code, state, true).ConfigureAwait(false);

    // store and log
    var user = response.User;
    var token = response.AccessToken;

    _logger.LogInformation("UserId: {userid} Username: {username} Media Count: {count} Account Type: {type}", user.Id, user.Username, user.MediaCount, user.AccountType);
    _logger.LogInformation("Access Token: {token}", token);
}
```

**Get an Instagram user's images, videos, and albums**

```csharp
private readonly InstagramApi _api;
private readonly ILogger<IndexModel> _logger;

public List<Media> Media { get; } = new List<Media>();

public IndexModel(InstagramApi api, ILogger<IndexModel> logger)
{
    _api = api;
    _logger = logger;
}

// code is passed by Instagram, the state is whatever you passed in _api.Authorize sent back to you
public async Task<IActionResult> OnGetAsync(string code, string state)
{
    // this returns an access token that will last for 1 hour - short-lived access token
    var response = await _api.AuthenticateAsync(code, state).ConfigureAwait(false);

    // this returns an access token that will last for 60 days - long-lived access token
    // var response = await _api.AuthenticateAsync(code, state, true).ConfigureAwait(false);

    // store and log
    var media = await _api.GetMediaListAsync(response).ConfigureAwait(false);

    _logger.LogInformation("Initial media response returned with [{count}] records ", media.Data.Count);

    _logger.LogInformation("First caption: {caption}, First media url: {url}",media.Data[0].Caption, media.Data[0].MediaUrl);

    //
    //  toggle the following boolean for a quick and dirty way of getting all a user's media.
    //
    if(false)
    {
        while (!string.IsNullOrWhiteSpace(media?.Paging?.Next))
        {
            var next = media?.Paging?.Next;
            var count = media?.Data?.Count;
            _logger.LogInformation("Getting next page [{next}]", next);

            media = await _api.GetMediaListAsync(next).ConfigureAwait(false);

            _logger.LogInformation("next media response returned with [{count}] records ", count);

            // add to list
            Media.Add(media);
        }

        _logger.LogInformation("The user has a total of {count} items in their Instagram feed", Media.Count);
    }
}
```

**Exchange a short-lived access token for a long-lived access token**

```csharp
private readonly InstagramApi _api;
private readonly ILogger<IndexModel> _logger;

public IndexModel(InstagramApi api, ILogger<IndexModel> logger)
{
    _api = api;
    _logger = logger;
}

// code is passed by Instagram, the state is whatever you passed in _api.Authorize sent back to you
public async Task<IActionResult> OnGetAsync(string code, string state)
{
    // this returns an access token that will last for 1 hour - short-lived access token
    var response = await _api.AuthenticateAsync(code, state).ConfigureAwait(false);
    _logger.LogInformation("response access token {token}", response.AccessToken);

    var longLived = await _api.GetLongLivedAccessTokenAsync(response).ConfigureAwait(false);
    _logger.LogInformation("longLived access token {token}", longLived.AccessToken);
}
```

**Refresh a long-lived access token for another long-lived access token**

```csharp
private readonly InstagramApi _api;
private readonly ILogger<IndexModel> _logger;

public IndexModel(InstagramApi api, ILogger<IndexModel> logger)
{
    _api = api;
    _logger = logger;
}

// code is passed by Instagram, the state is whatever you passed in _api.Authorize sent back to you
 public async Task<IActionResult> OnGetAsync(string code, string state)
{
    // this returns an access token that will last for 1 hour - short-lived access token
    var response = await _api.AuthenticateAsync(code, state).ConfigureAwait(false);
    _logger.LogInformation("response access token {token}", response.AccessToken);

    var longLived = await _api.GetLongLivedAccessTokenAsync(response).ConfigureAwait(false);
    _logger.LogInformation("longLived access token {token}", longLived.AccessToken);

    var another = await _api.RefreshLongLivedAccessToken(response).ConfigureAwait(false);
    _logger.LogInformation("response access token {token}", another.AccessToken);
}
```

### Start kestrel web server

**First navigate to the directory this `readme.md` file is in.**

```bash
cd path/to/samples/Web/
```

**Run `dotnet` on port 5001**

```powershell
dotnet run
```

or

```powershell
dotnet watch run
```

### Open page

e.g `https://localhost:5001/` which will serve the razor page from the samples/Web folder over https which is required by the Facebook app.


Success 🎉
