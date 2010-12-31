require File.dirname(__FILE__) + '/../lib/git-smart.rb'

WORKING_DIR = File.dirname(__FILE__) + '/working'

RSpec.configure do |config|
  config.before :each do
    FileUtils.mkdir_p WORKING_DIR
  end

  config.after :each do
    FileUtils.rm_rf WORKING_DIR
  end
end

def run_command(command, args = [])
  require 'stringio'
  $stdout = stdout = StringIO.new
  $stderr = stderr = StringIO.new

  GitSmart.run(command, args)

  $stdout = STDOUT
  $stderr = STDERR
  [stdout.string.split("\n"), stderr.string.split("\n")]
end

RSpec::Matchers.define :report do |expected|
  failure_message_for_should do |actual|
    "expected to see '#{expected}', got \n\n#{actual.map { |line| "  #{line}" }.join("\n")}"
  end
  match do |actual|
    !actual.grep(Regexp.new(Regexp.escape(expected))).empty?
  end
end
