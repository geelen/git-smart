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

  context "with nothing to do" do
    before :each do
      @out,err = run_command(WORKING_DIR + '/local', 'smart-pull')
      err.should be_empty
    end

    it "should assume origin/master, and nothing to do" do
      @out.should report("Fetching 'origin'")
      @out.should report("Neither your local branch 'master', nor the remote branch 'origin/master' have moved on.")
      @out.should report("Already up-to-date")
    end
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
      @out,err = run_command(WORKING_DIR + '/local', 'smart-pull')
      err.should be_empty
    end

    it "should report that no remote changes were found" do
      @out.should report("Fetching 'origin'")
      @out.should report("Remote branch 'origin/master' has not moved on.")
      @out.should report("Already up-to-date")
    end
  end
end
