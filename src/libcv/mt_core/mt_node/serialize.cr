module CV::MTL::Serialize
  def print_val(io : IO) : Nil
    if body = @body
      body.print_val(io)
    else
      io << @val
    end

    @succ.try(&.print_val(io))
  end

  def to_str : String
    String.build { |io| to_str(io) }
  end

  def to_str(io : IO) : Nil
    io << "\t" << @val
    return if @val == " "
    io << 'ǀ' << @dic << 'ǀ' << @idx << 'ǀ' << @key.size
  end

  def serialize(io : IO = STDOUT) : Nil
    if body = @body
      io << '〈' << @dic
      body.serialize(io)
      io << '〉'
    else
      to_str(io)
    end

    @succ.try(&.serialize(io))
  end

  def inspect(io : IO = STDOUT) : Nil
    return io << " " if val == " "
    io << "[#{@key}/#{@val}/#{@tag.to_str}/#{@dic}]"
  end

  def deep_inspect(io : IO = STDOUT) : Nil
    node = self

    if body = @body
      io << "{"
      body.deep_inspect(io)
      io << "}"
    else
      self.inspect(io)
    end

    @succ.try(&.deep_inspect(io))
  end
end
