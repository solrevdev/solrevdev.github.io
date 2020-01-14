---
published: true
layout: post
title: 'Forcing HTTP to HTTPS redirect on IIS via Amazon Elastic Load Balancers'
author: John Smith
tags:
  - '#iis'
  - '#aws'
  - '#elb'
  - '#urlredirect'
  - '#webconfig'
---

Today I replaced an ageing asp.net web forms web application with a new static site which for now is just a landing page with a contact form and in doing so needed to force any insecure HTTP requests to HTTPS.

A bit of a gotcha was an error on the redirect and the issue was the `HTTP_X_FORWARDED_PROTO` header also needed to be forwarded along with the redirect.

For example :

```xml
<conditions logicalGrouping="MatchAny">
   <add input="{HTTP_X_FORWARDED_PROTO}" pattern="^http$" />
   <add input="{HTTPS}" pattern="on" />
</conditions>
```

Next up, I needed to redirect any users who were going to `.aspx` pages that no longer existed to a custom 404 HTML page not found page.

This just needed adding to `web.config` like so :

```xml
  <system.web>
      <compilation targetFramework="4.0" />
      <customErrors mode="On" redirectMode="ResponseRewrite">
         <error statusCode="404" redirect="404.html" />
      </customErrors>
   </system.web>

   <system.webServer>
      <httpErrors errorMode="Custom">
         <remove statusCode="404"/>
         <error statusCode="404" path="/404.html" responseMode="ExecuteURL"/>
      </httpErrors>
   </system.webServer>

```

So here it is for the next time I have to do something similar, This is the full `web.config` that needs to in the root folder of the site.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.web>
        <compilation targetFramework="4.0" />
        <customErrors mode="On" redirectMode="ResponseRewrite">
            <error statusCode="404" redirect="404.html" />
        </customErrors>
    </system.web>
    <system.webServer>
        <httpErrors errorMode="Custom">
            <remove statusCode="404"/>
            <error statusCode="404" path="/404.html" responseMode="ExecuteURL"/>
        </httpErrors>
        <rewrite>
            <rules>
                <rule name="HTTPS Rule behind AWS Elastic Load Balancer" stopProcessing="true">
                    <match url="(.*)" ignoreCase="false" />
                    <conditions logicalGrouping="MatchAny">
                        <add input="{HTTP_X_FORWARDED_PROTO}" pattern="^http$" />
                        <add input="{HTTPS}" pattern="on" />
                    </conditions>
                    <action type="Redirect" url="https://{HTTP_HOST}{REQUEST_URI}" redirectType="Found" />
                </rule>
            </rules>
        </rewrite>
    </system.webServer>
</configuration>
```

And to test that the site works I entered it onto [https://www.whynopadlock.com/](https://www.whynopadlock.com/) which gave me the confidence that all was well.


Done. 👍
