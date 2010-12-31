require File.dirname(__FILE__) + '/spec_helper'

require 'fileutils'

describe 'smart-pull' do
  before :each do
    %x[
      cd #{WORKING_DIR}
        mkdir remote
        cd remote
          git init
          echo 'hurr durr' > README
          mkdir lib
          echo 'puts "pro hax"' > lib/codes.rb
          git add .
          git commit -m 'first'
        cd ..

        git clone remote/.git local
    ]
  end

  it "should tell us there's nothing to do" do
    out = run_command(WORKING_DIR + '/local', 'smart-pull')
    out.should report("Fetching 'origin'")
    out.should report("Neither your local branch 'master', nor the remote branch 'origin/master' have moved on.")
    out.should report("Already up-to-date")
  end

  context "with only local changes" do
    before :each do
      %x[
        cd #{WORKING_DIR}/local
          echo 'moar things!' >> README
          echo 'puts "moar code!"' >> lib/moar.rb
          git add .
          git commit -m 'moar'
      ]
    end

    it "should report that no remote changes were found" do
      out = run_command(WORKING_DIR + '/local', 'smart-pull')
      out.should report("Fetching 'origin'")
      out.should report("Remote branch 'origin/master' has not moved on.")
      out.should report("Already up-to-date")
    end
  end

  context "with only remote changes" do
    before :each do
      %x[
        cd #{WORKING_DIR}/remote
          echo 'changed on the server!' >> README
          git add .
          git commit -m 'upstream changes'
      ]
    end

    it "should report that no remote changes were found" do
      out = run_command(WORKING_DIR + '/local', 'smart-pull')
      out.should report("Fetching 'origin'")
      out.should report("There is 1 new commit on master.")
      out.should report("No uncommitted changes, no need to stash.")
      out.should report("Local branch 'master' has not moved on. Fast-forwarding.")
      out.should report("git merge --ff-only origin/master")
      out.should report(/Updating [^\.]+..[^\.]+/)
      out.should report("1 files changed, 1 insertions(+), 0 deletions(-)")
    end
  end
end
