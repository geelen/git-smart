require File.dirname(__FILE__) + '/spec_helper'

describe "smart-pull" do
  before do
    @repo = mock(GitRepo)
    @repo.should_receive(:current_branch).and_return('master')
    @context = TestExecutionContext.new
  end

  it "should run" do
    @context.instance_exec(nil, [], &GitSmart.commands['smart-pull'])
  end

  after do
    p @context.calls
  end
end
