---
published: false
layout: post
title: Building dotnet-crap - Change Risk Anti-Patterns for .NET
description: How I built dotnet-crap, a .NET 10 global tool that combines cyclomatic complexity and test coverage into CRAP scores to surface risky C# methods with actionable advice.
summary: Deep dive into building dotnet-crap, a .NET 10 global tool for CRAP (Change Risk Anti-Patterns) analysis. Covers Roslyn-based complexity analysis, Cobertura/LCOV coverage matching, CI-friendly output formats, risk thresholds, and practical workflows for refactoring and test prioritization.
cover_image: /images/dotnet-crap-cover.svg
image: /images/dotnet-crap-cover.png
tags:
- dotnet
- dotnet-10
- dotnet-global-tools
- csharp
- roslyn
- code-quality
- test-coverage
- cyclomatic-complexity
- ci-cd
---
**Overview** ☀

I wanted a practical way to spot risky C# code paths quickly: methods that are both complex and under-tested. The result is **dotnet-crap**, a .NET 10 global tool that computes **CRAP** (**Change Risk Anti-Patterns**), combines complexity with coverage, and ranks methods by change risk so you can focus on the highest-value fixes first.

This project started from a research-and-build prompt (initially in Claude, then continued in Codex): study CRAP prior art, borrow heavily from existing implementations and ideas, then adapt those patterns into a modern .NET CLI tool for local engineering workflows and CI quality gates.

**The Problem** 🎯

Cyclomatic complexity alone is noisy. Coverage alone is incomplete. The useful signal is their combination:

```text
CRAP(m) = comp(m)^2 * (1 - cov(m)/100)^3 + comp(m)
```

Where:
- `comp(m)` is method cyclomatic complexity
- `cov(m)` is method coverage percentage

High CRAP means code is difficult to reason about, insufficiently protected by tests, or both.

**Prior Art and References** 📚

The implementation direction was informed by:

- [cargo-crap article](https://minikin.me/blog/cargo-crap)
- [vscode-crap-metrics](https://github.com/RamtejSudani/vscode-crap-metrics)
- [Artima CRAP discussion](https://www.artima.com/weblogs/viewpost.jsp?thread=215899)
- [cargo-crap repository](https://github.com/minikin/cargo-crap)

These helped validate the model and UX patterns; the .NET tooling and implementation details were built specifically for C# workflows.

**What I Built** 🏗️

`dotnet-crap` is packaged as a .NET global tool (`solrevdev.dotnet-crap`) targeting **.NET 10** and command name:

```bash
dotnet-crap
```

Core capabilities:

1. Parse C# source with Roslyn and calculate per-method cyclomatic complexity.
2. Load and merge coverage from **Cobertura XML** and **LCOV**.
3. Match coverage to methods safely by file and line-range heuristics.
4. Compute CRAP score + risk banding for each method.
5. Emit reports in multiple formats: `human`, `json`, `markdown`, `github`.
6. Support CI policy gates with `--threshold`, `--fail-above`, and `--require-coverage`.
7. Support baseline and change-scoped checks (`--baseline`, `--changed-only`, `--changed-files`).

**Implementation Highlights** ⚙️

- **Roslyn-first analyzer**: dedicated syntax walker for complexity and method extraction.
- **Coverage diagnostics**: detailed input diagnostics and unmatched coverage reporting.
- **Actionable output**: ranked entries with method location, complexity, coverage match status, and CRAP score.
- **Operational flexibility**: exclusions, config file support (`.dotnet-crap.json`), top-N filtering, output to artifact files.
- **CI-ready GitHub mode**: emits workflow annotations so risky methods appear directly in PR checks.

**Testing Strategy** 🧪

The test suite is broad and split across focused categories:

- parser and CLI option behavior
- CRAP calculation and complexity rules
- coverage parsing and matching
- reporter output shape and formatting
- end-to-end command behavior and exit-code policy checks

This keeps the tool reliable both for local usage and automated pipelines.

**How It Helps in Practice** 🚀

Typical workflow:

```bash
dotnet test --collect:"XPlat Code Coverage" --results-directory ./TestResults
dotnet-crap ./src --coverage "TestResults/**/coverage.cobertura.xml" --format json --output crap.json --top 20
```

Then take the top-ranked methods and choose a strategy:
- low coverage + high complexity → add tests first, then refactor
- high coverage + high complexity → prioritize structural refactoring
- unmatched coverage → fix report mapping before trusting quality gates

**NuGet and CI Path** 📦

The project is structured to publish as a global tool (same packaging direction as other solrevdev tools), with local-first testing before release and straightforward CI automation for pack/publish.

Install from NuGet:

```bash
# install
dotnet tool install --global solrevdev.dotnet-crap

# run
dotnet-crap --help

# later updates
dotnet tool update --global solrevdev.dotnet-crap
```

Source repository:
[https://github.com/solrevdev/solrevdev.dotnet-crap](https://github.com/solrevdev/solrevdev.dotnet-crap)

**What’s Next** 🔮

Next improvements I want to explore:

- richer recommendations by method pattern/type
- trend/delta reporting between runs
- tighter PR-focused defaults for changed-files analysis

Success! 🎉
