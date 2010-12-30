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
    config("branch.#{current_branch}.branch")
  end

  def fetch(remote)
    git('fetch', remote)
  end

  def merge_base(ref_a, ref_b)
    git('merge-base', ref_a, ref_b)
  end

  def exists?(ref)
    git('rev-parse', ref)
    $?.success?
  end

  def rev_list(ref_a, ref_b)
    git('rev-list', ref_a, ref_b)
  end

  def dirty?
    git('diff-index', '--name-status', 'HEAD').empty?
  end

  def git(*args)
    SafeShell.execute('git', *args)
  end

  def config(name)
    remote = git('config', name).chomp
    remote.empty? ? nil : remote
  end
end
