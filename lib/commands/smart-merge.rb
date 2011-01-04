GitSmart.register 'smart-merge' do |repo, args|
  # A smart-merge is quite simply, a non-fast-forward merge with a stash push/pop, if required.
  current_branch = repo.current_branch
  start "Starting: smart-merge on branch '#{current_branch}'"

  merge_target = args.shift
  failure "Usage: git smart-merge ref" if !merge_target

  merge_sha = repo.sha(merge_target)
  failure "Branch to merge #{merge_target.inspect} not recognised by git!" if !merge_sha


end
