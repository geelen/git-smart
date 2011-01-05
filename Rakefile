require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "git-smart"
  gem.homepage = "http://github.com/geelen/git-smart"
  gem.license = "MIT"
  gem.summary = %Q{Add some smarts to your git workflow}
  gem.description = %Q{Installs some additional 'smart' git commands, like `git smart-pull`.}
  gem.email = "glenmaddern@gmail.com"
  gem.authors = ["Glen Maddern"]
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "git-smart #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Generate the rocco docs"
task :rocco do
  %x[cd lib/commands && rocco *.rb -o ../../docs]
end

task :release => :rocco

desc "Generate a binary for each of our commands"
task :generate_binaries do
  require File.join(File.dirname(__FILE__), 'lib', 'git-smart')
  GitSmart.commands.keys.each { |cmd|
    filename = "#{File.dirname(__FILE__)}/bin/git-#{cmd}"
    File.open(filename, 'w') { |out|
      out.puts %Q{#!/usr/bin/env ruby

$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib'))

require 'git-smart'

GitSmart.run('#{cmd}', ARGV)
}
    }
    `chmod a+x #{filename}`
    puts "Wrote #{filename}"
  }
end
