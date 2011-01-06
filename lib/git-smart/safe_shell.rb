module SafeShell
  def self.execute(command, *args)
    $stdout.sync = true
    $stderr.sync = true
    read_end, write_end = IO.pipe
    pid = fork do
      read_end.close
      $stdout.reopen(write_end)
      $stderr.reopen(write_end)
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
