---
layout: post
title: Evolving SeedFolder with GitHub Copilot - From Personal Tool to Multi-Template System
description: How GitHub Copilot helped transform a simple dotfile copier into a comprehensive project scaffolding tool with multiple templates and cross-platform support
summary: How I used GitHub Copilot to evolve SeedFolder from a dotfile copier into a flexible, multi-template scaffolding tool with cross-platform support, better UX, and CI improvements.
cover_image: /images/seedfolder-evolution-cover.svg
tags:
- dotnet-global-tools
- github-copilot
- dotnet
- csharp
- productivity
- templates

---
**Overview** ☀

It's been over 4 years since I first published my [.NET Core Global Tool](/2020/10/05/creating-a.net-core-global-tool.html) blog post about creating SeedFolder.

What started as a simple tool to copy my personal dotfiles has evolved into something much more powerful and hopefully eventually will be useful to the broader developer community.

The original version was quite limited - it basically just copied my specific `.editorconfig`, `.gitignore`, and other dotfiles to new project folders. While this was useful for me, it wasn't particularly helpful to other developers who might have different preferences or work with different technology stacks.

**The Evolution Journey** 🌱

Over the years, I've made several significant improvements to SeedFolder, particularly leveraging GitHub Copilot to help accelerate development and implement features I might not have found time to build otherwise.

**Upgrading Through .NET LTS Versions** ⬆️

One of the consistent maintenance tasks has been keeping the tool updated with each .NET LTS release. For example, [upgrading to more currwnt .NET versions](https://github.com/solrevdev/seedfolder/pull/4) involved updating the target framework and ensuring compatibility:

```diff
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
-    <TargetFramework>net6.0</TargetFramework>
    <!-- Multi-targeting for backward compatibility -->
+   <TargetFrameworks>net8.0;net9.0</TargetFrameworks>
    <PackAsTool>true</PackAsTool>
    <ToolCommandName>seedfolder</ToolCommandName>
    <!-- ... other properties -->
  </PropertyGroup>
</Project>
```

The tool now uses multi-targeting to support various .NET SDKs, ensuring users can install and use it regardless of which .NET version they have installed.

**GitHub Copilot as a Development Partner** 🤖

The real transformation happened when I started using GitHub Copilot - both from the web interface and my iOS app - to help implement more ambitious features. This was a game-changer for a side project that I rarely had dedicated time to improve.

**My AI Development Journey** 🛤️

This project coincided with my own evolution in AI-assisted development. Over the past couple of years, I've progressed through several stages:

1. **Context Sharing Era**: Using tools like Repomix to bundle codebase snippets for web-based ChatGPT, Claude, and Gemini conversations
2. **Desktop Integration**: Adopting dedicated ChatGPT and Claude desktop clients for more seamless workflows  
3. **IDE-Native AI**: Integrating GitHub Copilot directly into VSCode, progressing through OpenAI's GPT 4.0, 4.1, and eventually to GPT-5 and Claude Sonnet 4
4. **Terminal-First Development**: Embracing agentic terminal clients like Warp Terminal, Claude Code, and Codex for more direct development interaction

Today, my workflow splits between contexts: during work hours, I rely on VSCode with GitHub Copilot and terminal-based AI clients. But evenings and weekends - when I'm often watching TV with my phone in hand - GitHub's web and iOS Copilot interfaces became the perfect tools for iterating on side projects through issue-driven development.

This hybrid approach proved ideal for SeedFolder's evolution: I could sketch out features and improvements during downtime, then implement them through focused GitHub issue conversations. The combination of accessibility and power made consistent progress possible on a project that might otherwise have stagnated between day job commitments.

Here's how the process typically worked:

1. **Issue Creation**: I'd create a GitHub issue describing what I wanted to achieve
2. **Copilot Collaboration**: Using GitHub Copilot from the web or iOS app, I'd work through the implementation
3. **Iterative Development**: Copilot would suggest implementations, and we'd refine them together

For example, [Issue #9](https://github.com/solrevdev/seedfolder/issues/9) outlined a comprehensive roadmap for turning SeedFolder into a proper template system. What would have taken me weeks to implement manually, Copilot helped me accomplish in focused sessions.

**From Single Template to Multi-Template System** 📂

The biggest transformation was moving from a single set of dotfiles to a comprehensive template system. [Pull Request #10](https://github.com/solrevdev/seedfolder/pull/10) introduced support for six different project types:

```bash
# Interactive mode - prompts for template selection
seedfolder

# Specific template usage
seedfolder --template dotnet MyNewProject
seedfolder --template node MyNodeApp
seedfolder --template python data-analysis
seedfolder --template ruby rails-app
seedfolder --template markdown blog-posts
seedfolder --template universal generic-project

# Preview what would be created
seedfolder --dry-run --template node MyApp
```

Each template now includes carefully curated files appropriate for that project type:

- **dotnet**: .editorconfig, .gitignore for C#, omnisharp.json
- **node**: package.json template, .nvmrc, npm-specific .gitignore
- **python**: requirements.txt, .python-version, Python .gitignore
- **ruby**: Gemfile template, .ruby-version, Ruby .gitignore
- **markdown**: Basic structure for documentation projects
- **universal**: Generic files useful across all project types

**Enhanced User Experience** ✨

The tool is now much more user-friendly and customizable. Some key improvements include:

**Interactive Mode**:
```bash
$ seedfolder
? Select a project template: (Use arrow keys)
❯ dotnet - .NET applications with C# configuration
  node - Node.js applications with npm setup
  python - Python projects with pip requirements
  ruby - Ruby applications with Bundler setup
  markdown - Documentation and static sites
  universal - Generic template for any project type
```

**Better CLI Interface**:
```bash
# All the standard options you'd expect
seedfolder --help
seedfolder --version
seedfolder --list-templates
seedfolder --template dotnet --output ./projects MyApi
```

**Cross-Platform Compatibility**: The tool now works seamlessly across Windows, macOS, and Linux, with platform-specific optimizations.

**Improved CI/CD Pipeline** 🔄

[Pull Request #16](https://github.com/solrevdev/seedfolder/pull/16) addressed CI workflow issues and simplified the build process:

```yaml
# yaml-language-server: $schema=https://json.schemastore.org/github-workflow.json

name: CI

on:
    push:
        branches:
            - master
            - release/*
        paths-ignore:
          - '**/*.md'
          - '**/*.gitignore'
          - '**/*.gitattributes'
    pull_request:
        branches:
            - master
            - release/*
        paths-ignore:
            - '**/*.md'
            - '**/*.gitignore'
            - '**/*.gitattributes'
jobs:
    build:
        if: github.event_name == 'push' && contains(toJson(github.event.commits), '***NO_CI***') == false && contains(toJson(github.event.commits), '[ci skip]') == false && contains(toJson(github.event.commits), '[skip ci]') == false
        runs-on: ubuntu-latest
        env:
          ACTIONS_ALLOW_UNSECURE_COMMANDS: true
          DOTNET_CLI_TELEMETRY_OPTOUT: 1
          DOTNET_SKIP_FIRST_TIME_EXPERIENCE: 1
          DOTNET_NOLOGO: true
          DOTNET_GENERATE_ASPNET_CERTIFICATE: false
          DOTNET_ADD_GLOBAL_TOOLS_TO_PATH: false
          DOTNET_MULTILEVEL_LOOKUP: 0

        steps:
            - name: checkout code
              uses: actions/checkout@v4

            - name: setup .net core sdk
              uses: actions/setup-dotnet@v4
              with:
                  dotnet-version: |
                    8.0.x
                    9.0.x

            - name: dotnet build
              run: dotnet build solrevdev.seedfolder.sln --configuration Release

            - name: run integration tests
              run: ./tests/integration-test.sh

            - name: dotnet pack
              run: dotnet pack solrevdev.seedfolder.sln -c Release --no-build --include-source --include-symbols

            - name: setup nuget
              if: github.event_name == 'push' && github.ref == 'refs/heads/master'
              uses: nuget/setup-nuget@v1
              with:
                  nuget-version: latest

            - name: Publish NuGet
              if: github.event_name == 'push' && github.ref == 'refs/heads/master'
              uses: rohith/publish-nuget@v2.1.1
              with:
                PROJECT_FILE_PATH: src/solrevdev.seedfolder.csproj # Relative to repository root
                NUGET_KEY: ${{secrets.NUGET_API_KEY}} # nuget.org API key
                PACKAGE_NAME: solrevdev.seedfolder


```

**The Power of AI-Assisted Development** 🚀

What I found particularly interesting about working with GitHub Copilot was how it helped me think through problems I might not have tackled otherwise. For instance:

- **Error Handling**: Copilot suggested comprehensive error handling patterns I wouldn't have thought to implement
- **Cross-Platform Considerations**: It caught platform-specific issues early in development
- **User Experience**: Proposed CLI interface improvements that made the tool much more pleasant to use
- **Testing Strategies**: Suggested test cases and scenarios I hadn't considered

Here's an example of how Copilot helped implement the template system using enums and pattern matching:

```csharp
// Template metadata structure for future extensibility
internal record TemplateFile(string ResourceName, string FileName, string Description = "");

// Enum for supported project types
internal enum ProjectType
{
    Dotnet, Node, Python, Ruby, Markdown, Universal
}

private static bool TryParseProjectType(string input, out ProjectType projectType)
{
    projectType = input switch
    {
        "dotnet" or "net" or "csharp" => ProjectType.Dotnet,
        "node" or "nodejs" or "javascript" or "js" => ProjectType.Node,
        "python" or "py" => ProjectType.Python,
        "ruby" or "rb" => ProjectType.Ruby,
        "markdown" or "md" or "docs" => ProjectType.Markdown,
        "universal" or "basic" or "minimal" => ProjectType.Universal,
        _ => ProjectType.Dotnet
    };

    return input is "dotnet" or "net" or "csharp" or "node" or "nodejs"
        or "javascript" or "js" or "python" or "py" or "ruby" or "rb"
        or "markdown" or "md" or "docs" or "universal" or "basic" or "minimal";
}

private static TemplateFile[] GetTemplateFiles(ProjectType projectType)
{
    return projectType switch
    {
        ProjectType.Node => GetNodeTemplate(),
        ProjectType.Python => GetPythonTemplate(),
        ProjectType.Ruby => GetRubyTemplate(),
        ProjectType.Markdown => GetMarkdownTemplate(),
        ProjectType.Universal => GetUniversalTemplate(),
        _ => GetDotnetTemplate()
    };
}
```

**Next Steps: The Marketplace Vision** 🏪

The next major evolution is planned around [Issue #15](https://github.com/solrevdev/seedfolder/issues/15) - creating a template marketplace. This will allow the community to share and install custom templates:

```bash
# Future marketplace commands
seedfolder marketplace search angular
seedfolder marketplace install solrevdev/vue-typescript
seedfolder marketplace list --installed
seedfolder marketplace update
```

The marketplace will be hosted as a separate GitHub repository at `solrevdev/seedfolder-marketplace` with this structure:

```text
solrevdev/seedfolder-marketplace/
├── templates/
│   ├── angular/
│   │   ├── template.json
│   │   └── files/
│   ├── vue/
│   └── rust/
├── registry.json
└── README.md
```

This will enable developers to:
- Share their own project templates
- Override built-in templates with their preferences
- Fork the marketplace for team-specific template collections
- Contribute improvements back to the community

**Installation and Usage Today** 📦

The current version is available on NuGet and much more capable than the original:

```bash
# Install the latest version
dotnet tool install --global solrevdev.seedfolder

# Create a new .NET project with proper scaffolding
seedfolder --template dotnet MyWebApi

# Interactive mode for template selection
seedfolder MyNewProject

# See all available options
seedfolder --help
```

**Lessons Learned** 💡

Working on SeedFolder's evolution taught me several valuable lessons:

1. **AI as a Coding Partner**: GitHub Copilot isn't just an autocomplete tool - it's a thinking partner that can help you explore solutions you might not consider
2. **Incremental Improvement**: Small, consistent improvements over time can transform a simple tool into something genuinely useful
3. **Community Focus**: Building for your own needs first is fine, but thinking about broader use cases makes tools more valuable
4. **Template Systems**: Flexibility through templates is much more powerful than hardcoded configurations
5. **Context-Driven Development**: Different AI tools excel in different contexts - terminal clients for focused coding sessions, mobile interfaces for planning and ideation

The transformation from a personal dotfile copier to a comprehensive project scaffolding tool shows how AI assistance can help maintain and evolve side projects that might otherwise stagnate. The key insight was finding the right AI tool for each development context rather than trying to force a single solution across all scenarios.

Watch out for the next steps as I work on the marketplace functionality - the goal is to make SeedFolder not just more useful, but a platform for the community to share their own project setup best practices.

*If you're curious about the specific workflows and tools that made this multi-context AI development approach work, I'm planning a follow-up post diving deeper into the practical setup and decision-making process behind choosing the right AI tool for different development scenarios.*

Success! 🎉
