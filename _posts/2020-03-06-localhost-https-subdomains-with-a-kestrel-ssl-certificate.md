---
published: false
layout: post
title: localhost https subdomains with a kestrel ssl certificate
author: John Smith
tags:
  - dotnet
  - https
  - ssl
  - localhost
  - kestrel
---

When you build ASP.NET Core websites locally, you can view your local site under https/ssl, go read [this article](https://www.hanselman.com/blog/DevelopingLocallyWithASPNETCoreUnderHTTPSSSLAndSelfSignedCerts.aspx) by Scott Hanselman for more information.

For the most part this works great out of the box. 

However, I am building a multi-tenant application as in I make use of subdomains such as www.mywebsite.com and customer1.mywebsite.com. 

So naturally when I develop locally I want to visit https://www.localhost:5001 and https://customer1.localhost:5001/

Now you can do this out of the box you just need to add this to your hosts file.

```powershell
#macos / linux
cat /etc/hosts

127.0.0.1 www.localhost
127.0.0.1 customer1.localhost

#windows
type C:\Windows\System32\drivers\etc\hosts

127.0.0.1 www.localhost
127.0.0.1 customer1.localhost
```

However when you visit either `www.` or `customer1.` you will get an SSL cert warning from your browser as the SSL cert that kestrel and/or IISExpress uses only covers the apex localhost domain.

Yesterday I posted on [twitter asking for help](https://twitter.com/solrevdev/status/1235641092256784385) and the replies I got pointed me in the right direction.

### mkcert to the rescue

The answer is to use some software called [mkcert](https://github.com/FiloSottile/mkcert) to generate a `.pfx` certificate and configure kestrel to use this certificate when in development.

**Firstly off install mkcert**

```powershell
#macOS
brew install mkcert
brew install nss # if you use Firefox

#linux
sudo apt install libnss3-tools
    -or-
sudo yum install nss-tools
    -or-
sudo pacman -S nss
    -or-
sudo zypper install mozilla-nss-tools

brew install mkcert

#windows
choco install mkcert
scoop bucket add extras
scoop install mkcert
```

**Then create a new local certificate authority.**

```powershell
mkcert -install
Using the local CA at "/Users/solrevdev/Library/Application Support/mkcert" ✨
The local CA is already installed in the system trust store! 👍
The local CA is now installed in the Firefox trust store (requires browser restart)! 🦊
```

### Create .pfx certificate

**Now create your certificate covering the subdomains you want to use**

```powershell
#navigate to your website root
cd src/web/
#remove any earlier failed attempts!
rm kestrel.pfx
#create the cert adding each subdomain you want to use
mkcert -pkcs12 -p12-file kestrel.pfx www.localhost customer1.localhost localhost
#gives this output
Using the local CA at "/Users/solrevdev/Library/Application Support/mkcert" ✨

Created a new certificate valid for the following names 📜
 - "www.localhost"
 - "customer1.localhost"
 - "localhost"

The PKCS#12 bundle is at "kestrel.pfx" ✅

The legacy PKCS#12 encryption password is the often hardcoded default "changeit" ℹ️
```


**Now ensure you copy the `.pfx` file over when in development mode.**


*web.csproj*

```xml
 <ItemGroup Condition="'$(Configuration)' == 'Debug' ">
    <None Update="kestrel.pfx" CopyToOutputDirectory="PreserveNewest" Condition="Exists('kestrel.pfx')" />
  </ItemGroup>
```

**Now configure kestrel to use this certificate when in development not production**

You have two `appsettings` files, one for development and one for every other environment. Open up your development one and tell kestrel to use your newly created `pfx` file when not in production.

*appsettings.Development.json*

```json
{
    "Logging": {
        "LogLevel": {
            "Default": "Debug",
            "Microsoft": "Warning",
            "Microsoft.Hosting.Lifetime": "Warning"
        }
    },
    "Kestrel": {
        "Certificates": {
            "Default": {
                "Path": "kestrel.pfx",
                "Password": "changeit"
            }
        }
    }
}

```

And with that I was done. If you need to add more subdomains you will need to add them to your hosts file and recreate your pfx file by [redoing the instructions](#create-pfx-certificate) above.

Success 🎉