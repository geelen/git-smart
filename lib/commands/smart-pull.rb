GitSmart.register 'smart-pull' do |repo, args|
  # Let's begin!
  branch = repo.current_branch
  start "Starting: smart-pull on branch '#{branch}'"

  # Let's not have any arguments, fellas.
  warn "Ignoring arguments: #{args.inspect}" if !args.empty?

  # Try grabbing the tracking remote from the config. If it doesn't exist,
  # notify the user and choose 'origin'
  tracking_remote = repo.tracking_remote ||
    note("No tracking remote configured, assuming 'origin'") ||
    'origin'

  # Fetch the remote. This pulls down all new commits from the server, not just our branch,
  # but generally that's a good thing. This is the only communication we need to do with the server.
  repo.fetch!(tracking_remote)

  # Try grabbing the tracking branch from the config. If it doesn't exist,
  # notify the user and choose the branch of the same name
  tracking_branch = repo.tracking_branch ||
    note("No tracking branch configured, assuming '#{branch}'") ||
    branch

  # Check the upstream branch exists
  upstream_branch = "#{tracking_remote}/#{tracking_branch}"
  failure("Upstream branch '#{upstream_branch}' doesn't exist!") if !repo.exists?(upstream_branch)

  head = repo.sha('HEAD')
  remote = repo.sha(upstream_branch)

  if head == remote
    puts "Neither your local branch '#{branch}', nor the remote branch '#{upstream_branch}' have moved on."
    success "Already up-to-date"
  else
    merge_base = repo.merge_base(head, remote)

    if merge_base == remote
      puts "Remote branch '#{upstream_branch}' has not moved on."
      success "Already up-to-date"
    else
      new_commits_on_remote = repo.rev_list(merge_base, remote)
      is_are, s_or_not = (new_commits_on_remote.length == 1) ? ['is', ''] : ['are', 's']
      note "There #{is_are} #{new_commits_on_remote.length} new commit#{s_or_not} on '#{upstream_branch}'."

      stash_required = repo.dirty?
      if stash_required
        note "Working directory dirty. Stashing..."
        repo.stash!
      end

      success_messages = []

      if merge_base == head
        puts "Local branch '#{branch}' has not moved on. Fast-forwarding..."
        repo.fast_forward!(upstream_branch)
        success_messages << "Fast forwarded from #{head[0,7]} to #{remote[0,7]}"
      else
        note "Both local and remote branches have moved on. Branch 'master' needs to be rebased onto 'origin/master'"
        repo.rebase_preserving_merges!(upstream_branch)
        success_messages << "HEAD moved from #{head[0,7]} to #{repo.sha('HEAD')[0,7]}."
      end

      if stash_required
        note "Reapplying local changes..."
        repo.stash_pop!
      end

      success ["All good.", *success_messages].join(" ")
    end

  end
end
