GitSmart.register 'smart-pull' do |repo, args|
  note "Starting: smart-pull on branch #{repo.current_branch}"
  warn "Ignoring arguments: #{args.inspect}" if !args.empty?

  remote = repo.tracking_remote ||
    puts("* No tracking remote configured, assuming 'origin'") ||
    'origin'

  print "Fetching '#{remote}'..."
  repo.fetch(remote)
  puts "done."
end
