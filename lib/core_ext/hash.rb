class Hash
  def map_keys &blk
    map_keys_with_values { |k,v| blk.call(k) }
  end

  def map_keys_with_values &blk
    result = {}
    each { |k,v| result[blk.call(k,v)] = v}
    result
  end

  def map_values &blk
    map_values_with_keys { |k,v| blk.call(v) }
  end

  def map_values_with_keys &blk
    result = {}
    each { |k,v| result[k] = blk.call(k,v)}
    result
  end
end
