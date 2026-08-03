---
published: false
layout: post
title: Building orchat - A Single File .NET Client for OpenRouter
description: How I built orchat, a .NET 10 file-based app with no project file and no NuGet packages, that streams chat from any of OpenRouter's 337 models, browses the catalogue by price, and reports what every turn cost.
summary: An OpenRouter email warning me that unused credits expire turned into a 300 line single-file .NET app. Covers .NET 10 file-based apps, streaming chat completions over server-sent events, reading per-token costs back from the API, browsing 337 models by price, why the obvious usage endpoint reports the wrong number, storing the API key in the macOS keychain, and publishing the whole thing as a 5.4 MB native binary.
cover_image: /images/orchat-openrouter-cover.svg
image: /images/orchat-openrouter-cover.png
tags:
- dotnet
- dotnet-10
- csharp
- file-based-apps
- single-file
- openrouter
- llm
- ai
- ai-agents
- cli
- native-aot
- macos
- keychain

---
**Overview** ☀

OpenRouter emailed me to say my credits were about to expire. I had bought $10 in March 2024, spent seven pence of it, and forgotten the account existed. Credits older than twelve months expire if the account sees no activity, and running any inference resets the clock.

Easy enough. Send a request, keep the money. Except I could not prove it worked. The dashboard rounds every figure to two decimal places, and a request big enough to keep an account alive costs about $0.0002. Every screen I looked at said $0.00, both before and after.

So I wrote a client. It ended up being more interesting than the problem that prompted it, because two things landed at once: .NET 10 lets you run a `.cs` file with no project around it, and OpenRouter puts every model worth trying behind one API and one key. Put those together and a usable chat client with model browsing and cost reporting is about 300 lines in a single file you can email to someone.

It is called `orchat` and the whole thing is on GitHub at [solrevdev/solrevdev.orchat](https://github.com/solrevdev/solrevdev.orchat).

This post is about that file. I have written about [.NET global tools](https://solrevdev.com/2025/10/27/building-ytx-a-youtube-transcript-extractor-as-a-dotnet-global-tool.html) and [.NET 10](https://solrevdev.com/2025/11/14/upgrading-seedfolder-to-dotnet-10-lts.html) before. This is the other end of the scale: the smallest thing that is still a real application.

**A Single File, No Project** 📄

.NET 10 runs a loose `.cs` file:

```bash
dotnet run orchat.cs
```

No `.csproj`. No `obj` folder in sight. No `dotnet new`. The SDK compiles the file to a cache directory and runs it. Check you are on 10 or later first, because this does not exist before then:

```bash
dotnet --version
```

Top-level statements do the heavy lifting. The file opens with `using` directives and then just starts doing things:

```csharp
const string Base = "https://openrouter.ai/api/v1";

var key = Environment.GetEnvironmentVariable("OPENROUTER_API_KEY");
if (string.IsNullOrWhiteSpace(key))
{
    Console.Error.WriteLine("Set OPENROUTER_API_KEY first.");
    return 1;
}
```

Local functions can follow the statements, and type declarations go at the end. So the whole program reads top to bottom: setup, the main loop, then the functions it calls, then a `record` at the bottom.

Three things surprised me about how far this scales.

**You can add NuGet packages.** A directive at the top of the file pulls a package, no project required:

```csharp
#:package Humanizer@2.14.1
using Humanizer;
Console.WriteLine(TimeSpan.FromMinutes(90).Humanize());   // "1 hour"
```

I did not use it. Everything `orchat` needs is in the shared framework, and I wanted the file to stay copy-and-paste portable. But the ceiling is a lot higher than "toy script".

**It can be its own command.** Put a shebang on line one, mark it executable, and the source file becomes the program:

```csharp
#!/usr/bin/env dotnet
```

```bash
chmod +x orchat.cs
./orchat.cs
```

The compiler ignores that line, so `dotnet run`, `dotnet build` and `dotnet publish` all carry on working.

**There is a way out.** If it outgrows one file, you are not stuck rewriting the scaffolding by hand:

```bash
dotnet project convert orchat.cs --dry-run
dotnet project convert orchat.cs
```

That last one matters more than it sounds. The usual objection to scripts is that they become load-bearing and then you are trapped. Here the exit is one command and it keeps your code.

**What orchat Does** 🎯

It is a chat client that keeps the whole thread in memory, and a model browser.

```
> what is the difference between a record and a class in C#?
Records are reference types with value-based equality...
[26 in / 180 out, $0.002784, 2.1s, session $0.0028]

> now show me when that equality actually bites
```

The second question sees the first exchange. Every turn sends the system prompt plus the entire conversation, so follow-ups work the way you would want. Nothing is trimmed or summarised, which keeps the context honest at the cost of a bill that grows with the thread. The `in` count on the stats line is that growth, in public.

The commands are deliberately few:

```
/model <id>              switch model
/models [filter|free]    browse the catalogue
/models use 12           switch to row 12
/key                     usage for this key
/cost                    what this session has spent
/system <text>           replace the system prompt
/reset                   clear the thread, keep the model
/save [file]             write the thread to markdown
/exit
```

**Talking to OpenRouter** 🔌

OpenRouter's API is the OpenAI chat completions shape, so there is nothing exotic to learn. One base URL, one bearer token, and the model as a string in the body:

```csharp
var http = new HttpClient { Timeout = TimeSpan.FromMinutes(10) };
http.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", key);
http.DefaultRequestHeaders.Add("HTTP-Referer", "https://solrevdev.com");
http.DefaultRequestHeaders.Add("X-Title", "orchat");
```

Those last two headers are OpenRouter specific and optional. They attribute the traffic to your app on their rankings page. Worth setting.

The value here is that `anthropic/claude-sonnet-4.5`, `openai/gpt-oss-20b:free` and three hundred others are the same call with a different string. No SDK per vendor, no separate key per vendor, no separate billing relationship per vendor. For trying things out, that is the whole pitch.

**Streaming, and Getting the Bill** 💸

Two flags in the request body do the interesting work:

```csharp
var body = new JsonObject
{
    ["model"] = model,
    ["messages"] = messages,
    ["stream"] = true,
    ["usage"] = new JsonObject { ["include"] = true }
};
```

`stream` gives you server-sent events. `usage.include` makes OpenRouter append a usage block to the final event, with the actual cost of that request. Not an estimate from a price card. What you were charged.

Reading it back is a loop over lines. Anything that is not a `data:` line is noise, and `[DONE]` ends it:

```csharp
using var res = await http.SendAsync(req, HttpCompletionOption.ResponseHeadersRead);
using var stream = await res.Content.ReadAsStreamAsync();
using var reader = new StreamReader(stream);

while (await reader.ReadLineAsync() is { } chunk)
{
    if (!chunk.StartsWith("data: ")) continue;
    var data = chunk[6..];
    if (data == "[DONE]") break;

    JsonNode? node;
    try { node = JsonNode.Parse(data); }
    catch { continue; }
    if (node is null) continue;

    var delta = node["choices"]?[0]?["delta"]?["content"]?.GetValue<string>();
    if (!string.IsNullOrEmpty(delta))
    {
        Console.Write(delta);
        sb.Append(delta);
    }

    var usage = node["usage"];
    if (usage is not null)
        cost = usage["cost"]?.GetValue<double>() ?? 0;
}
```

`HttpCompletionOption.ResponseHeadersRead` is the line that makes it stream rather than buffer. Without it you wait for the whole response and then print it all at once, which defeats the point.

The `try`/`catch` around the parse is not defensive padding. OpenRouter sends comment lines and keep-alives during long generations, and a strict parser will fall over on them.

That cost figure is what makes the tool worth keeping. After every turn:

```
[26 in / 180 out, $0.002784, 2.1s, session $0.0028]
```

Six decimal places, because two is useless at these amounts. When you are comparing a frontier model against something a tenth of the price, seeing the real number after each answer changes which one you reach for.

**Browsing the Catalogue** 🔍

`GET /api/v1/models` is public and needs no key. It returns everything OpenRouter can route to, currently 337 models, with pricing, context length and a description.

`/models` sorts by output price, cheapest first, and numbers the rows so you can act on them:

```
  1. cohere/north-mini-code:free                    256k  free
  2. google/gemma-4-26b-a4b-it:free                 262k  free
 ...
 14. openai/gpt-oss-20b:free                        131k  free
```

Then `/models use 14` switches to it. `/models claude` filters by substring, `/models free` shows only the zero-priced ones, and `/models 14` prints the full detail for one row. The catalogue is fetched once and cached for the session, so browsing costs nothing after the first call.

One trap worth knowing if you write something similar. Pricing comes back as strings, mostly:

```json
"pricing": { "prompt": "0.000003", "completion": "0.000015" }
```

Mostly. Some entries omit pricing, and some quote it as a number. `GetValue<string>()` throws on a number rather than converting, so a naive parser takes the whole listing down over one odd row. Check the kind first:

```csharp
static double Price(JsonNode? n) => n?.GetValueKind() switch
{
    JsonValueKind.String => double.TryParse(n.GetValue<string>(), out var v) ? v : 0,
    JsonValueKind.Number => n.GetValue<double>(),
    _ => 0
};
```

Same for `context_length`, which is missing on a few entries. This is the sort of thing that never shows up against a mock and always shows up against the real catalogue.

**Free Models, and Why They Did Not Help** 🆓

OpenRouter carries a genuine free tier. Models with a `:free` suffix cost nothing, currently seventeen of them, rate limited but real. For a chat client that is a gift.

For my actual problem it was useless. A free call spends nothing, so there is no charge, so it may not count as the billable activity that resets credit expiry. If you are keeping an account alive, use a paid model. A request costing a fraction of a penny is the entire point.

The free list also churns hard. Endpoints get delisted and added constantly, so never hard-code a `:free` id into anything scheduled. Ask the catalogue what is free today.

**Where the Usage Actually Lives** 🔎

This is the part that cost me the most time, and it is the reason the post exists.

The obvious endpoint is `GET /api/v1/key`. It returns your usage, and `orchat` prints it:

```
Key 'unnamed': $0.023808 used all time, $9.976192 left on this key.
  today $0.023808   this week $0.023808   this month $0.023808
  free tier: false
```

`usage_daily`, `usage_weekly` and `usage_monthly` are all in that one response, at full precision, which is exactly what the dashboard hides.

The catch: **it reports usage for that one key, not for the account.** I had generated a fresh key for the tool. It read zero all-time while my account had spent $0.069 since 2024. Nothing I had done in the web chat room appeared, because that was a different key. Those zeros meant nothing at all about whether the account was alive, and I spent a while believing they did.

The account-level answer is a different endpoint:

```bash
curl -s -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  https://openrouter.ai/api/v1/credits
```

```json
{ "data": { "total_credits": 10, "total_usage": 0.069429591 } }
```

Nine decimal places. That is the number the dashboard rounds to $9.93 and refuses to elaborate on.

The method that finally settled it was a before-and-after delta. Snapshot `total_usage`, send one small paid request, wait a minute or two for OpenRouter to aggregate, snapshot again:

```
before   total_usage  0.069429591
after    total_usage  0.092981691
```

The rise matched the cost the API had reported for the requests, to the sixth decimal. Timer reset, proven, for about two pence.

The aggregation lag is worth flagging. A reading taken immediately after a request still shows zero. It took between one and two minutes to appear. I nearly concluded the whole thing had failed on the strength of a reading taken five seconds too early.

**Keeping the Key Out of the Repo** 🔐

The app reads `OPENROUTER_API_KEY` from the environment and nowhere else. No config file, no `.env`, nothing to accidentally commit.

That leaves the question of where the key lives. On macOS the answer is already installed:

```bash
security add-generic-password -a "$USER" -s OPENROUTER_API_KEY -w
```

Leave the value off the end and it prompts, twice, echoing nothing. The key never touches your shell history or your scrollback. Read it back for exactly one command:

```bash
OPENROUTER_API_KEY=$(security find-generic-password -s OPENROUTER_API_KEY -w) dotnet run orchat.cs
```

Encrypted at rest, no dependency, works from `cron` and `launchd`. I now use this for every local tool secret.

I did consider `dotnet user-secrets` and rejected it. It needs a package and a `UserSecretsId`, it ties a secret to one project, and Microsoft's own documentation says it does not encrypt anything and should not be treated as a trusted store. It is a `.env` file with more steps.

Because the store differs by platform, `orchat` ships two small launchers rather than making that command a thing you retype. `orchat.sh` tries the environment, then `security`, then `secret-tool` on Linux. `orchat.ps1` tries the environment, then PowerShell SecretManagement, then the native stores. Both check the SDK version and say something useful when it is too old.

**Publishing a Native Binary** 📦

The last trick. A file-based app publishes:

```bash
dotnet publish orchat.cs -o ./dist
./dist/orchat
```

That compiles ahead of time to native code. On my arm64 Mac the result is a 5.4 MB self-contained executable with no runtime to install, and it starts in 117 ms against 685 ms for `dotnet run orchat.cs`. Same work, including a network call, so that gap is build-and-launch overhead the binary does not carry.

Native compilation is also the reason I care about two warnings that looked cosmetic. The first draft built the request like this:

```csharp
var messages = new JsonArray { new JsonObject { ["role"] = "system", ["content"] = system } };
```

That binds to `JsonArray.Add<T>`, which raises `IL2026` and `IL3050`: not trim safe, not AOT safe. It runs fine under `dotnet run`. Published as a native binary it would have compiled cleanly and then failed at runtime the first time it sent a message, because the reflection path it needs is not there any more.

The fix is a cast, so it binds to the `JsonNode` overload instead:

```csharp
var messages = new JsonArray { (JsonNode)new JsonObject { ["role"] = "system", ["content"] = system } };
```

If you take one thing from this section: trimming warnings in a file-based app are not noise. They are the difference between a binary that works and one that fails on its first real request.

**Try It** 🚀

```bash
# get it
git clone https://github.com/solrevdev/solrevdev.orchat.git
cd solrevdev.orchat

# store the key once
security add-generic-password -a "$USER" -s OPENROUTER_API_KEY -w

# run it
./orchat.sh
```

Then:

```
> /models free
> /models use 14
> explain server-sent events in two sentences
> /model anthropic/claude-sonnet-4.5
> the answer above came from a much smaller model. what did it miss?
> /cost
```

The model is read fresh on every request, so `/model` switches mid-thread and the new model inherits the whole conversation. Handing one model another model's answer and asking what is wrong with it is the most useful thing this tool does, and it took no code at all. It falls out of keeping the thread in a list.

**What I Took Away** 💡

1. **File-based apps are past the toy stage.** Packages, shebangs, native publish, and a one-command exit to a real project. The reasons not to start something as a single file are getting thin.
2. **Ask the API what it charged you.** `usage.include` returns the real cost per request. Printing it after every turn changed which models I reach for more than any benchmark has.
3. **Check which scope an endpoint reports on.** `/key` and `/credits` both return something called usage. One is per key, one is per account, and reading the wrong one had me convinced a working thing was broken.
4. **Rounding hides the truth in both directions.** A dashboard showing $0.00 was not telling me nothing happened. It was telling me it could not be bothered to show four more digits.
5. **Parse the response you get, not the one in the docs.** Prices as strings except when they are numbers, missing context lengths, keep-alive lines in the event stream. None of it is documented and none of it survives a mock.
6. **Free models are not free activity.** Zero cost means zero charge means no billable event. If something downstream depends on you spending money, spend money.
7. **The keychain was there all along.** Two commands, encrypted, no dependency. I had been putting keys in dotfiles for years for no reason.

**What Is Next** 🔮

- A `/compare` command that sends one prompt to several models and prints the answers with their costs side by side.
- Token counts per model in `/cost`, so the session summary shows where the money went.
- Nothing scheduled. OpenRouter emails before credits expire, so the email is the reminder and a cron job would be one more thing to maintain.

The whole thing is one file, no project, no packages, and it fits in a screenful of scrolling. If you have an OpenRouter key and .NET 10, you can have it running in about a minute.

The source is at [solrevdev/solrevdev.orchat](https://github.com/solrevdev/solrevdev.orchat), MIT licensed. `orchat.cs` is the entire application, so you can read it in one sitting.

Success! 🎉
