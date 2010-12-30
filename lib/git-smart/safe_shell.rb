module SafeShell
  def self.execute(command, *args)
    opts = args.last.kind_of?(Hash) ? args.pop : {}
    read_end, write_end = IO.pipe
    new_stdout = opts[:stdout] ? File.open(opts[:stdout], "w+") : write_end
    new_stderr = opts[:stderr] ? File.open(opts[:stderr], "w+") : write_end
    pid = fork do
      read_end.close
      STDOUT.reopen(new_stdout)
      STDERR.reopen(new_stderr)
      exec(command, *args)
    end
    write_end.close
    output = read_end.read
    Process.waitpid(pid)
    read_end.close
    output
  end

  def self.execute?(*args)
    execute(*args)
    $?.success?
  end
end
