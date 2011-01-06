#This is a super simple alias for the most badass of log outputs that git
#offers. Uses git log --graph under the hood.
#
#Thanks to [@ben_h](http://twitter.com/ben_h) for this one!
GitSmart.register 'smart-log' do |repo, args|
  #Super simple, passes the args through to git log, but
  #ratchets up the badassness quotient.
  repo.log!('--pretty=format:%Cblue%h%Creset %cr %Cgreen%an%Creset %s', '--graph', *args)
end
