GitSmart.register 'smart-merge' do |repo, args|
  # A smart-merge is quite simply, a non-fast-forward merge with a stash push/pop, if required.
  current_branch = repo.current_branch
  start "Starting: smart-merge on branch '#{current_branch}'"

  merge_target = args.shift
  failure "Usage: git smart-merge ref" if !merge_target

  merge_sha = repo.sha(merge_target)
  failure "Branch to merge '#{merge_target}' not recognised by git!" if !merge_sha

  head = repo.sha('HEAD')
  if merge_sha == head
    note "Branch '#{merge_target}' has no new commits. Nothing to merge in."
    success 'Already up-to-date.'
  else
    merge_base = repo.merge_base(head, merge_sha)

    new_commits_on_merge_target = repo.rev_list(merge_base, merge_target)
    puts "Branch '#{merge_target}' has diverged by #{new_commits_on_merge_target.length} commit#{'s' if new_commits_on_merge_target.length != 1}. Merging in."

    if head == merge_base
      note "Branch '#{current_branch}' has not moved on since '#{merge_target}' diverged. Running with --no-ff anyway, since a fast-forward is unexpected behaviour."
    else
      puts "Branch '#{current_branch}' has 1 new commit since '#{merge_target}' diverged."
    end

    stash_required = repo.dirty?
    if stash_required
      note "Working directory dirty. Stashing..."
      repo.stash!
    end

    repo.merge!(merge_target)

    if stash_required
      note "Reapplying local changes..."
      repo.stash_pop!
    end

    success "All good. Created merge commit #{repo.sha('HEAD')[0,7]}."
  end
end
