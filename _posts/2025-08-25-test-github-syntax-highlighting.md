---
layout: post
title: Test GitHub Syntax Highlighting
author: Test Author
tags:
  - test
  - syntax-highlighting
  - github
---

Testing the new GitHub-like syntax highlighting across different languages to ensure consistency.

## Bash Example

```bash
#!/bin/bash
echo "Testing bash syntax highlighting"
for file in *.txt; do
    if [[ -f "$file" ]]; then
        echo "Processing: $file"
        wc -l "$file"
    fi
done
```

## PowerShell Example

```powershell
Write-Host "Testing PowerShell syntax highlighting"
Get-ChildItem -Path "*.txt" | ForEach-Object {
    if (Test-Path $_.FullName) {
        Write-Output "Processing: $($_.Name)"
        (Get-Content $_.FullName).Count
    }
}
```

## JSON Configuration

```json
{
  "name": "test-project",
  "version": "1.0.0",
  "scripts": {
    "build": "webpack --mode production",
    "test": "jest --coverage"
  },
  "dependencies": {
    "express": "^4.18.0",
    "lodash": "^4.17.21"
  }
}
```

## YAML Configuration

```yaml
name: Build and Test
on:
  push:
    branches: [main, develop]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
```

This should demonstrate consistent highlighting across different code languages.