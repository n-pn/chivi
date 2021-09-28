module MTL::Serialize
  def to_str : String
    String.build { |io| to_str(io) }
  end

  def to_str(io : IO) : Nil
    io << @val

    unless @val == " "
      io << 'ǀ' << @dic << 'ǀ' << @idx << 'ǀ' << @key.size
    end

    return unless succ = @succ
    io << '\t'
    succ.to_str(io)
  end

  def inspect(io : IO) : Nil
    io << (val == " " ? val : "[#{@key}/#{@val}/#{@tag.to_str}/#{@dic}]")
    @succ.try(&.inspect(io))
  end
end
