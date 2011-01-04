require File.dirname(__FILE__) + '/spec_helper'

require 'fileutils'

describe 'smart-merge' do
  def local_dir;  WORKING_DIR + '/local';  end

  before :each do
    %x[
      cd #{WORKING_DIR}
        mkdir local
        cd local
          git init
          echo 'hurr durr' > README
          mkdir lib
          echo 'puts "pro hax"' > lib/codes.rb
          git add .
          git commit -m 'first'
    ]
  end

  it "should require an argument" do
    out = run_command(local_dir, 'smart-merge')
    out.should report("Usage: git smart-merge ref")
  end

  it "should require a valid branch" do
    out = run_command(local_dir, 'smart-merge', 'foo')
    out.should report("Usage: git smart-merge ref")
  end

  context "with a fast forwardable branch" do
    before :each do
      %x[
        cd #{local_dir}
          git checkout -b newbranch
          echo 'moar things!' >> README
          echo 'puts "moar code!"' >> lib/moar.rb
          git add .
          git commit -m 'moar'

          git checkout master
      ]
    end

    it "should merge --no-ff, despite the branches not having diverged" do
      out = run_command(local_dir, 'smart-merge', 'newbranch')
      out.should_report("Branch 'newbranch' has diverged by 1 commit. Merging in.")
      out.should_report("* Branch 'master' has not moved on since 'newbranch' diverged. Running with --no-ff anyway, since a fast-forward is unexpected behaviour.")
      out.should_report("Executing: git merge --no-ff newbranch")
      out.should report("2 files changed, 2 insertions(+), 0 deletions(-)")
    end
  end
end
