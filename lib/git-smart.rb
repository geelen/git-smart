require 'rubygems'

class GitSmart
end

%w[git-smart commands].each { |dir|
  Dir.glob(File.join(File.dirname(__FILE__), dir, '**', '*.rb')) { |f| require f }
}
