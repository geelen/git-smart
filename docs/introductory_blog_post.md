# Introducing git-smart

Recently, I grappled with some unexpected git behaviour when trying to rebase local changes (in particular, merge commits) onto changes from upstream. I blogged about [the solution](http://notes.envato.com/developers/rebasing-merge-commits-in-git/), which is to use `git rebase -p`, but I still didn't feel 'done'.

Most of the dev team here at Envato had begun using my [aliases](https://gist.github.com/590895), but it's not exactly an easy or maintainable solution. I also wanted to do more, such as stashing local changes if required, using fast-forward when possible, and giving more feedback to the user. But most importantly, I wanted to remove the 'magic' from using someone else's aliases and help people understand the decisions behind choosing the 'correct' git command to run.

## A gem is born

Git allows you to add arbitrary commands by placing executables on the path. When you type `git some-custom-command`, git looks for a `git-custom-command` executable on your path and executes it. It can be in any language you want and has no special access to git's internals. It's perfect.

Packaging gems also allows you to generate any number of custom executables onto the path. It's perfect, too!

Putting them together, we get [git-smart](http://github.com/geelen/git-smart):

![git-smart logo](https://github.com/geelen/git-smart/raw/master/docs/images/git-smart.png)

Installing it is as easy as `gem install git-smart` and will give you three new commands, `git smart-pull`, `git smart-merge` and `git smart-log`:

## git smart-pull, the new king of the 'fetch & rebase' workflow

The first command I wrote was designed to expand on the knowledge behind `gup`, giving people a reliably-safe method of pulling updates from the server. I also wanted to give plenty of feedback to the user while it runs, and have the source code as [readable and well-documented as possible](http://github-displayer.heroku.com/geelen/git-smart/raw/master/docs/smart-pull.html).

In a nutshell, this script will detect which branch you want to pull from, assuming origin/same-branch-name if you haven't set up branch-tracking. If the remote branch hasn't moved on, there's nothing to do. If your local branch hasn't moved on, it can simply be fast-forwarded (wrapped in a `git stash`/`git stash pop` if necessary). Only if both the remote and your local branch have moved on, fall back to a `git rebase -p`, again wrapped in a stash/pop if needed. Easy!

This is what it looks like:

![screenshot](https://github.com/geelen/git-smart/raw/master/docs/images/smart-pull-screenshot.png)

## git smart-merge, a non-fast-forward merge wrapped in a stash

If you haven't read ["A successful Git branching model"](http://nvie.com/posts/a-successful-git-branching-model/) by Vincent Driessen, you really should. It's good stuff, and it makes the argument for using the `--no-ff` flag whenever you merge. I won't repeat the arguments here, but I wrote `git smart-merge` to effectively make `--no-ff` the default. It also does a stash/pop if required.

For more detail, take a look at the [annotated source code](http://github-displayer.heroku.com/geelen/git-smart/raw/master/docs/smart-merge.html).

## git smart-log, the most blinged out ASCII log possible

Use this in place of `git log`. I'll let the output speak for itself:

![screenshot](https://github.com/geelen/git-smart/raw/master/docs/images/smart-log-comparison.png)

Check out the [code itself](http://github-displayer.heroku.com/geelen/git-smart/raw/master/docs/smart-log.html). Hat tip to [@ben_h](http://twitter.com/ben_h) for the guts of this.

Also, if you're on OSX and not using [brotherbard's fork of gitx](https://github.com/brotherbard/gitx/wiki), you really should be. It's absolutely the best way to navigate through a git project's history.
