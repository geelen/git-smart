class Object
  def tapp(prefix = nil, &block)
    block ||= lambda {|x| x }
    str = if block[self].is_a? String then block[self] else block[self].inspect end
    puts [prefix, str].compact.join(": ")
    self
  end
end
