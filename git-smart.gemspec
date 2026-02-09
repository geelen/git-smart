Gem::Specification.new do |s|
  s.name = "git-smart"
  s.version = "0.1.12"

  s.authors = ["Glen Maddern"]
  s.email = "glenmaddern@gmail.com"
  s.summary = "Add some smarts to your git workflow"
  s.description = "Installs some additional 'smart' git commands, like `git smart-pull`."
  s.homepage = "https://github.com/geelen/git-smart"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.required_ruby_version = ">= 2.7.0"

  s.metadata = {
    "source_code_uri" => "https://github.com/geelen/git-smart",
    "changelog_uri" => "https://github.com/geelen/git-smart/commits/main"
  }

  s.extra_rdoc_files = %w[LICENSE.txt README.md]

  s.executables = `git ls-files -- bin`.split("\n").map { |f| File.basename(f) }
  s.files = `git ls-files -- {lib,docs}`.split("\n") + %w[LICENSE.txt README.md VERSION]

  s.add_runtime_dependency "colorize", ">= 0.8"

  s.add_development_dependency "rspec", "~> 3.0"
end
