require 'rspec'
require 'tmpdir'

require File.dirname(__FILE__) + '/../lib/git-smart'

WORKING_DIR = File.dirname(__FILE__) + '/working'

RSpec.configure do |config|
  config.before :each do
    FileUtils.rm_rf WORKING_DIR
    FileUtils.mkdir_p WORKING_DIR
  end
  
  config.expect_with(:rspec) { |c| c.syntax = :should }

  config.after :each do
    FileUtils.rm_rf WORKING_DIR
  end
end

def run_command(dir, command, *args)
  require 'stringio'
  $stdout = stdout = StringIO.new

  Dir.chdir(dir) { GitSmart.run(command, args) }

  $stdout = STDOUT
  stdout.string.split("\n")
end

RSpec::Matchers.define :report do |expected|
  failure_message do |actual|
    "expected to see #{expected.inspect}, got \n\n#{actual.map { |line| "  #{line}" }.join("\n")}"
  end
  failure_message_when_negated do |actual|
    "expected not to see #{expected.inspect} in \n\n#{actual.map { |line| "  #{line}" }.join("\n")}"
  end
  match do |actual|
    actual.any? { |line| line[expected] }
  end
end


RSpec::Matchers.define :have_git_status do |expected|
  failure_message do |dir|
    "expected '#{dir}' to have git status of #{expected.inspect}, got #{GitRepo.new(dir).status.inspect}"
  end
  failure_message_when_negated do |actual|
    "expected '#{dir}' to not have git status of #{expected.inspect}, got #{GitRepo.new(dir).status.inspect}"
  end
  match do |dir|
    GitRepo.new(dir).status == expected
  end
end


RSpec::Matchers.define :have_last_few_commits do |expected|
  failure_message do |dir|
    "expected '#{dir}' to have last few commits of #{expected.inspect}, got #{GitRepo.new(dir).last_commit_messages(expected.length).inspect}"
  end
  failure_message_when_negated do |actual|
    "expected '#{dir}' to not have git status of #{expected.inspect}, got #{GitRepo.new(dir).last_commit_messages(expected.length).inspect}"
  end
  match do |dir|
    GitRepo.new(dir).last_commit_messages(expected.length) == expected
  end
end
