class GitSmart
  def self.run(code, args)
    lambda = commands[code]
    if lambda
      lambda.call(args)
    else
      puts "No command #{code.inspect} defined! Available commands are #{commands.keys.sort.inspect}"
    end
  end

  # Used like this:
  # GitSmart.register 'my-command' do |repo, args|
  def self.register(code, &blk)
    commands[code] = lambda { |args|
      blk.call(Grit::Repo.new("."), args)
    }
  end

  private

  def self.commands
    @commands ||= {}
  end
end
