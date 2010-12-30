# The context that commands get executed within. Used for defining and scoping helper methods.

class ExecutionContext
  def initialize
    require 'colorize'
  end

  def start msg
    puts "- #{msg} -".green
  end

  def note msg
    puts "* #{msg}"
  end

  def warn msg
    puts msg.red
  end

  def puts_with_done msg, &blk
    print "#{msg}..."
    blk.call
    puts "done."
  end

  def success msg
    puts big_message(msg).green
  end

  def failure msg
    puts big_message(msg).red
    raise GitSmart::RunFailed
  end

  def big_message msg
    spacer_line = (" " + "-" * (msg.length + 20) + " ")
    [spacer_line, "|" + " " * 10 + msg + " " * 10 + "|", spacer_line].join("\n")
  end
end
