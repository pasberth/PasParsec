module Enumerable
  
  def until &block
    result = nil
    each do |item|
      if result = block.call(item)
        break
      end
    end
    result
  end
end