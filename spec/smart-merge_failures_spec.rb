require File.dirname(__FILE__) + '/spec_helper'

require 'fileutils'

describe 'smart-merge with failures' do
  def local_dir;  WORKING_DIR + '/local';  end

  before :each do
    %x[
      cd #{WORKING_DIR}
        mkdir local
        cd local
          git init
          echo -e 'one\ntwo\nthree\nfour\n' > README
          mkdir lib
          echo 'puts "pro hax"' > lib/codes.rb
          git add .
          git commit -m 'first'
    ]
  end

  context "with conflicting changes on master and newbranch" do
    before :each do
      %x[
        cd #{local_dir}
          git checkout -b newbranch 2> /dev/null
          echo 'one\nnewbranch changes\nfour\n' > README
          git commit -am 'newbranch_commit'

          git checkout master 2> /dev/null

          echo 'one\nmaster changes\nfour\n' > README
          git commit -am 'master_commit'
      ]
    end

    it "should report the failure and give instructions to the user" do
      out = run_command(local_dir, 'smart-merge', 'newbranch')
      local_dir.should have_git_status(:conflicted => ['README'])
      out.should_not report("All good")
      out.should report("Executing: git merge --no-ff newbranch")
      out.should report("CONFLICT (content): Merge conflict in README")
      out.should report("Automatic merge failed; fix conflicts and then commit the result.")
    end
  end
end
