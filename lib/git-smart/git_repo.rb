class GitRepo
  def initialize(dir)
    @dir = dir
    if !File.exists? File.join(@dir, ".git")
      raise GitSmart::RunFailed.new("You need to run this from within a git directory")
    end
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
    if value.nil?
      value
    elsif value =~ /^refs\/heads\/(.*)$/
      $1
    else
      raise GitSmart::UnexpectedOutput.new("Expected the config of '#{key}' to be /refs/heads/branchname, got '#{value}'")
    end
  end

  def fetch!(remote)
    log_git('fetch', remote)
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

  def raw_status
    git('status', '-s')
  end

  def status
    raw_status.
      split("\n").
      map { |l| l.split(" ") }.
      group_by(&:first).
      map_values { |lines| lines.map(&:last) }.
      map_keys { |status|
        case status
          when /^M/; :modified
          when /^A/; :added
          when /^\?\?/; :untracked
          else raise GitSmart::UnexpectedOutput.new("Expected the output of git status to only have lines starting with A,M, or ??. Got: \n#{raw_status}")
        end
      }
  end

  def dirty?
    status.any? { |k,v| k != :untracked && v.any? }
  end

  def fast_forward!(upstream)
    log_git('merge', '--ff-only', upstream)
  end

  def stash!
    log_git('stash')
  end

  def stash_pop!
    log_git('stash', 'pop')
  end

  def rebase_preserving_merges!(upstream)
    log_git('rebase', '-p', upstream)
  end

  def log(nr)
    git('log', '--oneline', '-n', nr.to_s).split("\n").map { |l| l.split(" ",2) }
  end

  def log_commit_messages(nr)
    log(nr).map(&:last)
  end

  def merge_no_ff!(target)
    log_git('merge', '--no-ff', target)
  end

  # helper methods, left public in case other commands want to use them directly

  def git(*args)
    Dir.chdir(@dir) {
      output = SafeShell.execute('git', *args)
      $?.success? ? output : ''
    }
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
