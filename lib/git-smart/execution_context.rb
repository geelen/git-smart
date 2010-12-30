# The context that commands get executed within. Used for defining and scoping helper methods.

class ExecutionContext
  def initialize
    require 'colorize'
  end

  def note msg
    puts msg.green
  end

  def warn msg
    puts msg.red
  end
end
