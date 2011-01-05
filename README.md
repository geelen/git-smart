# git-smart

![git-smart logo](https://github.com/geelen/git-smart/raw/master/docs/images/git-smart.png)

Adds some additional git commands to add some smarts to your workflow. These commands follow a few guidelines:

0. It should do the 'right thing' in all situations - an inexperienced git user should be guided away from making simple mistakes.
0. It should make every attempt to explain to the user what decisions it has made, and why.
0. All git commands that modify the repository should be shown to the user - hopefully this helps the user eventually learn the underlying git commands, and when they're relevant.
0. All git commands, destructive or not, and their output should be shown to the user with the -v/--verbose flag. (not implemented yet)

# Installing

First, grab the gem:

    gem install git-smart

List the commands you can install (currently only the one):

    git-smart list

Install away!

    git-smart install smart-pull

OR

    git-smart install --all

That'll put an executable file for each command in your ~/bin directory if that exists and is on the path, /usr/local/bin otherwise.

# Using

Git allows custom commands with a simple convention - `git xyz` tries to find an executable `git-xyz` on the path. So, to run the commands, simply type

    git smart-pull
    git smart-merge <branchname>

# Documentation

The code for each of these commands has been annotated with comments and rendered with [Rocco](https://github.com/rtomayko/rocco):

- [smart-pull](https://github.com/geelen/git-smart/raw/master/docs/smart-pull.html)
- [smart-merge](https://github.com/geelen/git-smart/raw/master/docs/smart-merge.html)

# Contributing to git-smart

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

# Copyright

Copyright (c) 2011 Glen Maddern. See LICENSE.txt for
further details.
