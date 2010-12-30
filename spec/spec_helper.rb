require File.dirname(__FILE__) + '/../lib/git-smart.rb'

class TestExecutionContext
  ExecutionContext.instance_methods(false).each do |method|
    define_method(method) { |msg| calls[method] << msg }
  end

  def calls
    @calls ||= Hash.new { |h,k| h[k] = [] }
  end
end
