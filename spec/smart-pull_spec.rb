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
          git config --local user.name 'Maxwell Smart'
          git config --local user.email 'agent86@control.gov'
          git config --local core.pager 'cat'
          echo 'hurr durr' > README
          mkdir lib
          echo 'puts "pro hax"' > lib/codes.rb
          git add .
          git commit -m 'first'
        cd ..
        git clone remote/.git local
        cd local
          git config --local user.name 'Agent 99'
          git config --local user.email 'agent99@control.gov'
          git config --local core.pager 'cat'
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
      out.should report(/1 files? changed, 1 insertions?\(\+\)(, 0 deletions\(-\))?$/)
    end

    it "should not stash before fast-forwarding if untracked files are present" do
      %x[
        cd #{local_dir}
          echo "i am nub" > noob
      ]
      local_dir.should have_git_status({:untracked => ['noob']})
      out = run_command(local_dir, 'smart-pull')
      out.should report("Executing: git merge --ff-only origin/master")
      out.should report(/1 files? changed, 1 insertions?\(\+\)(, 0 deletions\(-\))?$/)
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
      out.should report(/1 files? changed, 1 insertions?\(\+\)(, 0 deletions\(-\))?$/)
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

    it "should stash, rebase, pop if there are local renamed files" do
      %x[
        cd #{local_dir}
          git mv lib/codes.rb lib/codes2.rb
      ]
      local_dir.should have_git_status({:renamed=>["lib/codes2.rb"]})
      out = run_command(local_dir, 'smart-pull')
      out.should report("Working directory dirty. Stashing...")
      out.should report("Executing: git stash")
      out.should report("Executing: git rebase -p origin/master")
      out.should report("Successfully rebased and updated refs/heads/master.")
      local_dir.should have_git_status({:deleted=>["lib/codes.rb"], :added=>["lib/codes2.rb"]})
      local_dir.should have_last_few_commits(['local changes', 'upstream changes', 'first'])
    end
  end

  context 'with a submodule' do
    before do
      %x[
      cd #{WORKING_DIR}
        mkdir submodule
        cd submodule
          git init
          git config --local user.name 'The Chief'
          git config --local user.email 'agentq@control.gov'
          git config --local core.pager 'cat'
          echo 'Unusual, but effective.' > README
          git add .
          git commit -m 'first'
        cd ..
        cd local
          git submodule add "${PWD}/../submodule/.git" submodule
          git commit -am 'Add submodule'
      ]
    end
    let(:submodule_dir) { local_dir + '/submodule' }

    it 'can smart-pull the repo containing the submodule' do
      out = run_command(local_dir, 'smart-pull')
      out.should report('Executing: git fetch origin')
      out.should report("Remote branch 'origin/master' has not moved on.")
      out.should report("You have 1 new commit on 'master'.")
    end

    it 'can smart-pull the submodule' do
      out = run_command(submodule_dir, 'smart-pull')
      out.should report('Executing: git fetch origin')
      out.should report("Neither your local branch 'master', nor the remote branch 'origin/master' have moved on.")
      out.should report('Already up-to-date')
    end
  end

  context 'outside of a repo' do
    it 'should report a meaningful error' do
      Dir.mktmpdir do |non_repo_dir|
        out = run_command(non_repo_dir, 'smart-pull')
        out.should report 'You need to run this from within a Git directory'
        out.should report 'Current working directory: '
        out.should report 'Expected .git directory: '
      end
    end
  end
end
