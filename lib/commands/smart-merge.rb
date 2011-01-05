#Calling `git smart-merge branchname` will, quite simply, perform a
#non-fast-forward merge wrapped in a stash push/pop, if that's required.
#With some helpful extra output.
GitSmart.register 'smart-merge' do |repo, args|
  #Let's begin!
  current_branch = repo.current_branch
  start "Starting: smart-merge on branch '#{current_branch}'"

  #Grab the merge_target the user specified
  merge_target = args.shift
  failure "Usage: git smart-merge ref" if !merge_target

  #Make sure git can resolve the reference to the merge_target
  merge_sha = repo.sha(merge_target)
  failure "Branch to merge '#{merge_target}' not recognised by git!" if !merge_sha

  #If the SHA of HEAD and the merge_target are the same, we're trying to merge
  #the same commit with itself. Which is madness!
  head = repo.sha('HEAD')
  if merge_sha == head
    note "Branch '#{merge_target}' has no new commits. Nothing to merge in."
    success 'Already up-to-date.'
  else
    #Determine the merge-base of the two commits, so we can report some useful output
    #about how many new commits have been added.
    merge_base = repo.merge_base(head, merge_sha)

    #Report the number of commits on merge_target we're about to merge in.
    new_commits_on_merge_target = repo.rev_list(merge_base, merge_target)
    puts "Branch '#{merge_target}' has diverged by #{new_commits_on_merge_target.length} commit#{'s' if new_commits_on_merge_target.length != 1}. Merging in."

    #Determine if our branch has moved on.
    if head == merge_base
      #Note: Even though we _can_ fast-forward here, it's a really bad idea since
      #it results in the disappearance of the branch in history. For a good discussion
      #on this topic, see this [StackOverflow question](http://stackoverflow.com/questions/2850369/why-uses-git-fast-forward-merging-per-default).
      note "Branch '#{current_branch}' has not moved on since '#{merge_target}' diverged. Running with --no-ff anyway, since a fast-forward is unexpected behaviour."
    else
      #Report how many commits on our branch since merge_target diverged.
      new_commits_on_branch = repo.rev_list(merge_base, head)
      puts "Branch '#{current_branch}' has #{new_commits_on_branch.length} new commit#{'s' if new_commits_on_merge_target.length != 1} since '#{merge_target}' diverged."
    end

    #Before we merge, detect if there are local changes and stash them.
    stash_required = repo.dirty?
    if stash_required
      note "Working directory dirty. Stashing..."
      repo.stash!
    end

    #Perform the merge, using --no-ff.
    repo.merge_no_ff!(merge_target)

    #If we stashed before, pop now.
    if stash_required
      note "Reapplying local changes..."
      repo.stash_pop!
    end

    #Display a nice completion message in large, friendly letters.
    success "All good. Created merge commit #{repo.sha('HEAD')[0,7]}."
  end
end
