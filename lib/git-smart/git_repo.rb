class GitRepo
  def initialize(dir)
    @dir = dir
  end

  def current_branch
    File.read(File.join(@dir, ".git", "HEAD")).strip.sub(/^.*refs\/heads\//, '')
  end

  def tracking_remote
    remote = git('config', "branch.#{current_branch}.remote").chomp
    remote.empty? ? nil : remote
  end

  private

  def git(*args)
    SafeShell.execute('git', *args)
  end
end
