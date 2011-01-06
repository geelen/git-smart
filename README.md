# git-smart

![git-smart logo](https://github.com/geelen/git-smart/raw/master/docs/images/git-smart.png)

Adds some additional git commands to add some smarts to your workflow. These commands follow a few guidelines:

0. It should do the 'right thing' in all situations - an inexperienced git user should be guided away from making simple mistakes.
0. It should make every attempt to explain to the user what decisions it has made, and why.
0. All git commands that modify the repository should be shown to the user - hopefully this helps the user eventually learn the underlying git commands, and when they're relevant.

## Installing

All you need to do is grab the gem:

    gem install git-smart

Git allows custom commands with a simple convention - `git xyz` looks for `git-xyz` on the path, so that'll install a binary for each command e.g. `git-smart-pull`. They'll be removed when you uninstall the gem.

You almost certainly want to run this as well, to allow git commands to be output with colour:

    git config --global color.ui always

Git normally only colours output when being run from the terminal, not from within scripts like these. This sorts that right out.
  
## Get smart!

There's only two commands at this point, but there'll be more!

### smart-pull

Run `git smart-pull` whenever you would have run `git pull`. It doesn't take any arguments, it'll use the tracking branch configuration or assume 'origin/same-branch-name'.

In brief, it'll detect the best way to grab the changes from the server and update your local branch, using a `git rebase -p` if there's no easier way. It'll also stash/pop local changes if need be.

Read what it does in detail: [smart-pull](http://github-displayer.heroku.com/geelen/git-smart/raw/master/docs/smart-pull.html)

### smart-merge

Run `git smart-merge` when you would have run `git merge`. This is basically a wrapper around `git merge --no-ff`, which should have been the default anyway. It also does a stash/pop if required, and reports a bit of helpful output.

Details here: [smart-merge](http://github-displayer.heroku.com/geelen/git-smart/raw/master/docs/smart-merge.html)

## Contributing to git-smart

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011 Glen Maddern. See LICENSE.txt for
further details.
