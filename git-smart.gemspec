Gem::Specification.new do |s|
  s.name = %q{git-smart}
  s.version = "0.1.7"

  s.authors = ["Glen Maddern"]
  s.email = %q{glenmaddern@gmail.com}
  s.date = %q{2011-01-06}
  s.summary = %q{Add some smarts to your git workflow}
  s.description = %q{Installs some additional 'smart' git commands, like `git smart-pull`.}
  s.homepage = %q{http://github.com/geelen/git-smart}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]

  s.extra_rdoc_files = %w[LICENSE.txt README.md]

  s.executables = `git ls-files -- bin`.split("\n").map{|f| File.basename(f) }
  s.files       = `git ls-files -- {lib,docs}`.split("\n") + %w[Gemfile Gemfile.lock LICENSE.txt README.md Rakefile VERSION]
  s.test_files  = `git ls-files -- spec`.split("\n")

  s.add_runtime_dependency(%q<colorize>, [">= 0"])

  s.add_development_dependency(%q<rspec>, [">= 2.7.0"])
  s.add_development_dependency(%q<rcov>, [">= 0"])
  s.add_development_dependency(%q<rocco>, [">= 0"])
end
