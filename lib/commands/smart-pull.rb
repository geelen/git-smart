#Calling `git smart-pull` will fetch remote tracked changes
#and reapply your work on top of it. It's like a much, much
#smarter version of `git pull --rebase`.
#
#For some background as to why this is needed, see [my blog
#post about the perils of rebasing merge commits](http://notes.envato.com/developers/rebasing-merge-commits-in-git/)
#
#This is how it works:

GitSmart.register 'smart-pull' do |repo, args|
  #Let's begin!
  branch = repo.current_branch
  start "Starting: smart-pull on branch '#{branch}'"

  #Let's not have any arguments, fellas.
  warn "Ignoring arguments: #{args.inspect}" if !args.empty?

  #Try grabbing the tracking remote from the config. If it doesn't exist,
  #notify the user and default to 'origin'
  tracking_remote = repo.tracking_remote ||
    note("No tracking remote configured, assuming 'origin'") ||
    'origin'

  # Fetch the remote. This pulls down all new commits from the server, not just our branch,
  # but generally that's a good thing. This is the only communication we need to do with the server.
  repo.fetch!(tracking_remote)

  #Try grabbing the tracking branch from the config. If it doesn't exist,
  #notify the user and choose the branch of the same name
  tracking_branch = repo.tracking_branch ||
    note("No tracking branch configured, assuming '#{branch}'") ||
    branch

  #Check the specified upstream branch exists. Fail if it doesn't.
  upstream_branch = "#{tracking_remote}/#{tracking_branch}"
  failure("Upstream branch '#{upstream_branch}' doesn't exist!") if !repo.exists?(upstream_branch)

  #Grab the SHAs of the commits we'll be working with.
  head = repo.sha('HEAD')
  remote = repo.sha(upstream_branch)

  #If both HEAD and our upstream_branch resolve to the same SHA, there's nothing to do!
  if head == remote
    puts "Neither your local branch '#{branch}', nor the remote branch '#{upstream_branch}' have moved on."
    success "Already up-to-date"
  else
    #Find out where the two branches diverged using merge-base. It's what git
    #uses internally.
    merge_base = repo.merge_base(head, remote)

    #Report how many commits are new locally, since that's useful information.
    new_commits_locally = repo.rev_list(merge_base, head)
    if !new_commits_locally.empty?
      note "You have #{new_commits_locally.length} new commit#{'s' if new_commits_locally.length != 1} on '#{branch}'."
    end

    #By comparing the merge_base to both HEAD and the remote, we can
    #determine whether both or only one have moved on.
    #If the remote hasn't changed, we're already up to date, so there's nothing
    #to pull.
    if merge_base == remote
      puts "Remote branch '#{upstream_branch}' has not moved on."
      success "Already up-to-date"
    else
      #If the remote _has_ moved on, we actually have some work to do:
      #
      #First, report how many commits are new on remote. Because that's useful information, too.
      new_commits_on_remote = repo.rev_list(merge_base, remote)
      is_are, s_or_not = (new_commits_on_remote.length == 1) ? ['is', ''] : ['are', 's']
      note "There #{is_are} #{new_commits_on_remote.length} new commit#{s_or_not} on '#{upstream_branch}'."

      #Next, detect if there are local changes and stash them.
      stash_required = repo.dirty?
      if stash_required
        note "Working directory dirty. Stashing..."
        repo.stash!
      end

      success_messages = []

      #Then, bring the local branch up to date.
      #
      #If our local branch hasn't moved on, that's easy - we just need to fast-forward.
      if merge_base == head
        puts "Local branch '#{branch}' has not moved on. Fast-forwarding..."
        repo.fast_forward!(upstream_branch)
        success_messages << "Fast forwarded from #{head[0,7]} to #{remote[0,7]}"
      else
        #If our local branch has new commits, we need to rebase them on top of master.
        #
        #When we rebase, we use `git rebase -p`, which attempts to recreate merges
        #instead of ignoring them. For a description as to why, see my [blog post](http://notes.envato.com/developers/rebasing-merge-commits-in-git/).
        note "Both local and remote branches have moved on. Branch 'master' needs to be rebased onto 'origin/master'"
        repo.rebase_preserving_merges!(upstream_branch)
        success_messages << "HEAD moved from #{head[0,7]} to #{repo.sha('HEAD')[0,7]}."
      end

      #If we stashed before, pop now.
      if stash_required
        note "Reapplying local changes..."
        repo.stash_pop!
      end

      #Use smart-log to show the new commits.
      GitSmart.run('smart-log', ["#{merge_base}..#{upstream_branch}"])

      #Display a nice completion message in large, friendly letters.
      success ["All good.", *success_messages].join(" ")
    end

    #Still to do:
    #
    #* Ensure ORIG_HEAD is correctly set at the end of each run.
    #* If the rebase fails, and you've done a stash, remind the user to unstash

  end
end
