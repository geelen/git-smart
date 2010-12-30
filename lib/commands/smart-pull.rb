GitSmart.register 'smart-pull' do |repo, args|
  puts repo.current_branch
  p repo.tracking_remote
end
