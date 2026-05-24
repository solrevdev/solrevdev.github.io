---
published: false
layout: post
title: Building macOS Screen Narrator - a .NET Global Tool for Narrated Screen Recordings
description: How I built macOS Screen Narrator, a .NET 10 global tool that turns silent macOS screen recordings into narrated MP4s using FFmpeg, an LLM-assisted timing pass, and the built-in macOS say command.
summary: Deep dive into building macOS Screen Narrator, a local .NET 10 global tool for preparing LLM-timed narration manifests and rendering narrated MP4s from silent macOS screen recordings. Covers the prep/render workflow, FFmpeg frame extraction, scene-change hints, macOS speech synthesis, JSON segment manifests, and testable CLI design.
cover_image: /images/macos-screen-narrator-cover.svg
tags:
- dotnet
- dotnet-10
- dotnet-global-tools
- csharp
- macos
- ffmpeg
- screen-recording
- video
- llm
- cli
---
**Overview** ☀

I wanted a repeatable local workflow for turning silent macOS screen recordings into narrated videos without opening a full video editor every time. The result is **macOS Screen Narrator**, a .NET 10 global tool that prepares a screen recording for narration, hands the timing problem to an LLM, and renders a narrated MP4 with FFmpeg and the built-in macOS `say` command.

The tool is intentionally local-first. It works with files on disk, generated review frames, simple JSON manifests, and a render command that can be rerun after small timing edits.

**The Problem** 🎯

Silent screen recordings are quick to capture, but tedious to polish. The hard part is not just generating speech; it is lining each spoken line up with visible UI actions.

I wanted a workflow that could:

1. Analyze a `.mov` or `.mp4` screen recording.
2. Extract useful frames and scene-change hints.
3. Generate a self-contained prompt for timing narration.
4. Let an LLM choose segment start times from the visual evidence.
5. Render the final narrated MP4 locally.
6. Keep the timing manifest editable so the last mile is fast.

**What I Built** 🏗️

`macos-screen-narrator` is a .NET 10 command-line tool packaged as a global tool under:

```bash
solrevdev.macos-screen-narrator
```

The command name is:

```bash
macos-screen-narrator
```

Core capabilities:

1. Check local prerequisites with `doctor`.
2. Prepare recordings with `prep` by extracting frames and scene-change metadata.
3. Generate an `llm-prompt.md` file plus a JSON segment template.
4. Render an existing work folder with `render`.
5. Render directly from a video and `segments.json` with `render-video`.
6. Support a convenience `create` path for rough automatic drafts.

**The LLM Handoff** 🤖

The important design choice is that the LLM does not need to run the video pipeline. The tool creates a work folder with enough evidence for a separate timing pass:

```text
work/<run-name>/
  source.json
  context.md
  analysis.json
  frames.csv
  scene-changes.csv
  llm-prompt.md
  segments.template.json
  frames/
  scene-frames/
```

The LLM reviews the prompt, sampled frames, and scene-change frames, then returns JSON in a simple shape:

```json
{
  "title": "Demo video",
  "source": "/path/to/screen-recording.mov",
  "voice": "Jamie (Premium)",
  "rate": 175,
  "segments": [
    {
      "start": 0.5,
      "text": "Open the page and begin the workflow."
    }
  ]
}
```

That file becomes `segments.json`. From there, rendering is deterministic and repeatable.

**Implementation Highlights** ⚙️

- **FFmpeg and FFprobe integration**: video duration, codecs, frame extraction, scene detection, audio/video muxing, and final MP4 output.
- **macOS speech synthesis**: narration is generated with `say`, keeping the tool dependency-light on macOS.
- **Editable manifests**: `{ start, text }` segments make timing changes simple.
- **Prompt-friendly artifacts**: CSV files and relative frame paths make the LLM review step easy to inspect.
- **CLI without heavy framework dependencies**: option parsing stays small and explicit.
- **Test seams around process execution**: `ICommandRunner`, `IClock`, and `TextWriter` make command behavior easy to test without invoking FFmpeg in unit tests.

**Example Workflow** 🚀

Prepare a recording:

```bash
macos-screen-narrator prep \
  "/path/to/screen-recording.mov" \
  --context-file notes.md \
  --directions "Keep the narration concise and align each line to the visible UI action." \
  --workdir work \
  --name demo-prep
```

Then ask a local LLM to inspect `work/demo-prep/llm-prompt.md` and the referenced JPEG frames, returning only the requested JSON. Save that as:

```text
work/demo-prep/segments.json
```

Render the narrated video:

```bash
macos-screen-narrator render-video \
  "/path/to/screen-recording.mov" \
  work/demo-prep/segments.json \
  work/demo-prep/output/demo-narrated.mp4
```

If the narration lands early or late, edit `segments.json` and rerun the same render command.

**Testing Strategy** 🧪

The tests focus on the parts that should stay stable:

- bare video paths defaulting to the `create` command
- explicit commands staying explicit
- segment normalization and sorting
- narration aliases in JSON input
- generated LLM prompts including frame paths, scene paths, and output rules

The heavier video pipeline stays behind command-runner abstractions, which keeps unit tests fast while leaving room for smoke tests with real FFmpeg and macOS voices.

**NuGet and CI Path** 📦

The project is structured for packaging as a .NET global tool:

```bash
dotnet restore
dotnet build
dotnet test
dotnet pack src/MacosScreenNarrator.Tool -c Release
```

Once published, installation should look like:

```bash
dotnet tool install --global solrevdev.macos-screen-narrator
macos-screen-narrator doctor
```

And updates:

```bash
dotnet tool update --global solrevdev.macos-screen-narrator
```

Source repository:
[https://github.com/solrevdev/solrevdev.macos-screen-narrator](https://github.com/solrevdev/solrevdev.macos-screen-narrator)

**What’s Next** 🔮

Before publishing, I still need to finish the repository housekeeping: move the tool out of its dated staging folder, give it the final project directory name, add the GitHub remote, push the code, and wire up package publishing.

After that, the improvements I want to explore are:

- richer validation for overlapping or too-dense narration segments
- better defaults for voice selection and speech rate
- optional before/after quality checks against a reference render
- CI smoke tests that verify the package can be packed and installed locally

Success! 🎉
