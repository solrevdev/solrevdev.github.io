---
layout: post
title: Upgrading SeedFolder to .NET 10 LTS - Maintaining Multi-Target Framework Support
description: How to upgrade a .NET Global Tool to support .NET 10 while maintaining backward compatibility with .NET 8 and 9
summary: A walkthrough of upgrading SeedFolder to support .NET 10 (LTS) while maintaining full backward compatibility with .NET 8 and 9. Covers multi-targeting, dependency management, CI/CD updates, and testing strategies for .NET global tools.
cover_image: /images/seedfolder-dotnet10-upgrade.svg
tags:
- dotnet-global-tools
- dotnet
- csharp
- dotnet10
- multi-targeting
- nuget
- ci-cd

---
**Overview** ☀

With .NET 10 now released as the latest Long-Term Support (LTS) version, it was time to update [SeedFolder](https://github.com/solrevdev/seedfolder) to support the newest framework while maintaining compatibility with .NET 8 and 9. This post walks through the process of adding .NET 10 support to a global tool, managing dependencies, updating CI/CD pipelines, and ensuring a smooth upgrade path for users.

**Why .NET 10?** 🎯

.NET 10 is the latest LTS release, providing long-term support until November 2028. By adding .NET 10 support alongside existing .NET 8 and 9 targets, SeedFolder users get:

- **Latest LTS**: Long-term support until November 2028
- **Performance improvements**: Built-in performance enhancements from .NET 10
- **Forward compatibility**: Automatic use of the highest installed SDK
- **Backward compatibility**: Continued support for .NET 8 (LTS) and .NET 9 (STS)

The beauty of multi-targeting is that users with any of these SDK versions can install and run the tool. When multiple SDKs are installed, the .NET CLI automatically selects the highest compatible version.

**The Upgrade Process** 🚀

The upgrade was surprisingly straightforward, thanks to .NET's excellent multi-targeting support. Here's the step-by-step process I followed:

**1. Research and Planning** 📚

Before making any changes, I researched the .NET 10 requirements:

- **Target Framework Moniker (TFM)**: `net10.0`
- **SDK Version**: `10.0.100` or later
- **Breaking Changes**: Reviewed Microsoft docs for any breaking changes (none affecting SeedFolder)

I also reviewed the git history to understand how previous SDK upgrades were handled:

```bash
git log --all --grep=".NET" --oneline | head -20
```

This showed that the last major upgrade ([PR #259c452](https://github.com/solrevdev/seedfolder/commit/259c45284d67cb8ab6b1ff2f65d9fe2c5bfa8223)) added .NET 8 and 9 support, following a similar pattern I could replicate.

**2. Update Project File** 🔧

The key change was adding `net10.0` to the `TargetFrameworks` property in the `.csproj` file:

```diff
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
-   <TargetFrameworks>net8.0;net9.0</TargetFrameworks>
+   <TargetFrameworks>net8.0;net9.0;net10.0</TargetFrameworks>
    <LangVersion>latest</LangVersion>
    <ImplicitUsings>enable</ImplicitUsings>
    <PackAsTool>true</PackAsTool>
    <ToolCommandName>seedfolder</ToolCommandName>
    <PackageOutputPath>./nupkg</PackageOutputPath>
    <NoDefaultExcludes>true</NoDefaultExcludes>
-   <Version>1.3.3</Version>
+   <Version>1.4.0</Version>
    <!-- ... other properties ... -->
  </PropertyGroup>
</Project>
```

**Important considerations:**
- Use semicolon-separated list for multiple targets
- Bump the version number for NuGet release (1.3.3 → 1.4.0)
- Maintain existing targets for backward compatibility

**3. Update CI/CD Pipeline** ⚙️

The GitHub Actions workflow needed to install the .NET 10 SDK alongside existing versions:

```diff
- name: setup .net core sdk
  uses: actions/setup-dotnet@v4
  with:
      dotnet-version: |
        8.0.x
        9.0.x
+       10.0.x
```

This ensures the CI pipeline can build all three target frameworks.

**4. Dependency Management** 📦

I ran `dotnet outdated` to check for package updates:

```bash
dotnet tool install -g dotnet-outdated-tool
dotnet outdated
```

This revealed that Figgle (the ASCII art library) had a newer version (0.6.5). However, upon investigation, version 0.6.x introduced breaking changes by splitting fonts into a separate package. Since the upgrade goal was .NET 10 support, not dependency updates, I kept Figgle at 0.5.1 to avoid unnecessary complexity.

**5. Build and Test** ✅

Building for multiple frameworks is straightforward with multi-targeting:

```bash
dotnet build solrevdev.seedfolder.sln --configuration Release
```

Output showed successful builds for all three targets:

```
solrevdev.seedfolder -> src/bin/Release/net8.0/solrevdev.seedfolder.dll
solrevdev.seedfolder -> src/bin/Release/net9.0/solrevdev.seedfolder.dll
solrevdev.seedfolder -> src/bin/Release/net10.0/solrevdev.seedfolder.dll
```

**Testing the Tool Locally** 🧪

Before publishing, I packaged and tested the tool locally:

```bash
# Package the tool
dotnet pack -c Release -o /tmp/seedfolder-test

# Install from local package
dotnet tool uninstall -g solrevdev.seedfolder
dotnet tool install -g --add-source /tmp/seedfolder-test solrevdev.seedfolder

# Verify installation
seedfolder --version
# Output: seedfolder version 1.4.0
```

Then I tested various commands in `/tmp` to ensure functionality:

```bash
# Test dry-run mode
seedfolder --dry-run -t node test-node-app

# Create Python project
seedfolder -t python test-python-app

# Create .NET project
seedfolder --template dotnet test-dotnet-app

# Verify help and template listing
seedfolder --help
seedfolder --list-templates
```

All tests passed successfully! 🎉

**6. Update Documentation** 📝

Documentation updates included:

**README.md** - Updated requirements section:
```diff
## Requirements

- This tool requires **.NET 8.0 or .NET 9.0 SDK** to be installed
+ This tool requires **.NET 8.0, .NET 9.0, or .NET 10.0 SDK** to be installed

- **Runtime**: .NET 8.0 or later
```

**CLAUDE.md** - Updated framework information:
```diff
## Multi-Target Framework Support
- The project targets .NET 8.0 (LTS) and 9.0 (STS)
+ The project targets .NET 8.0 (LTS), 9.0 (STS), and 10.0 (LTS)
+ .NET 10 is the latest LTS release providing long-term support until November 2028.
```

**Multi-Targeting Best Practices** 💡

From this experience, here are some best practices for multi-targeting .NET global tools:

**1. Use Multi-Targeting, Not Multiple Projects**
```xml
<!-- Good: Single project, multiple targets -->
<TargetFrameworks>net8.0;net9.0;net10.0</TargetFrameworks>

<!-- Bad: Multiple projects for different versions -->
```

**2. Maintain LTS Versions**

Keep the previous LTS version (net8.0) alongside the new one. This gives users flexibility and ensures broad compatibility.

**3. Test All Targets**

The NuGet package includes all target frameworks:

```
tools/net8.0/any/solrevdev.seedfolder.dll
tools/net9.0/any/solrevdev.seedfolder.dll
tools/net10.0/any/solrevdev.seedfolder.dll
```

Verify each target builds correctly and the tool runs on all supported SDKs.

**4. Handle Dependencies Carefully**

When upgrading, check if dependencies support all your target frameworks. If a dependency doesn't support your newest target, you have options:

- Keep the dependency at a compatible version
- Use conditional package references for different targets
- Find an alternative package

**5. Update CI/CD First**

Install all SDK versions in your CI pipeline before merging. This catches incompatibilities early:

```yaml
- name: setup .net core sdk
  uses: actions/setup-dotnet@v4
  with:
      dotnet-version: |
        8.0.x
        9.0.x
        10.0.x
```

**The Results** 📊

After merging [PR #17](https://github.com/solrevdev/seedfolder/pull/17), the CI/CD pipeline automatically:

1. Built all three target frameworks
2. Ran integration tests
3. Packaged the NuGet package
4. Published version 1.4.0 to NuGet

Users can now install the updated version:

```bash
dotnet tool update --global solrevdev.seedfolder
seedfolder --version
# Output: seedfolder version 1.4.0
```

The tool automatically uses the highest installed SDK when run, so users with .NET 10 get the latest performance improvements while users on .NET 8 or 9 continue to work seamlessly.

**Framework Support Timeline** 📅

Current support timeline for SeedFolder:

| Framework | Type | Support Until | Status |
|-----------|------|---------------|--------|
| .NET 8.0  | LTS  | November 2026 | ✅ Supported |
| .NET 9.0  | STS  | 18 months     | ✅ Supported |
| .NET 10.0 | LTS  | November 2028 | ✅ Supported |

**Lessons Learned** 🎓

1. **Multi-targeting is powerful**: Adding .NET 10 support while maintaining .NET 8 and 9 compatibility was trivial thanks to proper multi-targeting setup.

2. **Dependency management matters**: Always check dependencies when upgrading. Sometimes staying on older (but stable) dependency versions is the right choice.

3. **Testing is essential**: Local testing before publishing caught issues that automated tests might miss.

4. **Documentation updates are important**: Users need to know what versions are supported and what's changed.

5. **CI/CD automation pays off**: Once configured properly, the entire build-test-publish pipeline runs automatically on merge.

**What's Next?** 🔮

With .NET 10 support in place, SeedFolder is well-positioned for the future. The next areas of focus include:

- Template marketplace functionality ([Issue #15](https://github.com/solrevdev/seedfolder/issues/15))
- Additional project templates based on community feedback
- Enhanced template customization options

The full source code and history of this upgrade are available on [GitHub](https://github.com/solrevdev/seedfolder/pull/17).

**Installation** 📦

Try the latest version with .NET 10 support:

```bash
# Install or update to the latest version
dotnet tool update --global solrevdev.seedfolder

# Create a new project with your favorite template
seedfolder --template python my-new-project

# Or use interactive mode
seedfolder
```

Success! 🎉
