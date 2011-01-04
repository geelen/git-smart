class GitSmart
  def self.run(code, args)
    lambda = commands[code]
    if lambda
      begin
        lambda.call(args)
      rescue GitSmart::Exception => e
        if e.message && !e.message.empty?
          puts e.message.red
        end
      end
    else
      puts "No command #{code.inspect} defined! Available commands are #{commands.keys.sort.inspect}"
    end
  end

  # Used like this:
  # GitSmart.register 'my-command' do |repo, args|
  def self.register(code, &blk)
    commands[code] = lambda { |args|
      ExecutionContext.new.instance_exec(GitRepo.new("."), args, &blk)
    }
  end

  def self.commands
    @commands ||= {}
  end
end
