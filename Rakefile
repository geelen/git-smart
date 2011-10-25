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

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "git-smart #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Generate the rocco docs"
task :rocco do
  base_dir = File.dirname(__FILE__)
  %x[cd #{base_dir}/lib/commands && rocco *.rb -o ../../docs]
  %x[cd #{base_dir} && git add docs]
end

task :release => :rocco

desc "Generate a binary for each of our commands"
task :generate_binaries do
  base_dir = File.dirname(__FILE__)
  require "#{base_dir}/lib/git-smart"

  require 'fileutils'
  FileUtils.mkdir_p "#{base_dir}/bin"
  GitSmart.commands.keys.each { |cmd|
    filename = "#{base_dir}/bin/git-#{cmd}"
    File.open(filename, 'w') { |out|
      out.puts %Q{#!/usr/bin/env ruby

$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib'))

require 'git-smart'

GitSmart.run('#{cmd}', ARGV)
}
    }
    `chmod a+x #{filename}`
    `cd #{base_dir} && git add #{filename}`
    puts "Wrote #{filename}"
  }
end

task :build => :generate_binaries
