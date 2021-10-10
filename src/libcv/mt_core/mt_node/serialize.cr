module CV::MTL::Serialize
  def to_str : String
    String.build { |io| to_str(io) }
  end

  def to_str(io : IO) : Nil
    io << @val
    return unless @val == " "
    io << 'ǀ' << @dic << 'ǀ' << @idx << 'ǀ' << @key.size
  end

  def serialize(io : IO = STDOUT)
    self.to_str(io)
    node = self

    while node = node.succ?
      io << '\t'
      node.to_str(io)
    end
  end

  def inspect(io : IO = STDOUT) : Nil
    return io << " " if val == " "
    io << "[#{@key}/#{@val}/#{@tag.to_str}/#{@dic}]"
  end

  def deep_inspect(io : IO = STDOUT) : Nil
    node = self

    while node = node.succ?
      node.inspect(io)
    end
  end
end
