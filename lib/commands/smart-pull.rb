GitSmart.register 'smart-pull' do |repo, args|
  branch = repo.current_branch

  start "Starting: smart-pull on branch '#{branch}'"
  warn "Ignoring arguments: #{args.inspect}" if !args.empty?

  tracking_remote = repo.tracking_remote ||
    note("No tracking remote configured, assuming 'origin'") ||
    'origin'

#  puts_with_done("Fetching '#{remote}'") { repo.fetch(remote) }

  tracking_branch = repo.tracking_branch ||
    note("No tracking branch configured, assuming '#{branch}'") ||
    branch

  tracking = "#{tracking_remote}/#{tracking_branch}"

  head = repo.sha('HEAD')
  remote = repo.sha(tracking)

  if head == remote
    puts "Neither your local branch '#{branch}', nor the remote branch '#{tracking}' have moved on."
    success "Already up-to-date"
  end

  merge_base = repo.merge_base(head, remote)


end
