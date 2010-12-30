class GitSmart
  def self.register(code, &blk)
    commands[code] = lambda { blk.call }
  end

  def self.run(code)
    blk = commands[code]
    if blk
      blk.call
    else
      puts "No command #{code.inspect} defined! Available commands are #{commands.keys.sort.inspect}"
    end
  end

  private

  def self.commands
    @commands ||= {}
  end
end
