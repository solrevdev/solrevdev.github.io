---
published: false
---
## homebrew's cellar version of mono breaks omnisharp

So today, I raised a [github issue](https://github.com/OmniSharp/omnisharp-vscode/issues/3477) when opening the result of  `dotnet new mvc` in VSCode would leave the problems window full of approximatley 120 issues and the code windows full of red squiggles. 

Long story short installing the stable version of mono from the official website fixed the problem. Big thanks to the rapid response and answer from [@filipw](https://github.com/filipw)! 

For the full timeline, infomation and screenshots see this twitter thread.

