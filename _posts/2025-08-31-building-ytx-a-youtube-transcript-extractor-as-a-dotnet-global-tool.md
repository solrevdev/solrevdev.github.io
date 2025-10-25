---
layout: post
title: Building ytx - A YouTube Transcript Extractor as a .NET Global Tool
description: Build a .NET Global Tool to extract YouTube transcripts and metadata as JSON. Learn YoutubeExplode, CLI argument parsing, NuGet packaging, and GitHub Actions automation from concept to publication.
summary: Complete tutorial on creating ytx, a .NET global tool for extracting YouTube video titles, descriptions, and transcripts as JSON. Covers YoutubeExplode library, caption selection logic, JSON serialization, NuGet packaging, and automated CI/CD with GitHub Actions.
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

I built **ytx** - a .NET Global Tool that extracts YouTube video metadata and transcripts as structured JSON. The tool takes a YouTube URL and returns the video title, description, and full transcript with timestamps in both raw text and markdown formats. This post walks you through building your own .NET global tool from scratch, covering architecture design, caption handling, JSON serialization, NuGet packaging, and setting up automated CI/CD with GitHub Actions.

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

**Production-Ready CI/CD Pipeline with GitHub Actions** 🤖

To streamline releases and reduce manual work, I set up GitHub Actions to automatically handle the entire release pipeline. Unlike simple workflows, this production pipeline:
- Runs on every push to `master` (only when source files change, avoiding redundant builds)
- Allows manual triggers with version bump selection (patch, minor, or major)
- Automatically increments semantic versions in your `.csproj` file
- Commits version changes back to the repository with git tags
- Builds and publishes to NuGet with proper error handling
- Creates GitHub releases with auto-generated release notes
- Supports multiple .NET versions (8.x and 9.x) for maximum compatibility

The complete workflow file (`.github/workflows/publish.yml`) handles all of this:

```yaml
name: Publish NuGet (ytx)

on:
  workflow_dispatch:
    inputs:
      bump:
        description: 'Version bump type (major|minor|patch)'
        required: true
        default: 'patch'
  push:
    branches: [ "master" ]
    paths:
      - 'src/Ytx/**'
      - '.github/workflows/publish.yml'

permissions:
  contents: write
  packages: read

env:
  PROJECT_DIR: src/Ytx
  CSPROJ: src/Ytx/Ytx.csproj
  NUPKG_DIR: nupkg
  NUGET_SOURCE: https://api.nuget.org/v3/index.json

jobs:
  build-pack-publish:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: |
            9.x
            8.x

      - name: Restore
        run: dotnet restore $PROJECT_DIR

      - name: Determine and bump version
        id: bump
        shell: bash
        run: |
          set -euo pipefail
          CURR=$(grep -oPm1 '(?<=<Version>)[^<]+' "$CSPROJ")
          echo "Current version: $CURR"
          IFS='.' read -r MAJ MIN PAT <<< "$CURR"
          BUMP="${{ github.event.inputs.bump || 'patch' }}"
          case "$BUMP" in
            major) MAJ=$((MAJ+1)); MIN=0; PAT=0 ;;
            minor) MIN=$((MIN+1)); PAT=0 ;;
            patch|*) PAT=$((PAT+1)) ;;
          esac
          NEW="$MAJ.$MIN.$PAT"
          echo "New version: $NEW"
          sed -i "s|<Version>$CURR</Version>|<Version>$NEW</Version>|" "$CSPROJ"
          echo "version=$NEW" >> "$GITHUB_OUTPUT"

      - name: Commit version bump
        if: ${{ github.ref == 'refs/heads/master' }}
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add ${{ env.CSPROJ }}
          git commit -m "chore: bump version to ${{ steps.bump.outputs.version }}"
          git tag "v${{ steps.bump.outputs.version }}"
          git push --follow-tags

      - name: Build
        run: dotnet build $PROJECT_DIR -c Release --no-restore

      - name: Pack
        run: dotnet pack $PROJECT_DIR -c Release --no-build

      - name: Publish to NuGet
        env:
          NUGET_API_KEY: ${{ secrets.NUGET_API_KEY }}
        run: |
          dotnet nuget push $NUPKG_DIR/*.nupkg \
            --api-key "$NUGET_API_KEY" \
            --source "$NUGET_SOURCE" \
            --skip-duplicate

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: v${{ steps.bump.outputs.version }}
          name: ytx v${{ steps.bump.outputs.version }}
          generate_release_notes: true
```

**Understanding the Workflow Architecture** 🏗️

This workflow implements several production best practices that help .NET developers distribute global tools effectively:

**Environment Variables for DRY Principle:**
The `env:` block defines reusable values (`PROJECT_DIR`, `CSPROJ`, `NUPKG_DIR`, `NUGET_SOURCE`) referenced throughout the workflow. This approach keeps configuration centralized—change a directory path once, and it updates everywhere. This is crucial when managing complex multi-project solutions or adjusting package output locations.

**Permissions Block:**
The `permissions:` section restricts the workflow to only what it needs:
- `contents: write` — Required to create commits, tags, and push back to the repository
- `packages: read` — Required for accessing NuGet package data

This follows the principle of least privilege, improving security by preventing the workflow from performing unauthorized actions.

**Smart Trigger Configuration:**
```yaml
on:
  push:
    branches: [ "master" ]
    paths:
      - 'src/Ytx/**'
      - '.github/workflows/publish.yml'
```

The `paths:` filter prevents unnecessary builds when only documentation or other non-source files change. This saves CI/CD minutes and reduces feedback latency.

**Semantic Version Bumping with bash:**
The version bump step demonstrates how to parse and manipulate semantic versions programmatically:

```bash
IFS='.' read -r MAJ MIN PAT <<< "$CURR"  # Parse 1.0.2 into components
case "$BUMP" in
  major) MAJ=$((MAJ+1)); MIN=0; PAT=0 ;;  # 1.0.2 → 2.0.0
  minor) MIN=$((MIN+1)); PAT=0 ;;         # 1.0.2 → 1.1.0
  patch|*) PAT=$((PAT+1)) ;;             # 1.0.2 → 1.0.3
esac
```

This approach ensures version consistency without manually editing `.csproj` files. The `echo "version=$NEW" >> "$GITHUB_OUTPUT"` sends the new version to subsequent steps—a key pattern in GitHub Actions workflows.

**Git Automation for Reproducible Releases:**
```bash
git config user.name "github-actions[bot]"
git add ${{ env.CSPROJ }}
git commit -m "chore: bump version to ${{ steps.bump.outputs.version }}"
git tag "v${{ steps.bump.outputs.version }}"
git push --follow-tags
```

This creates an immutable audit trail. Every NuGet release corresponds to:
1. A specific git commit (with the bumped version)
2. A git tag (for easy checkout: `git checkout v1.0.3`)
3. A GitHub release (with release notes)

This traceability is essential for troubleshooting issues and understanding what code produced which package version.

**Optimized Build Pipeline:**
Notice the careful use of build flags:
```bash
dotnet restore $PROJECT_DIR              # Explicit restore
dotnet build $PROJECT_DIR -c Release --no-restore    # Skip redundant restore
dotnet pack $PROJECT_DIR -c Release --no-build       # Skip redundant build
```

The `--no-restore` and `--no-build` flags prevent repeating expensive operations. For .NET global tools especially, proper dependency isolation matters—you want to ensure your tool works across different .NET SDK versions, which is why this workflow tests against both 8.x and 9.x.

**NuGet Publishing with Idempotency:**
```bash
dotnet nuget push $NUPKG_DIR/*.nupkg \
  --skip-duplicate
```

The `--skip-duplicate` flag means you can safely re-run the workflow without errors if a version was already published. This is crucial for reliability—sometimes you need to retry a build due to temporary network issues or API timeouts.

**Automated GitHub Releases:**
```yaml
- name: Create GitHub Release
  uses: softprops/action-gh-release@v2
  with:
    tag_name: v${{ steps.bump.outputs.version }}
    generate_release_notes: true
```

This automatically creates a GitHub release with auto-generated release notes based on commit messages since the last release. Users see a clear changelog without manual effort, and the release is properly associated with the NuGet package version.

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

**Key Learnings & Best Practices** 💡

Building this .NET global tool taught me several valuable lessons applicable to any command-line tool project:

1. **YoutubeExplode Library Maturity**: Version 6.5.4 resolved transcript extraction issues that plagued earlier versions. Always verify library versions match your use case requirements.
2. **.NET Global Tool Packaging**: The `PackAsTool` property, `ToolCommandName`, and `PackageReadmeFile` are crucial for NuGet discoverability. Missing these makes your tool harder to find.
3. **Multi-targeting Strategy**: Supporting both .NET 8 and 9 simultaneously ensures broader compatibility across development environments and CI/CD pipelines.
4. **Flexible Input/Output Design**: Supporting both command-line arguments and stdin (JSON) makes your tool more versatile for automation, scripting, and pipeline integration.
5. **Intelligent Caption Selection**: Smart ordering logic (English preference → auto-generated fallback) dramatically improves user experience compared to simple "first available" approaches.
6. **Semantic Versioning in CI/CD**: Automating patch/minor/major version bumps reduces manual work and ensures consistency across releases.

**Future Enhancements** 🔮

Potential improvements for future versions:

- Support for downloading specific time ranges
- Batch processing multiple URLs
- Custom output formats (CSV, XML)
- Integration with subtitle file formats (SRT, VTT)
- Translation support for non-English captions

**Development Velocity with Modern AI Tooling** ⚡

What stands out about this project is the development speed enabled by modern AI assistance. From initial concept through architecture, implementation, testing, and NuGet publication took just a few hours - something that would have required days of work just five years ago.

**The AI-Assisted Development Workflow** 🤖

This .NET global tool project showcased the power of combining multiple AI tools effectively:

- **Claude Code**: Handled core architecture decisions, .NET-specific patterns, error handling strategies, and GitHub Actions CI/CD pipeline configuration. Particularly valuable for getting the `.csproj` packaging configuration correct on the first attempt.
- **GitHub Copilot**: Excelled at generating repetitive code patterns, JSON serialization boilerplate, regex text normalization functions, and test scaffold code.
- **MCPs (Model Context Protocol)**: Provided seamless integration between different AI tools and development contexts, making the workflow feel natural rather than fragmented.

**The Human-AI Partnership in Practice** 🤝

The most interesting insight wasn't that AI wrote the code, but how it transformed the development process itself:

1. **Design-First Development**: Instead of iterating through implementation details, focus shifted to user experience and clean data flow architecture.
2. **Documentation-Driven Development**: Writing this technical blog post in parallel with coding helped clarify requirements and catch edge cases early.
3. **Risk-Free Exploration**: AI assistance made it easy to try different architectural approaches without the usual "sunk cost" hesitation.

**What This Means for .NET Developers** 🚀

This project represents a new normal in software development—where the bottleneck shifts from typing code to thinking through problems and user needs. The combination of AI coding assistants, intelligent build toolchains (GitHub Actions, NuGet), and human creativity is genuinely transformative.

For developers hesitant about AI tools: they're not replacing you; they're amplifying your ability to solve meaningful problems quickly. The future belongs to developers who can effectively collaborate with AI to build better software faster.

**Get Started Building Your Own .NET Global Tool** 📦

Ready to create your own command-line tool and publish it to NuGet? Install ytx to see a working example:

```powershell
dotnet tool install -g solrevdev.ytx
ytx "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
```

Or [explore the source code on GitHub](https://github.com/solrevdev/solrevdev.ytx) to see the complete implementation.

Success! 🎉