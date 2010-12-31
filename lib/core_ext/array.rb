class Array
  def group_by(&blk)
    Hash.new { |h,k| h[k] = [] }.tap do |hash|
      each do |element|
        hash[blk.call(element)] << element
      end
    end
  end
end
