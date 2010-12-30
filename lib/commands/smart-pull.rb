GitSmart.register 'smart-pull' do |repo, args|
  p repo.commits("better_attributes")
  p args
end
