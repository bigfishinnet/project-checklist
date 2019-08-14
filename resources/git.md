# Git Commands and notes

git merge issues can be handled with a three way merge tool caled meld.

If you’d like to use meld for 3-way merges instead of vscode’s 2-way, set up with:
```brew cask install meld
git config --global merge.tool meld```
Then when you have a conflict, run:
```git mergetool```

If you also set your difftool:
```git config --global  diff.guitool meld```
You can also do e.g.
```git difftool master```
instead of just `git diff`.

Other diff/merge tools are available…