class GitRepo
  def initialize(dir)
    @dir = dir
  end

  def current_branch
    File.read(File.join(@dir, ".git", "HEAD")).strip.sub(/^.*refs\/heads\//, '')
  end

  def sha(ref)
    sha = git('rev-parse', ref).chomp
    sha.empty? ? nil : sha
  end

  def tracking_remote
    config("branch.#{current_branch}.remote")
  end

  def tracking_branch
    key   = "branch.#{current_branch}.merge"
    value = config(key)
    if value =~ /^refs\/heads\/(.*)$/
      $1
    else
      raise GitSmart::UnexpectedOutput.new("Expected the config of '#{key}' to be /refs/heads/branchname, got '#{value}'")
    end
  end

  def fetch(remote)
    git('fetch', remote)
  end

  def merge_base(ref_a, ref_b)
    git('merge-base', ref_a, ref_b).chomp
  end

  def exists?(ref)
    git('rev-parse', ref)
    $?.success?
  end

  def rev_list(ref_a, ref_b)
    git('rev-list', "#{ref_a}..#{ref_b}").split("\n")
  end

  def status
    status_output = git('status', '-s')
    status_output.
      split("\n").
      map { |l| l.split(" ") }.
      group_by(&:first).
      map_values { |lines| lines.map(&:last) }.
      map_keys { |status|
        case status
          when /^M/: :modified
          when /^A/: :added
          when /^\?\?/: :untracked
          else raise GitSmart::UnexpectedOutput.new("Expected the output of git status to only have lines starting with A,M, or ??. Got: \n#{status_output}")
        end
      }
  end

  def dirty?
    status.any? { |k,v| k != :untracked && v.any? }
  end

  def fast_forward(ref)
    log_git('merge', '--ff-only', ref)
  end

  # helper methods, left public in case other commands want to use them directly

  def git(*args)
    Dir.chdir(@dir) { SafeShell.execute('git', *args) }
  end

  def log_git(*args)
    puts "Executing: #{['git', *args].join(" ")}"
    output = git(*args)
    puts output.split("\n").map { |l| "  #{l}" }
    output
  end

  def config(name)
    remote = git('config', name).chomp
    remote.empty? ? nil : remote
  end
end
