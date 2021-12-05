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
    return if @key == "" && @val == " " # skip rendering if node is empty space

    dic = @tag.puncts? || @val == "" ? 0 : @dic
    io << 'ǀ' << dic << 'ǀ' << @idx << 'ǀ' << @key.size
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

  def inspect(io : IO = STDOUT, pad = -1) : Nil
    # return if @key == "" && @val == " "
    io << " " * pad if pad >= 0
    io << "[#{@key}/#{@val}/#{@tag.tag}/#{@dic}/#{@idx}]"
    io << "\n" if pad >= 0
  end

  def deep_inspect(io : IO = STDOUT, pad = 0) : Nil
    node = self

    if body = @body
      io << " " * pad << "{" << @tag.to_str << "/" << @dic << "}" << "\n"
      body.deep_inspect(io, pad + 2)
      io << " " * pad << "{/" << @tag.to_str << "/" << @dic << "}" << "\n"
    else
      self.inspect(io, pad: pad)
    end

    @succ.try(&.deep_inspect(io, pad))
  end
end
