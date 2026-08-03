---
layout: post
title: Building bbx - A Bitbucket Cloud CLI as a .NET Global Tool
description: How I built bbx, a .NET 10 global tool that puts the Bitbucket Cloud API v2 on the command line with JSON on stdout, so scripts and LLM agents can drive Bitbucket the way gh drives GitHub.
summary: A start-to-finish account of building solrevdev.bbx, a .NET global tool for Bitbucket Cloud. Covers the System.CommandLine 2.0 rewrite, feature-slice architecture, API token auth, the four bugs that only show up against a live API, testing with a fake HTTP handler, and a publish workflow that will not push a duplicate version to NuGet.
cover_image: /images/bbx-bitbucket-cli-cover.svg
image: /images/bbx-bitbucket-cli-cover.png
tags:
- dotnet-global-tools
- bitbucket
- bitbucket-api
- cli
- csharp
- dotnet
- dotnet-10
- system-commandline
- nuget
- ci-cd
- llm
- ai-agents

---
**Overview** ☀

GitHub has `gh`. Bitbucket has nothing. Atlassian never shipped a first-party command line tool for Bitbucket Cloud, so anything you want to automate ends up as a pile of `curl` calls with a hand-rolled `Authorization` header and a `jq` filter to make sense of the answer.

I built **bbx** to close that gap. It is a .NET global tool that wraps the Bitbucket Cloud API v2, prints JSON on stdout, keeps human messages on stderr, and exits non-zero when something fails. That last part sounds obvious. It was the single worst bug in the project, and I will come back to it.

This post covers the whole build: what the tool does, how it is put together, the four bugs that only appear when you point the thing at a live API, and the release pipeline that puts it on NuGet. I have written about [.NET global tools](https://solrevdev.com/2025/10/27/building-ytx-a-youtube-transcript-extractor-as-a-dotnet-global-tool.html) and [.NET 10 upgrades](https://solrevdev.com/2025/11/14/upgrading-seedfolder-to-dotnet-10-lts.html) before, so I have skipped the ground those posts already cover and spent the space on what was new here.

The source is on GitHub at [solrevdev/solrevdev.bbx](https://github.com/solrevdev/solrevdev.bbx), and the package is on NuGet as [solrevdev.bbx](https://www.nuget.org/packages/solrevdev.bbx).

**What bbx Is** 🎯

`bbx` is `gh` for Bitbucket Cloud. One command per thing you would otherwise open a browser tab for:

```bash
bbx repo list -w myworkspace --limit 10
bbx pr list -w myworkspace -r myrepo --state OPEN
bbx pr view 42 -w myworkspace -r myrepo
bbx pipeline list -w myworkspace -r myrepo --limit 5
```

Coverage runs to twelve command groups: repositories, pull requests, branches, tags, commits, source files, downloads, pipelines, snippets, workspaces, projects and users. Underneath that there are 150 feature handlers, one per verb.

Set a default workspace once and you can drop `-w` from everything after it:

```bash
bbx auth set-workspace myworkspace
bbx pr list -r myrepo --state OPEN
```

**What It Is Useful For** 🔧

Three things, in the order I actually use them.

**Answering a question without leaving the terminal.** "Did the last pipeline pass?" is a browser tab, two clicks and a wait. Or:

```bash
bbx pipeline list -r myrepo --limit 1 \
  | jq -r '.pipelines[0].state | "\(.name) \(.result // "")"'
```

**Scripting against Bitbucket in CI.** Every command answers with JSON and reports failure through its exit code, so `set -e` and `if !` do what you expect:

```bash
if ! prs=$(bbx pr list -r myrepo --state OPEN); then
  echo "lookup failed" >&2
  exit 1
fi
```

**Giving an LLM agent a way to read Bitbucket.** This is the one that shaped the design. An agent calling a CLI needs a stable contract, not human prose it has to scrape. `bbx` promises three things and the whole tool is built to keep them:

1. JSON on stdout, everything else on stderr, so a pipe stays clean.
2. Exit `0` on success and `1` on any failure, so the agent knows without parsing.
3. Pretty-printed by default, single-line on request via `--json-compact` or `BBX_JSON_COMPACT=1`, because an agent paying per token wants the compact form.

There is a fourth flag for the same audience. `BBX_NO_INTERACTIVE=1` guarantees the tool never stops to prompt, and fails with a clear message instead:

```bash
BBX_NO_INTERACTIVE=1 bbx repo list -w myworkspace
```

The repository ships a [separate guide written for agents rather than people](https://github.com/solrevdev/solrevdev.bbx/blob/master/docs/llm-guide.md), which turned out to be a more useful artefact than I expected. Point an agent at that file and it stops guessing at argument shapes.

**How It Was Built, Start to Finish** 🏗️

The first commit landed on 31 December 2025. Version 1.0.0 went to NuGet on 2 August 2026. That is a long calendar gap and a short amount of actual work: 57 commits, most of them in two bursts.

The first burst produced something that worked and was badly organised. Argument parsing, HTTP calls and output formatting all lived in the same files. Adding a command meant touching four places and hoping.

The second burst, in May 2026, was a rewrite that kept the command surface and replaced everything behind it. That is where the shape below comes from.

**Project Layout** 📁

```
src/Bbx/
  Program.cs        entry point; builds DI once, owns the exit-code contract
  Api/              BitbucketClient, JsonElementExtensions
  Auth/             ICredentialStore, CredentialManager, IAuthProvider, AuthGate
  Commands/         System.CommandLine wiring only, no business logic
  Features/<Area>/<Verb>/   Request record + Handler, co-located
  Composition/      ServiceRegistration (DI), JsonOptions
tests/Bbx.Tests/    fake HTTP handler, in-memory credential store, no network
```

One rule holds the whole thing together: **files in `Commands/` parse arguments and nothing else.** They describe the CLI, then hand off. All the logic lives in a handler under `Features/`.

A handler is small and boring on purpose. Here is the one behind `bbx repo list`, in full:

```csharp
public sealed class ListReposHandler(BitbucketClient client, CredentialManager credentials)
{
    public async Task<object> HandleAsync(ListReposRequest request, CancellationToken ct)
    {
        var workspace = Resolve.Workspace(credentials, request.Workspace,
            "Error: Workspace required. Use --workspace or run: bbx auth set-workspace <workspace>");

        var endpoint = $"/repositories/{workspace}";
        if (!string.IsNullOrEmpty(request.Query))
            endpoint += $"?q={Uri.EscapeDataString(request.Query)}";

        var repos = new List<object>();
        var count = 0;
        await foreach (var repo in client.GetPaginatedAsync<JsonElement>(endpoint, ct))
        {
            repos.Add(new
            {
                name = repo.TryGetProperty("name", out var n) ? n.GetString() : null,
                slug = repo.TryGetProperty("slug", out var s) ? s.GetString() : null,
                full_name = repo.TryGetProperty("full_name", out var fn) ? fn.GetString() : null,
                is_private = repo.TryGetProperty("is_private", out var ip) && ip.GetBoolean(),
                scm = repo.TryGetProperty("scm", out var scm) ? scm.GetString() : null,
                description = repo.TryGetProperty("description", out var d) ? d.GetString() : null,
                updated_on = repo.TryGetProperty("updated_on", out var u) ? u.GetString() : null,
                size = repo.TryGetProperty("size", out var sz) ? sz.GetInt64() : 0
            });
            if (++count >= request.Limit) break;
        }

        return new
        {
            workspace,
            count = repos.Count,
            repositories = repos,
        };
    }
}
```

It resolves the workspace, walks a paginated endpoint, reshapes each item, and returns an anonymous object. It never serializes anything and never writes to the console. `CommandRunner` does that, in one place, so the output contract cannot drift between commands.

Adding a command is now five steps with no thinking involved: write the request record, write the handler, register it in `ServiceRegistration`, wire it in the matching `Commands/` file, and test it against the fake HTTP handler.

**Not Multi-Targeting This Time** 🎚️

My [.NET 10 upgrade post](https://solrevdev.com/2025/11/14/upgrading-seedfolder-to-dotnet-10-lts.html) was all about multi-targeting: keep `net8.0` and `net9.0` alongside `net10.0` so nobody gets locked out. `bbx` targets `net10.0` and nothing else, which is the opposite call, so it is worth saying why.

SeedFolder had users on older SDKs already. `bbx` had none, because it had never shipped. And the calendar was against the old frameworks: .NET 8 and .NET 9 both reach end of support on 10 November 2026. Multi-targeting a brand new package would have meant shipping build assets for runtimes that expire within months of release, for the benefit of zero existing users.

The compatibility problem multi-targeting solves is handled by one property instead:

```xml
<TargetFramework>net10.0</TargetFramework>

<!-- Run on a newer major runtime than the asset was built for, so the tool
     still works on a machine that has only the latest .NET installed. -->
<RollForward>Major</RollForward>
```

`RollForward` covers the direction that actually matters for a global tool. Someone who upgrades to .NET 11 keeps a working `bbx` without me shipping anything.

The rest of the packaging is the familiar global tool block, with a few additions worth calling out:

```xml
<PackAsTool>true</PackAsTool>
<ToolCommandName>bbx</ToolCommandName>
<PackageId>solrevdev.bbx</PackageId>
<AssemblyName>bbx</AssemblyName>

<PackageReadmeFile>PACKAGE.md</PackageReadmeFile>
<PackageIcon>icon.png</PackageIcon>

<IncludeSymbols>true</IncludeSymbols>
<SymbolPackageFormat>snupkg</SymbolPackageFormat>
<PublishRepositoryUrl>true</PublishRepositoryUrl>
<EmbedUntrackedSources>true</EmbedUntrackedSources>
```

`AssemblyName` is set to `bbx` deliberately. System.CommandLine 2.0 derives the program name in help and usage text from the assembly and no longer lets you set `RootCommand.Name`, so if the assembly is called `Bbx` then every usage line reads `Bbx pr list`. Naming the assembly after the command fixes it.

`PackageReadmeFile` points at a `PACKAGE.md` rather than the repository `README.md`. NuGet.org strips raw HTML, and the GitHub readme leans on `<details>` blocks for its command reference, so on NuGet it would have rendered as a wall of unformatted text.

The symbol properties mean a stack trace from a published build maps back to real source lines. Cheap to turn on, and worth it the first time a user reports a crash.

**System.CommandLine 2.0 Broke Every Command File** 🧨

This was the biggest surprise of the rewrite, and the thing I would most want to know before starting.

System.CommandLine 2.0 removed the strongly-typed `SetHandler(handler, symbols…)` family. In its place there is a single callback that hands you a `ParseResult` and leaves you to pull your own values out:

```csharp
command.SetAction((parseResult, cancellationToken) =>
{
    var workspace = parseResult.GetValue(workspaceOption);
    var repo = parseResult.GetValue(repoOption);
    var state = parseResult.GetValue(stateOption);
    var limit = parseResult.GetValue(limitOption);
    return handler(workspace, repo, state, limit);
});
```

That is fine once. Across 150 commands it turns every command file from a description of the CLI into a pile of `GetValue` calls, and it throws away the compile-time check that a bound symbol matches the handler parameter it feeds.

So I wrote a small shim to keep the declarative shape. The awkward part is that `GetValue` has two overloads, one for `Option<T>` and one for `Argument<T>`, with no common base carrying the value type. A tiny struct closes over whichever applies:

```csharp
internal readonly struct Bound<T>
{
    private readonly Func<ParseResult, T> _read;

    private Bound(Func<ParseResult, T> read) => _read = read;

    public T From(ParseResult parseResult) => _read(parseResult);

    public static implicit operator Bound<T>(Option<T> option) => new(pr => pr.GetValue(option)!);

    public static implicit operator Bound<T>(Argument<T> argument) => new(pr => pr.GetValue(argument)!);
}
```

The implicit conversions are what make it pleasant to use. A command passes an `Option<T>` or an `Argument<T>` interchangeably, and the compiler still checks that each one lines up with its handler parameter:

```csharp
internal static class CommandBinding
{
    public static void SetHandler<T1, T2, T3, T4>(
        this Command command, Func<T1, T2, T3, T4, Task> handler,
        Bound<T1> b1, Bound<T2> b2, Bound<T3> b3, Bound<T4> b4)
        => command.SetAction((pr, _) => handler(
            b1.From(pr), b2.From(pr), b3.From(pr), b4.From(pr)));
}
```

Overloads run up to eight parameters, which covers every command in the tool. Command files went back to reading like a description of the CLI.

One thing the shim cannot restore: a broken command definition still compiles. Registering an option on the wrong command, or forgetting to register it at all, is a runtime problem now. That is a real bug I shipped and I will get to it shortly. The answer was a test class that asserts against parse behaviour rather than against handler output.

**The Four Bugs You Only Find Against a Live API** 🐛

Unit tests against a fake HTTP handler catch logic errors. They do not catch a wrong assumption about what the other end actually sends. These four all passed their tests and all failed in real use.

**1. Every failed command exited 0.**

The worst one, and the least visible. Handlers catch their own errors, print to stderr and set `Environment.ExitCode = 1`. The tool printed the right error. It exited 0 anyway, so every script and every agent saw success.

The cause is a rule that is easy to forget: a value returned from `Main` overrides whatever you put in `Environment.ExitCode`. Returning the invocation result alone discarded it, because System.CommandLine reports 0 whenever a handler returned normally.

```csharp
var parseResult = rootCommand.Parse(args);

int exitCode;
try
{
    exitCode = await parseResult.InvokeAsync();
}
catch (Exception ex)
{
    // System.CommandLine 2.0 dropped the built-in exception handler, so
    // report the message here rather than printing a stack trace.
    Console.Error.WriteLine($"Error: {ex.Message}");
    return 1;
}

// A value returned from Main overrides Environment.ExitCode, and the
// invocation reports 0 whenever a handler returned normally. Handlers catch
// their own errors and set Environment.ExitCode, so returning the invocation
// result alone made every failed command exit 0.
return exitCode != 0 ? exitCode : Environment.ExitCode;
```

Keep the invocation's non-zero result when there is one, because that is a parse failure. Otherwise fall through to whatever the handler set. If you take one thing from this post, take this one.

**2. HttpClient drops your credentials when it follows a redirect.**

`bbx pr diff` and `bbx pr patch` always failed with "You may not have access to this repository". Both endpoints answer with a 302 to the underlying commit-range diff. `HttpClient` follows it, and strips the `Authorization` header on the way, because it cannot know the redirect target is trustworthy. The authenticated request arrives anonymous, and Bitbucket says you have no access.

The fix is to turn automatic redirects off and follow them yourself, re-applying credentials only when the target is on the same origin:

```csharp
var hops = 0;
while (IsRedirect(response) && method == HttpMethod.Get && hops++ < MaxRedirects)
{
    var location = response.Headers.Location;
    if (location is null) break;

    var target = location.IsAbsoluteUri ? location : new Uri(current, location);
    response.Dispose();

    // Re-apply credentials only when staying on the same origin, so a
    // redirect out to storage cannot leak them.
    var sameOrigin = Uri.Compare(target, current, UriComponents.SchemeAndServer,
        UriFormat.UriEscaped, StringComparison.OrdinalIgnoreCase) == 0;

    current = target;
    response = await SendOnceAsync(HttpMethod.Get, target.AbsoluteUri, null, ct, accept,
        applyAuth: sameOrigin);
}
```

The same-origin check is not decoration. Downloads redirect out to object storage, and re-attaching a Bitbucket credential to that request would hand it to a third party. Only GET is followed, because other verbs would need their body re-sent and nothing we call redirects them.

**3. `TryGetProperty` returns true for a JSON null.**

`bbx branch tag list` crashed on any repository with a lightweight tag. Bitbucket sends `"tagger": null` for those, rather than leaving the property out. `TryGetProperty` reports success, hands back an element whose `ValueKind` is `Null`, and reading a property off it throws.

```csharp
public static bool TryGetObject(this JsonElement element, string name, out JsonElement value)
{
    if (element.ValueKind == JsonValueKind.Object
        && element.TryGetProperty(name, out var candidate)
        && candidate.ValueKind == JsonValueKind.Object)
    {
        value = candidate;
        return true;
    }

    value = default;
    return false;
}
```

One tag crashed. The same pattern was wrong at 41 other nested lookups that had simply not met a null yet. Worth grepping for if you are reading someone else's JSON.

**4. A default `Accept` header caused an HTTP 406.**

`bbx pipeline logs` returned 406 Not Acceptable for every pipeline. The client sends `Accept: application/json` as a default header, which is right for the ninety-odd endpoints that return JSON. The step log endpoint serves `application/octet-stream` and refuses to fall back. Setting `Accept: */*` on the calls that expect something other than JSON suppresses the default for that request.

Small fix, and completely invisible to a test that fakes the response.

**Errors That Tell You What To Do** 💬

Bitbucket answers a scope failure with a bare 403 and a `detail` object naming the scopes it wanted. Passing "HTTP 403 Forbidden" to the user throws that away and leaves them guessing. So the client unpacks it:

```console
$ bbx repo deploy-keys list -w myworkspace -r myrepo
Error: Your credentials lack one or more required privilege scopes. (HTTP 403 Forbidden)
Missing token scopes: admin:repository:bitbucket. Re-issue your token with those
scopes at https://id.atlassian.com/manage-profile/security/api-tokens
```

Getting that link right took two goes. The first release pointed at
`bitbucket.org/account/settings/api-tokens/`, which looks obvious and returns a
404: API tokens live on the Atlassian account, not under Bitbucket's own
settings. An error message that sends you to a dead page is worse than one that
says nothing, because you assume you mistyped something.

There is a trap in the deserialization. `error.detail` is an **object** for scope failures and a **string** everywhere else. Typing it as `string` makes the whole payload fail to deserialize, which silently reduces every 403 back to the bare status. It has to stay a `JsonElement`:

```csharp
public class BitbucketErrorDetail
{
    public string? Message { get; set; }

    /// <summary>
    /// Free-form. A string for most errors, but an object carrying
    /// <c>required</c> and <c>granted</c> arrays for scope failures.
    /// </summary>
    public JsonElement? Detail { get; set; }

    public string? Id { get; set; }
    public BitbucketErrorData? Data { get; set; }
}
```

The same routine prints `error.data.announcement_url` when there is one, so a deprecation error carries the changelog entry that explains it.

**Auth: One Token, One File** 🔐

`bbx` authenticates with an Atlassian API token and nothing else. Getting there took a detour worth describing, because the obvious answer is wrong.

I built OAuth first. It works, and I deleted it before release. Bitbucket's OAuth is bring-your-own-consumer: every user has to create a private OAuth consumer in workspace settings, set a callback URL, and copy out a key and a secret before they can log in once. That is more setup than pasting a token, and it needs workspace admin rights a contributor may not have. App passwords were not an option either, since Bitbucket retires them on 9 June 2026.

So the flow is one command:

```bash
bbx auth login
```

It prompts for your Atlassian account email and the token, checks the pair against `/2.0/user`, and saves them to `~/.config/bbx/config.json` with mode 0600. Two details that matter: Atlassian API tokens are **basic** auth with `email:token`, not bearer tokens, and the email is the Atlassian account email rather than the Bitbucket username.

An `AuthGate` runs before every non-auth command. On a terminal it prompts for a credential on first use. Without a terminal it fails with a message telling you what to run, and `BBX_NO_INTERACTIVE=1` forces that behaviour even when a terminal is present. In CI you skip the prompt entirely by writing the config file:

{% raw %}
```yaml
- name: Configure bbx
  run: |
    mkdir -p ~/.config/bbx
    cat > ~/.config/bbx/config.json <<'JSON'
    { "AuthMethod": "api-token",
      "Username": "${{ secrets.BITBUCKET_EMAIL }}",
      "ApiToken": "${{ secrets.BITBUCKET_API_TOKEN }}",
      "DefaultWorkspace": "myworkspace" }
    JSON
    chmod 600 ~/.config/bbx/config.json
```
{% endraw %}

Commands that change or remove something confirm before they act, and take `--yes` to skip the prompt in a script. The prompt goes to stderr, so it cannot end up in a JSON pipe.

**Endpoints Bitbucket Has Withdrawn** 🚫

Some things cannot be built no matter how you write the client, and it saves time to know which.

`bbx workspace list` and `bbx user permissions workspaces|repositories` return **HTTP 410 Gone**. Atlassian removed the cross-workspace discovery endpoints under CHANGE-2770. There is no replacement. You name the workspace, or you set a default with `bbx auth set-workspace`. I spent a while assuming I had the URL wrong.

Usernames are no longer valid user selectors either; user lookups need an account UUID or account ID.

And Bitbucket Issues shut down on **20 August 2026**. The `issue` command group is in the tool, works today, prints a warning to stderr, and goes away with the API. Building against something with a published end date is a strange feeling, but leaving it out would have been worse for anyone still using it this month.

**Testing Without a Network** 🧪

The test project runs 205 tests against a fake `HttpMessageHandler` and an in-memory credential store. Nothing touches the network, so the suite is fast and runs the same in CI as it does locally.

Three things I would repeat:

**Tests do not run in parallel.** Several capture `Console` or read `Environment.ExitCode`. Both are process-global, so parallel tests corrupt each other in ways that look like flakiness. One line in `AssemblyInfo.cs` disables it.

**Parse behaviour needs its own tests.** Because a broken command definition still compiles under System.CommandLine 2.0, handler tests prove nothing about wiring. A separate test class parses argument strings and asserts on the result. That is what caught `--project-key` being bound in the handler but never registered as an option, which made three `workspace project` subcommands impossible to use.

**Check the licence on your assertion library.** The tests use [AwesomeAssertions](https://github.com/AwesomeAssertions/AwesomeAssertions), an Apache-2.0 fork of FluentAssertions 7. FluentAssertions 8 moved to the Xceed Community licence, which requires a paid commercial licence for use by or for a revenue-earning organisation. The API is identical and the namespace is `AwesomeAssertions`, so the switch is a find and replace. An automated dependency bump to version 8 would quietly create a licensing problem in a repository that looks fine.

**The Release Pipeline** 🤖

The workflow builds, tests, packs, publishes to NuGet, tags the commit and opens a GitHub release. My [ytx post](https://solrevdev.com/2025/10/27/building-ytx-a-youtube-transcript-extractor-as-a-dotnet-global-tool.html) walks through that shape in detail, so here are only the parts that are different.

**Pull requests validate, they do not publish.** Two jobs guarded by the event type, sharing the same `env` block. A PR gets restore, build, test and pack. It never sees the NuGet key.

{% raw %}
```yaml
jobs:
  validate:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
      - uses: actions/setup-dotnet@v5
        with:
          global-json-file: global.json
      - run: dotnet restore "$PROJECT_DIR" && dotnet restore "$TEST_PROJECT"
      - run: dotnet build "$PROJECT_DIR" --configuration Release --no-restore
      - run: dotnet test "$TEST_PROJECT" --configuration Release --no-restore
      - run: dotnet pack "$PROJECT_DIR" --configuration Release --no-build

  publish:
    if: github.event_name != 'pull_request'
    permissions:
      contents: write
    runs-on: ubuntu-latest
```
{% endraw %}

Note where `permissions` sits. The workflow default is `contents: read`, and only the publish job widens it to `write`. A pull request from a fork cannot get a token that can push.

**The SDK comes from `global.json`.** Rather than listing versions in the workflow, `setup-dotnet` reads the same pin the repository uses locally:

```yaml
- uses: actions/setup-dotnet@v5
  with:
    global-json-file: global.json
```

CI and a local build cannot drift apart, because there is only one place the version is written.

**The first release ships the version already in the csproj.** Every bump script has an awkward first run. If it always bumps, your `1.0.0` in source publishes as `1.0.1` and the repository never matches the package. Checking for release tags handles it:

{% raw %}
```bash
# The very first release ships the version already in the csproj. Every run
# after that bumps, so a later run can never try to push a version NuGet
# already has.
if git ls-remote --exit-code --tags origin 'refs/tags/v*' >/dev/null 2>&1; then
  case "$BUMP" in
    major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
    minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
    patch) PATCH=$((PATCH + 1)) ;;
  esac
  VERSION="$MAJOR.$MINOR.$PATCH"
else
  VERSION="$CURRENT"
  echo "No release tags yet; publishing the initial version as-is."
fi
```
{% endraw %}

**It refuses to publish a stale commit.** A push to master starts a run against a specific SHA. If another push lands while that run is packing, the job would tag and publish code that is no longer the tip of master. So before publishing, it checks:

{% raw %}
```bash
REMOTE_MASTER=$(git ls-remote origin refs/heads/master | cut -f1)
if git ls-remote --exit-code --tags origin "refs/tags/$TAG" >/dev/null 2>&1; then
  echo "Tag $TAG already exists; this is a safe retry."
  echo "tag_exists=true" >> "$GITHUB_OUTPUT"
else
  if [[ "$REMOTE_MASTER" != "$GITHUB_SHA" ]]; then
    echo "origin/master moved from $GITHUB_SHA to $REMOTE_MASTER; refusing to publish." >&2
    exit 1
  fi
  echo "tag_exists=false" >> "$GITHUB_OUTPUT"
fi
```
{% endraw %}

An existing tag is treated as a retry rather than an error, so re-running a failed job after a network blip does the right thing instead of exploding. The version and tag push together atomically:

```bash
git push --atomic origin HEAD:refs/heads/master "refs/tags/$TAG"
```

`--atomic` means the branch and the tag both move or neither does. Without it, a failure between the two pushes leaves a tagged version that is not on master.

**The pack step verifies its own output.** `dotnet pack` can succeed while producing a file named something other than what you expect, usually because a version property resolved differently than you thought. Checking for the exact filename before pushing turns that into a clear failure instead of a confusing `nuget push` error:

{% raw %}
```bash
PACKAGE="$NUPKG_DIR/solrevdev.bbx.$VERSION.nupkg"
if [[ ! -f "$PACKAGE" ]]; then
  echo "Expected package was not created: $PACKAGE" >&2
  exit 1
fi
```
{% endraw %}

**Try It** 📦

```bash
dotnet tool install -g solrevdev.bbx
bbx auth login
bbx auth set-workspace myworkspace
bbx repo list --limit 10
```

Create the API token first from your [Atlassian account security settings](https://id.atlassian.com/manage-profile/security/api-tokens). Note that the page offers two buttons, and you want **Create API token with scopes** rather than the plain one: `bbx` reports missing scopes by name, which only works on a token that carries them. Grant the least you need, and read-only scopes are enough for everything above. Atlassian documents the process in [manage API tokens for your Atlassian account](https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/).

Tokens live on your Atlassian account, not under Bitbucket's own settings, which is worth knowing because it is not where you would think to look.

A few more read-only commands to get a feel for the output:

```bash
bbx pr list -r myrepo --state OPEN --limit 5
bbx branch list -r myrepo --limit 10
bbx commit list -r myrepo --limit 5
bbx src ls --ref main -r myrepo
bbx src cat --ref main README.md -r myrepo
```

Everything above prints JSON except `src cat`, which prints the file. `pr diff`, `pr patch`, `commit diff` and `commit patch` also print raw text, because that is the useful form for a diff.

To build from source:

```bash
git clone https://github.com/solrevdev/solrevdev.bbx.git
cd solrevdev.bbx

dotnet build src/Bbx/Bbx.csproj
dotnet test tests/Bbx.Tests/Bbx.Tests.csproj

# run without installing
dotnet run --project src/Bbx/Bbx.csproj -f net10.0 -- repo list -w myworkspace
```

**What I Took Away** 💡

1. **Test the exit code.** It is the part of a CLI nobody looks at and every script depends on. Mine was wrong for months while the tool printed perfect error messages.
2. **Read the real responses, not the documentation.** Explicit JSON nulls, a redirect that eats your auth header, an endpoint that refuses `Accept: application/json`. None of these are in the API docs and none survive contact with a mock.
3. **A wrapper is only as good as its error messages.** Turning a bare 403 into "here is the scope you are missing and here is where to re-issue the token" took an afternoon and removed the most common support question before anyone asked it.
4. **Pick the boring architecture.** One folder per verb, handlers that return objects, one place that serializes. Adding the last thirty commands took no design thought at all, which is the point.
5. **Check the licence, not just the version.** The FluentAssertions 8 relicence is the kind of thing a dependency bot walks straight into.
6. **Write the agent documentation separately.** A guide written for an LLM looks different from one written for a person: pattern tables instead of prose, argument shapes instead of narrative. Keeping them apart made both better.

**What Is Next** 🔮

- A `--fields` flag to trim the JSON to what the caller wants, which matters when an agent is paying per token.
- Shell completions for bash and zsh.
- Retiring the `issue` group when Bitbucket retires the API on 20 August 2026.

The repository is at [github.com/solrevdev/solrevdev.bbx](https://github.com/solrevdev/solrevdev.bbx), the package is at [nuget.org/packages/solrevdev.bbx](https://www.nuget.org/packages/solrevdev.bbx), and issues and pull requests are welcome.

Success! 🎉
