# encoding: utf-8

require 'yaml'
require 'pathname'

class GitRepo
  def initialize(dir)
    @dir = dir
    unless File.directory?(git_dir)
      raise GitSmart::RunFailed.new(
        <<-MSG.gsub(/^\s+/, '')
        You need to run this from within a Git directory.
        Current working directory: #{File.expand_path(dir)}
        Expected .git directory: #{git_dir}
        MSG
      )
    end
  end

  def git_dir
    gitdir = Pathname.new(@dir).join('.git')

    unless File.exist?(gitdir)
      @dir = git('rev-parse', '--show-toplevel').chomp
      gitdir = Pathname.new(@dir).join('.git') unless @dir.empty?
    end

    if File.file?(gitdir)
      submodule = YAML.load_file(gitdir)
      gitdir = Pathname.new(@dir).join(submodule['gitdir']).to_path
    end

    gitdir
  end

  def current_branch
    head_file = File.join(git_dir, 'HEAD')
    File.read(head_file).strip.sub(%r(^.*refs/heads/), '')
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
    git!('fetch', remote)
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
          when /^[^ ]*M/; :modified
          when /^[^ ]*A/; :added
          when /^[^ ]*R/; :renamed
          when /^[^ ]*D/; :deleted
          when /^[^ ]*\?\?/; :untracked
          when /^[^ ]*UU/; :conflicted
          else raise GitSmart::UnexpectedOutput.new("Expected the output of git status to only have lines starting with A, M, R, D, UU, or ??. Got: \n#{raw_status}")
        end
      }
  end

  def dirty?
    status.any? { |k,v| k != :untracked && v.any? }
  end

  def fast_forward!(upstream)
    git!('merge', '--ff-only', upstream)
  end

  def stash!
    git!('stash')
  end

  def stash_pop!
    git!('stash', 'pop')
  end

  def rebase_preserving_merges!(upstream)
    git!('rebase', '--rebase-merges', upstream)
  end

  def read_log(nr)
    git('log', '--oneline', '-n', nr.to_s).split("\n").map { |l| l.split(" ",2) }
  end

  def last_commit_messages(nr)
    read_log(nr).map(&:last)
  end

  def log_to_shell(*args)
    git_shell('log', *args)
  end

  def merge_no_ff!(target)
    git!('merge', '--no-ff', target)
  end

  # helper methods, left public in case other commands want to use them directly

  def git(*args)
    output = exec_git(*args)
    $?.success? ? output : ''
  end

  def git!(*args)
    puts "Executing: #{['git', *args].join(" ")}"
    output = exec_git(*args)
    to_display = output.split("\n").map { |l| "  #{l}" }.join("\n")
    $?.success? ? puts(to_display) : raise(GitSmart::UnexpectedOutput.new(to_display))
    output
  end

  def git_shell(*args)
    puts "Executing: #{['git', *args].join(" ")}"
    Dir.chdir(@dir) {
      system('git', *args)
    }
  end

  def config(name)
    remote = git('config', name).chomp
    remote.empty? ? nil : remote
  end

  private

  def exec_git(*args)
    return if @dir.empty?
    Dir.chdir(@dir) {
      SafeShell.execute('git', *args)
    }
  end
end
