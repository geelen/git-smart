class GitSmart
  class Exception < ::RuntimeError
    def initialize(msg = '')
      super(msg)
    end
  end

  class RunFailed < Exception; end
  class UnexpectedOutput < Exception; end
end
