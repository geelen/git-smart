require File.dirname(__FILE__) + '/spec_helper'

require 'fileutils'

describe 'smart-pull' do
  def local_dir;  WORKING_DIR + '/local';  end
  def remote_dir; WORKING_DIR + '/remote'; end

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
    out = run_command(local_dir, 'smart-pull')
    out.should report("Fetching 'origin'")
    out.should report("Neither your local branch 'master', nor the remote branch 'origin/master' have moved on.")
    out.should report("Already up-to-date")
  end

  context "with only local changes" do
    before :each do
      %x[
        cd #{local_dir}
          echo 'moar things!' >> README
          echo 'puts "moar code!"' >> lib/moar.rb
          git add .
          git commit -m 'moar'
      ]
    end

    it "should report that no remote changes were found" do
      out = run_command(local_dir, 'smart-pull')
      out.should report("Fetching 'origin'")
      out.should report("Remote branch 'origin/master' has not moved on.")
      out.should report("Already up-to-date")
    end
  end

  context "with only remote changes" do
    before :each do
      %x[
        cd #{remote_dir}
          echo 'changed on the server!' >> README
          git add .
          git commit -m 'upstream changes'
      ]
    end

    it "should fast-forward" do
      out = run_command(local_dir, 'smart-pull')
      out.should report("Fetching 'origin'")
      out.should report("There is 1 new commit on master.")
      out.should report("No uncommitted changes, no need to stash.")
      out.should report("Local branch 'master' has not moved on. Fast-forwarding.")
      out.should report("git merge --ff-only origin/master")
      out.should report(/Updating [^\.]+..[^\.]+/)
      out.should report("1 files changed, 1 insertions(+), 0 deletions(-)")
    end

    it "should not stash before fast-forwarding if untracked files are present" do
      %x[
        cd #{local_dir}
          echo "i am nub" > noob
      ]
      local_dir.should have_git_status({:untracked => ['noob']})
      out = run_command(local_dir, 'smart-pull')
      out.should report("No uncommitted changes, no need to stash.")
      out.should report("git merge --ff-only origin/master")
      out.should report("1 files changed, 1 insertions(+), 0 deletions(-)")
    end

    it "should stash, fast forward, pop if there are local changes" do
      %x[
        cd #{local_dir}
          echo "i am nub" > noob
          echo "I make a change!" >> README
          echo "puts 'moar codes too!'" >> lib/codes.rb
          git add noob
          git add README
      ]
      local_dir.should have_git_status({:added => ['noob'], :modified => ['README', 'lib/codes.rb']})
      out = run_command(local_dir, 'smart-pull')
      out.should report("No uncommitted changes, no need to stash.")
      out.should report("git merge --ff-only origin/master")
      out.should report("1 files changed, 1 insertions(+), 0 deletions(-)")

    end
  end
end
