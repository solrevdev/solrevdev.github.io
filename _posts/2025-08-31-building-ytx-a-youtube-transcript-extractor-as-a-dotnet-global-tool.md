---
layout: post
title: Building ytx - A YouTube Transcript Extractor as a .NET Global Tool
description: How to build a .NET Global Tool that extracts YouTube video metadata and transcripts as structured JSON, from concept to NuGet publication
summary: A tutorial on creating ytx, a .NET global tool that extracts YouTube video titles, descriptions, and transcripts as JSON using YoutubeExplode and automated CI/CD.
cover_image: /images/ytx-dotnet-tool-cover.svg
tags:
- dotnet-global-tools
- youtube
- transcripts
- csharp
- dotnet
- json
- ci-cd
- nuget

---
**Overview** ☀

Sometimes you need to extract structured data from YouTube videos for analysis, documentation, or automation. While there are various web-based solutions, having a command-line tool that outputs clean JSON makes integration with scripts and pipelines much easier.

I built `ytx` - a .NET Global Tool that extracts YouTube video metadata and transcripts as structured JSON. The tool takes a YouTube URL and returns the video title, description, and full transcript with timestamps in both raw text and markdown formats.

**The Problem** 🎯

I wanted a simple way to:
- Extract YouTube video transcripts for analysis
- Get structured JSON output for easy parsing
- Handle different caption languages and auto-generated captions
- Create timestamped links back to specific moments in videos
- Package everything as a portable command-line tool

**Project Architecture** 🏗️

The tool is built as a single-file .NET console application with a simple but effective architecture:

```csharp
record Input(string url);

class Output
{
    public string url { get; set; } = "";
    public string title { get; set; } = "";
    public string description { get; set; } = "";
    public string transcriptRaw { get; set; } = "";
    public string transcript { get; set; } = "";
}
```

The data flow is straightforward:
1. Input validation (command-line args or JSON via stdin)
2. YouTube video data extraction via YoutubeExplode
3. Caption track discovery and selection
4. Transcript formatting (raw + markdown with timestamps)
5. JSON serialization to stdout

**Getting Started** 🚀

First, I created the project structure:

```powershell
dotnet new console -n Ytx
cd Ytx
```

The key to making this a global tool is the `.csproj` configuration:

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFrameworks>net8.0;net9.0</TargetFrameworks>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>

    <!-- dotnet tool packaging -->
    <PackAsTool>true</PackAsTool>
    <ToolCommandName>ytx</ToolCommandName>
    <PackageId>solrevdev.ytx</PackageId>

    <!-- CI auto-bumps this -->
    <Version>1.0.2</Version>

    <!-- NuGet metadata -->
    <Authors>solrevdev</Authors>
    <PackageDescription>Extract YouTube title, description, and transcript (raw + Markdown) as JSON.</PackageDescription>
    <PackageTags>YouTube;transcript;captions;cli;dotnet-tool;json</PackageTags>
    <RepositoryUrl>https://github.com/solrevdev/solrevdev.ytx</RepositoryUrl>
    <PackageProjectUrl>https://github.com/solrevdev/solrevdev.ytx</PackageProjectUrl>
    <PackageLicenseExpression>MIT</PackageLicenseExpression>
    <PackageReadmeFile>README.md</PackageReadmeFile>

    <!-- where pack puts .nupkg -->
    <PackageOutputPath>../../nupkg</PackageOutputPath>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="YoutubeExplode" Version="6.5.4" />
  </ItemGroup>

  <ItemGroup>
    <None Include="../../README.md" Pack="true" PackagePath="\" />
  </ItemGroup>
</Project>
```

The crucial elements are:
- `PackAsTool>true` - Makes this a global tool
- `ToolCommandName` - The command users will type
- `TargetFrameworks` - Multi-targeting for compatibility
- `PackageOutputPath` - Consistent build artifacts location

**Core Implementation** ⚙️

The main challenge was handling YouTube's various caption formats and languages. Here's the complete Main method:

```csharp
static async Task<int> Main(string[] args)
{
    try
    {
        string? url = null;

        if (args.Length == 1 && !string.IsNullOrWhiteSpace(args[0]))
        {
            url = args[0];
        }
        else
        {
            string stdin = Console.IsInputRedirected ? await Console.In.ReadToEndAsync() : "";
            if (!string.IsNullOrWhiteSpace(stdin))
            {
                var input = JsonSerializer.Deserialize<Input>(stdin.Trim(),
                    new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
                url = input?.url;
            }
        }

        if (string.IsNullOrWhiteSpace(url))
        {
            Console.Error.WriteLine("Usage: ytx <YouTube URL>\n   or: echo '{\"url\":\"https://...\"}' | ytx");
            return 2;
        }

        var client = new YoutubeClient();
        var videoId = VideoId.TryParse(url) ?? throw new ArgumentException("Invalid YouTube URL/ID.");
        var video = await client.Videos.GetAsync(videoId);
        var title = video.Title ?? "";
        var description = video.Description ?? "";

        string transcriptRaw = "";
        string transcriptMd = "";

        try
        {
            var manifest = await client.Videos.ClosedCaptions.GetManifestAsync(video.Id);
            var track = manifest.Tracks
                .OrderByDescending(t => t.Language.Name.Contains("English", StringComparison.OrdinalIgnoreCase))
                .ThenByDescending(t => t.IsAutoGenerated)
                .FirstOrDefault();

            if (track != null)
            {
                var captions = await client.Videos.ClosedCaptions.GetAsync(track);

                var rawSb = new StringBuilder();
                var mdSb  = new StringBuilder();

                foreach (var c in captions.Captions)
                {
                    var text = NormalizeCaption(c.Text);
                    if (string.IsNullOrWhiteSpace(text)) continue;

                    if (rawSb.Length > 0) rawSb.Append(' ');
                    rawSb.Append(text);

                    var ts = ToHhMmSs(c.Offset);
                    var link = $"https://www.youtube.com/watch?v={video.Id}&t={(int)c.Offset.TotalSeconds}s";
                    mdSb.AppendLine($"- [{ts}]({link}) {text}");
                }

                transcriptRaw = rawSb.ToString().Trim();
                transcriptMd = mdSb.ToString().TrimEnd();
            }
            else
            {
                transcriptRaw = "";
                transcriptMd = "_No transcript/captions available for this video._";
            }
        }
        catch
        {
            transcriptRaw = "";
            transcriptMd = "_No transcript/captions available or captions retrieval failed._";
        }

        var output = new Output
        {
            url = url,
            title = title,
            description = description,
            transcriptRaw = transcriptRaw,
            transcript = transcriptMd
        };

        var json = JsonSerializer.Serialize(output, new JsonSerializerOptions
        {
            WriteIndented = true,
            Encoder = System.Text.Encodings.Web.JavaScriptEncoder.UnsafeRelaxedJsonEscaping
        });

        Console.OutputEncoding = Encoding.UTF8;
        Console.WriteLine(json);
        return 0;
    }
    catch (Exception ex)
    {
        Console.Error.WriteLine($"Error: {ex.Message}");
        return 1;
    }
}
```

**Smart Caption Detection** 🧠

One of the trickiest parts was handling YouTube's various caption formats. The tool needs to:
- Prefer English captions when available
- Fall back to any available language
- Handle both manual and auto-generated captions
- Gracefully handle videos without captions

The caption selection logic is embedded in the Main method above (lines 32-62), where it:
1. Gets the caption manifest for the video
2. Orders tracks by English language preference, then by auto-generated status
3. Downloads the selected caption track and formats both raw and markdown output
4. Handles error cases gracefully with appropriate fallback messages

**Utility Functions** 🔧

The tool includes helper functions for formatting and text normalization:

```csharp
static string ToHhMmSs(TimeSpan ts)
{
    int h = (int)ts.TotalHours;
    int m = ts.Minutes;
    int s = ts.Seconds;
    return h > 0 ? $"{h:00}:{m:00}:{s:00}" : $"{m:00}:{s:00}";
}

static string NormalizeCaption(string text)
{
    if (string.IsNullOrWhiteSpace(text)) return "";
    text = Regex.Replace(text, @"\s+", " ").Trim();
    text = text.Replace("&nbsp;", " ");
    return text;
}
```

**Local Development and Testing** 🧪

During development, I used this workflow:

```powershell
# Restore dependencies
dotnet restore src/Ytx

# Build the project
dotnet build src/Ytx -c Release

# Test with a YouTube URL
dotnet run --project src/Ytx --framework net8.0 "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

# Package for local installation testing
dotnet pack src/Ytx -c Release
dotnet tool install -g solrevdev.ytx --add-source ./nupkg
```

This allowed me to test the tool end-to-end before publishing to NuGet.

**Output Format** 📄

The tool produces clean, structured JSON:

```json
{
  "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
  "title": "Rick Astley - Never Gonna Give You Up (Official Music Video)",
  "description": "The official video for \"Never Gonna Give You Up\" by Rick Astley...",
  "transcriptRaw": "We're no strangers to love You know the rules and so do I...",
  "transcript": "- [00:17](https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=17s) We're no strangers to love\n- [00:20](https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=20s) You know the rules and so do I..."
}
```

The markdown transcript format makes it easy to create documentation with clickable timestamps that jump directly to specific moments in the video.

**Automated CI/CD Pipeline** 🤖

To streamline releases, I set up GitHub Actions to automatically:
- Build and test the project
- Increment version numbers
- Publish to NuGet
- Create GitHub releases

The workflow file (`.github/workflows/publish.yml`) handles version bumping:

```yaml
name: Publish NuGet (ytx)

on:
  push:
    branches: [ master ]
  workflow_dispatch:
    inputs:
      version_bump:
        description: 'Version bump type'
        required: true
        default: 'patch'
        type: choice
        options:
          - patch
          - minor
          - major

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: |
            8.0.x
            9.0.x

      - name: Bump version
        run: |
          # Script to increment version in .csproj
          VERSION_TYPE="{% raw %}${{ github.event.inputs.version_bump || 'patch' }}{% endraw %}"
          ./scripts/bump-version.sh "$VERSION_TYPE"

      - name: Build and Pack
        run: |
          dotnet restore src/Ytx
          dotnet build src/Ytx -c Release
          dotnet pack src/Ytx -c Release

      - name: Publish to NuGet
        run: |
          dotnet nuget push nupkg/*.nupkg \
            --api-key {% raw %}${{ secrets.NUGET_API_KEY }}{% endraw %} \
            --source https://api.nuget.org/v3/index.json
```

**Installation and Usage** 📦

Once published to NuGet, users can install the tool globally:

```powershell
# Install the tool
dotnet tool install -g solrevdev.ytx

# Basic usage
ytx "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

# Via JSON input for scripting
echo '{"url":"https://www.youtube.com/watch?v=dQw4w9WgXcQ"}' | ytx

# Save to file for further processing
ytx "https://www.youtube.com/watch?v=dQw4w9WgXcQ" > video-data.json

# Update to latest version
dotnet tool update -g solrevdev.ytx
```

**Error Handling and Edge Cases** ⚠️

The tool handles various error scenarios gracefully:

- Invalid YouTube URLs (exit code 2)
- Private or region-restricted videos (exit code 1)
- Videos without captions (returns explanatory message)
- Network errors (exit code 1)

This makes it suitable for use in scripts and automation pipelines.

**Key Learnings** 💡

Building this tool taught me several valuable lessons:

1. **YoutubeExplode Evolution**: The library has improved significantly - version 6.5.4 resolved transcript extraction issues that existed in earlier versions
2. **Global Tool Packaging**: The `PackageReadmeFile` and proper NuGet metadata are crucial for discoverability
3. **Multi-targeting**: Supporting both .NET 8 and 9 ensures broader compatibility
4. **JSON Input/Output**: Supporting both CLI args and stdin makes the tool more versatile for automation
5. **Caption Prioritization**: Smart ordering logic for captions improves user experience significantly

**Future Enhancements** 🔮

Potential improvements for future versions:

- Support for downloading specific time ranges
- Batch processing multiple URLs
- Custom output formats (CSV, XML)
- Integration with subtitle file formats (SRT, VTT)
- Translation support for non-English captions

**Modern Development Velocity** ⚡

What strikes me most about this project is the development speed enabled by modern AI tooling. From initial concept to published NuGet package took just a few hours - a timeframe that would have been unthinkable just a few years ago.

**The AI-Assisted Workflow** 🤖

This project showcased the power of combining multiple AI tools:

- **Claude Code**: Handled the core architecture decisions, error handling patterns, and CI/CD pipeline setup. Particularly valuable for getting the .csproj packaging configuration right on the first try.
- **GitHub Copilot**: Excelled at generating repetitive code patterns, JSON serialization boilerplate, and regex text normalization functions.
- **MCPs (Model Context Protocol)**: Provided seamless integration between different AI tools and development contexts, making the workflow feel natural rather than fragmented.

**The Human-AI Partnership** 🤝

The most interesting aspect wasn't that AI wrote the code, but how it changed the development process itself:

1. **Design-First Thinking**: Instead of iterating through implementation details, I could focus on the user experience and data flow
2. **Documentation-Driven Development**: Writing this blog post in parallel with coding helped clarify requirements and catch edge cases early
3. **Confidence in Exploration**: Having AI assistance made it easy to try different approaches without the usual "sunk cost" feeling

**Looking Forward** 🔮

This project represents a new normal in software development - where the bottleneck shifts from typing code to thinking through problems and user needs. The combination of AI coding assistants, intelligent toolchains, and human creativity is genuinely transformative.

For developers hesitant about AI tools: they're not replacing us, they're amplifying our ability to solve meaningful problems quickly. The future belongs to developers who can effectively collaborate with AI to build better software faster.

Ready to extract some YouTube transcripts? 🎬

```powershell
dotnet tool install -g solrevdev.ytx
```

Success! 🎉