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
    before :all do
      @out,err = run_command('smart-pull')
      err.should be_empty
    end

    it "should assume origin/master" do
      @out.should report("No tracking remote configured, assuming 'origin'")
      @out.should report("No tracking branch configured, assuming 'master'")
    end

    it "should report nothing to do" do
      @out.should report("Neither your local branch 'master', nor the remote branch 'origin/master' have moved on.")
      @out.should report("Already up-to-date")
    end
  end
end
