---
published: true
layout: post
title: Deploy ASP.NET Core Web API to Fly via Docker
description: How to deploy an ASP.NET Core Web API site to fly.io via Docker
tags:
  - dotnetcore
  - dotnet
  - blazor
  - flyio
  - docker
  - cors
---
In my [last post](https://solrevdev.com/2020/05/17/blazor-hosted-on-vercel-aka-zeit-now.html) I deployed the standard [Blazor template](https://docs.microsoft.com/en-us/aspnet/core/blazor/get-started?view=aspnetcore-3.1) over to [vercel static site hosting](https://vercel.com/).

In the standard template, the `FetchData` component gets its data from a local `sample-data/weather.json` file via an `HttpClient`.

```csharp
forecasts = await Http.GetFromJsonAsync<WeatherForecast[]>("sample-data/weather.json");
```

I wanted to upgrade this by replacing that call to the local json file with a call to an ASP.NET Core Web API backend.

Unfortunately unlike in the version 1 days of zeit where you could deploy Docker based apps to them vercel now offer [serverless functions](https://vercel.com/docs/v2/serverless-functions/introduction) instead but [do not support .NET](https://vercel.com/docs/v2/serverless-functions/supported-languages).

So, as an alternative, I looked at [fly.io](https://fly.io/docs/).

I first used them in 2017 before GitHub supported HTTPS/SSL for custom domains by [using them as middleware](2017-08-31-http-ssl-via-github-pages-with-flyio.md) to provide this service.

Since then they now support [deploying Docker based app servers](https://fly.io/docs/hands-on/start/) which works in pretty much the same way as zeit used to.

Perfect!

**Backend**

So, the plan was to create a backend to replace the weather.json file, deploy and host it via Docker on fly.io and point my vercel hosted blazor website to that!

First up I created a backend web API using the `dotnet new` template and added that to my solution.

Fortunately, the .NET Core Web API template comes out of the box with a `/weatherforecast` endpoint that returns the same shape data as the `sample_data/weather.json` file in the frontend.

```powershell
dotnet new webapi -n backend
dotnet sln add backend/backend.csproj
```

Next, I needed to tell my web API backend that another domain (my vercel hosted blazor app) would be connecting to it. This would fix any [CORS](https://docs.microsoft.com/en-us/aspnet/core/security/cors?view=aspnetcore-3.1) related error messages.

So in `backend/Program.cs`

```csharp
private readonly string _myAllowSpecificOrigins = "_myAllowSpecificOrigins";

public void ConfigureServices(IServiceCollection services)
{
    services.AddCors(options =>
    {
        options.AddPolicy(name: _myAllowSpecificOrigins,
                        builder =>
                        {
                            builder.WithOrigins("https://blazor.now.sh",
                                                "https://blazor.solrevdev.now.sh",
                                                "https://localhost:5001",
                                                "http://localhost:5000");
                        });
    });

    services.AddControllers();
}

// This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
{
    if (env.IsDevelopment())
    {
        app.UseDeveloperExceptionPage();
    }

    app.UseHttpsRedirection();

    app.UseRouting();

    app.UseCors(policy =>
                policy
                    .WithOrigins("https://blazor.now.sh",
                                    "https://blazor.solrevdev.now.sh",
                                    "https://localhost:5001",
                                    "http://localhost:5000")
                    .AllowAnyMethod()
                    .WithHeaders(HeaderNames.ContentType));

    app.UseAuthorization();

    app.UseEndpoints(endpoints => endpoints.MapControllers());
}
```

**Docker**

Now that the backend project is ready it was time to deploy it to [https://fly.io/](fly.io).

From a previous project, I already had a handy dandy working Dockerfile I could re-use so making sure I replaced the name of dotnet dll and ensured I was pulling a recent version of .NET Core SDK

`Dockerfile`

```Dockerfile
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
# update the debian based system
RUN apt-get update && apt-get upgrade -y
# install my dev dependacies inc sqllite and curl and unzip
RUN apt-get install -y sqlite3
RUN apt-get install -y libsqlite3-dev
RUN apt-get install -y curl
RUN apt-get install -y unzip
# not sure why im deleting these
RUN rm -rf /var/lib/apt/lists/*

# add debugging in a docker tooling - install the dependencies for Visual Studio Remote Debugger
RUN apt-get update && apt-get install -y --no-install-recommends unzip procps
# install Visual Studio Remote Debugger
RUN curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v latest -l ~/vsdbg
WORKDIR /app/web

# layer and build
COPY . .
WORKDIR /app/web
RUN dotnet restore

# layer adding linker then publish after tree shaking
FROM build AS publish
WORKDIR /app/web
RUN dotnet publish -c Release -o out

# final layer using smallest runtime available
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS runtime
WORKDIR /app/web
COPY --from=publish app/web/out ./

# expose port and execute aspnetcore app
EXPOSE 5000
ENV ASPNETCORE_URLS=http://+:5000
ENTRYPOINT ["dotnet", "backend.dll"]
```

The lines of code in that Dockerfile that were really important for fly.io to work were

```Dockerfile
EXPOSE 5000
ENV ASPNETCORE_URLS=http://+:5000
```

I also created a `.dockerignorefile`

```Dockerfile
bin/
obj/
```

I had already installed and authenticated the `flyctl` command-line tool, head over to [https://fly.io/docs/speedrun/](https://fly.io/docs/speedrun/) for a simple tutorial on how to get started.

After some trial and error and some fantastic help from support, I worked out that I needed to override the port that fly.io used so that it matched my .NET Core Web API project.

I created an app using port 5000 by first navigating into the backend project so that I was in the same location as the csproj file.

```powershell
cd backend
flyctl apps create -p 5000
```

You should find a new `fly.toml` file has been added to your project folder

```yml
app = "blue-dust-2805"

[[services]]
  internal_port = 5000
  protocol = "tcp"

  [services.concurrency]
    hard_limit = 25
    soft_limit = 20

  [[services.ports]]
    handlers = ["http"]
    port = "80"

  [[services.ports]]
    handlers = ["tls", "http"]
    port = "443"

  [[services.tcp_checks]]
    interval = 10000
    timeout = 2000
```

Make a mental note of the app name you will see it again in the final hostname, also note the port number that we overrode in the previous step.

Now to deploy the app…

```powershell
flyctl deploy
```

And get the deployed endpoint URL back to use in the front end…

```powershell
flyctl info
```

The `flyctl info` command will return a deployed endpoint along with a random hostname such as

```powershell
flyctl info
App
  Name = blue-dust-2805
  Owner = your fly username
  Version = 10
  Status = running
  Hostname = blue-dust-2805.fly.dev

Services
  PROTOCOL PORTS
  TCP 80 => 5000 [HTTP]
             443 => 5000 [TLS, HTTP]

IP Addresses
  TYPE ADDRESS CREATED AT
  v4 77.83.141.66 2020-05-17T20:49:30Z
  v6 2a09:8280:1:c3b:5352:d1d5:9afd:fb65 2020-05-17T20:49:31Z
```

Now that the app is deployed you can view it by taking the hostname `blue-dust-2805.fly.dev` and appending the weather forecast endpoint at the end.

For example [https://blue-dust-2805.fly.dev/weatherforecast](https://blue-dust-2805.fly.dev/weatherforecast)

If all has gone well you should see some random weather!

Login to you fly.io control panel to see some stats

![](https://i.imgur.com/1MyvTwn.png)

**Frontend**

Next up it was just a case of replacing the frontend’s call to the local json file with the backend endpoint.

```csharp
builder.Services.AddTransient(sp => new HttpClient { BaseAddress = new Uri("https://blue-dust-2805.fly.dev") });
```

A small change to the `FetchData.razor` page.

```csharp
protected override async Task OnInitializedAsync()
{
    _forecasts = await Http.GetFromJsonAsync<WeatherForecast[]>("weatherforecast");
}
```

Re-deploy that to vercel by navigating to the root of our solution and running the deploy.sh script or manually via

```powershell
cd ../../
dotnet publish -c Release
now --prod frontend/bin/Release/netstandard2.1/publish/wwwroot/
```

Test that everything has worked by navigating to the `FetchData` endpoint of our frontend. In my case [https://blazor.now.sh/fetchdata](https://blazor.now.sh/fetchdata)

![](https://i.imgur.com/OMSih22.png)

**GitHub Actions**

As a final nice to have fly.io have GitHub action we can use to [automatically build and deploy](https://fly.io/docs/app-guides/continuous-deployment-with-github-actions/) our Dockerfile based .NET Core Web API on each push or pull request to GitHub.

Create an auth token in your project

```powershell
cd backend
flyctl auth token
```

Go to your repository on GitHub and select Setting then to Secrets and create a secret called FLY\_API\_TOKEN with the value of the token we just created.

Next, create the file `.github/workflows/fly.yml`

```yml
name: Fly Deploy
on:
    push:
        branches:
            - master
            - release/*
    pull_request:
        branches:
            - master
            - release/*
env:
  FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
  FLY_PROJECT_PATH: backend
jobs:
  deploy:
      name: Deploy app
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v2
        - uses: superfly/flyctl-actions@1.0
          with:
            args: "deploy"
```

Notice that in that file we have told the GitHub action to use the `FLY_API_TOKEN` we just setup.

Also because my `fly.toml` is not in the solution root but in the backend folder I can tell fly to look for it by setting the environment variable `FLY_PROJECT_PATH`

```yml
FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
FLY_PROJECT_PATH: backend
```

Also, make sure the `fly.toml` is not in your .gitignore file.

And so with that, every time I accept a pull request or I push to master my backend will get deployed to fly.io!

![](https://i.imgur.com/LqxEeQ2.png)

The new code is up on GitHub at [https://github.com/solrevdev/blazor-on-vercel](https://github.com/solrevdev/blazor-on-vercel)

Success 🎉
