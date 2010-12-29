# git-smart

Adds some additional git commands to add some smarts to your workflow. These commands follow a few guidelines:

0. It should do the 'right thing' in all situations - an inexperienced git user should be guided away from making simple mistakes.
0. It should make every attempt to explain to the user what decisions it has made, and why.
0. All git commands that modify the repository should be shown to the user - hopefully this helps the user eventually learn the underlying git commands, and when they're relevant.
0. All git commands, destructive or not, and their output should be shown to the user with the -v/--verbose flag.

## git-smart-pull

Calling 'git smart-pull' will fetch remote tracked changes and reapply your work on top of it. It's like a much, much smarter version of 'git pull --rebase'.

For some background as to why this is needed, see [my blog post about the perils of rebasing merge commits](https://gist.github.com/591209)

This is how it works:

0. First, determine which remote branch to update from. Use branch tracking config if present, otherwise default to a remote of 'origin' and the same branch name. E.g. 'branchX', by default, tracks 'origin/branchX'.
0. Fetch the remote.
0. Determine what needs to be done:
  - If the remote is a parent of HEAD, there's nothing to do.
  - If HEAD is a parent of the remote, you simply need to reapply any working changes to the new HEAD. Stash, fast-forward, stash pop.
  - If HEAD and the remote have diverged:
    0. stash
    0. rebase -p onto the remote
    0. stash pop
    0. update ORIG\_HEAD to be the previous local HEAD, as expected (rebase -p doesn't set ORIG\_HEAD correctly)
0. Output a summary of what just happened, as well as any new or updated branches that came down with the last fetch.
0. Output a big, green GIT UP GOOD or red GIT UP BAD, depending on how things went.

