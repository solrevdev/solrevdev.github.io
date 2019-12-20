---
published: false
---
## homebrew's cellar version of mono breaks omnisharp

So today, I raised a [github issue](https://github.com/OmniSharp/omnisharp-vscode/issues/3477) when opening the result of  `dotnet new mvc` in VSCode would leave the problems window full of approximatley 120 issues and the code windows full of red squiggles. 

Long story short installing the stable version of mono from the official website fixed the problem. Big thanks to the rapid response and answer from [@filipw](https://github.com/filipw)! 

For the full timeline, infomation and screenshots see this twitter thread.

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">who can fix this <a href="https://twitter.com/hashtag/dotnetcore?src=hash&amp;ref_src=twsrc%5Etfw">#dotnetcore</a> <a href="https://twitter.com/hashtag/aspnetcore?src=hash&amp;ref_src=twsrc%5Etfw">#aspnetcore</a> <a href="https://twitter.com/hashtag/vscode?src=hash&amp;ref_src=twsrc%5Etfw">#vscode</a> <a href="https://twitter.com/hashtag/intellisense?src=hash&amp;ref_src=twsrc%5Etfw">#intellisense</a> issue on <a href="https://twitter.com/hashtag/macos?src=hash&amp;ref_src=twsrc%5Etfw">#macos</a>. This is a horrible <a href="https://twitter.com/hashtag/dotnet?src=hash&amp;ref_src=twsrc%5Etfw">#dotnet</a> new mvc experience <a href="https://t.co/cDcIcDJvAi">pic.twitter.com/cDcIcDJvAi</a></p>&mdash; john smith (@solrevdev) <a href="https://twitter.com/solrevdev/status/1207634539469819904?ref_src=twsrc%5Etfw">December 19, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

