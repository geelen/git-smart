require 'open3'

module SafeShell
  def self.execute(command, *args)
    cmd = [].push(command).push(args).join(' ')
    result = ""
    exit_status = nil

    Open3.popen2e (cmd) do |stdin, out, wait_thr|
      while line = out.gets
        result += line
      end

      exit_status = wait_thr.value
    end

    return result, exit_status
  end

  def self.execute?(*args)
    output, exit_status = execute(*args)
    exit_status.success?
  end
end
