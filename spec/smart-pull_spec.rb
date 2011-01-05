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
    out.should report("Executing: git fetch origin")
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
      out.should report("Executing: git fetch origin")
      out.should report("Remote branch 'origin/master' has not moved on.")
      out.should report("You have 1 new commit on 'master'.")
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
      out.should report("Executing: git fetch origin")
      out.should report(/master +-> +origin\/master/)
      out.should report("There is 1 new commit on 'origin/master'.")
      out.should report("Local branch 'master' has not moved on. Fast-forwarding.")
      out.should report("Executing: git merge --ff-only origin/master")
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
      out.should report("Executing: git merge --ff-only origin/master")
      out.should report("1 files changed, 1 insertions(+), 0 deletions(-)")
      local_dir.should have_git_status({:untracked => ['noob']})
    end

    it "should stash, fast forward, pop if there are local changes" do
      %x[
        cd #{local_dir}
          echo "i am nub" > noob
          echo "puts 'moar codes too!'" >> lib/codes.rb
          git add noob
      ]
      local_dir.should have_git_status({:added => ['noob'], :modified => ['lib/codes.rb']})
      out = run_command(local_dir, 'smart-pull')
      out.should report("Working directory dirty. Stashing...")
      out.should report("Executing: git stash")
      out.should report("Executing: git merge --ff-only origin/master")
      out.should report("1 files changed, 1 insertions(+), 0 deletions(-)")
      out.should report("Reapplying local changes...")
      out.should report("Executing: git stash pop")
      local_dir.should have_git_status({:added => ['noob'], :modified => ['lib/codes.rb']})
    end
  end

  context "with diverged branches" do
    before :each do
      %x[
        cd #{remote_dir}
          echo 'changed on the server!' >> README
          git add .
          git commit -m 'upstream changes'

        cd #{local_dir}
          echo "puts 'moar codes too!'" >> lib/codes.rb
          git add .
          git commit -m 'local changes'
      ]
    end

    it "should rebase" do
      out = run_command(local_dir, 'smart-pull')
      out.should report("Executing: git fetch origin")
      out.should report(/master +-> +origin\/master/)
      out.should report("There is 1 new commit on 'origin/master'.")
      out.should report("You have 1 new commit on 'master'.")
      out.should report("Both local and remote branches have moved on. Branch 'master' needs to be rebased onto 'origin/master'")
      out.should report("Executing: git rebase -p origin/master")
      out.should report("Successfully rebased and updated refs/heads/master.")
      local_dir.should have_last_few_commits(['local changes', 'upstream changes', 'first'])
    end

    it "should not stash before rebasing if untracked files are present" do
      %x[
        cd #{local_dir}
          echo "i am nub" > noob
      ]
      local_dir.should have_git_status({:untracked => ['noob']})
      out = run_command(local_dir, 'smart-pull')
      out.should report("Executing: git rebase -p origin/master")
      out.should report("Successfully rebased and updated refs/heads/master.")
      local_dir.should have_git_status({:untracked => ['noob']})
      local_dir.should have_last_few_commits(['local changes', 'upstream changes', 'first'])
    end

    it "should stash, rebase, pop if there are local uncommitted changes" do
      %x[
        cd #{local_dir}
          echo "i am nub" > noob
          echo "puts 'moar codes too!'" >> lib/codes.rb
          git add noob
      ]
      local_dir.should have_git_status({:added => ['noob'], :modified => ['lib/codes.rb']})
      out = run_command(local_dir, 'smart-pull')
      out.should report("Working directory dirty. Stashing...")
      out.should report("Executing: git stash")
      out.should report("Executing: git rebase -p origin/master")
      out.should report("Successfully rebased and updated refs/heads/master.")
      local_dir.should have_git_status({:added => ['noob'], :modified => ['lib/codes.rb']})
      local_dir.should have_last_few_commits(['local changes', 'upstream changes', 'first'])
    end
  end
end
