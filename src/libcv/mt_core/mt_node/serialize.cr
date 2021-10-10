module CV::MTL::Serialize
  def to_str : String
    String.build { |io| to_str(io) }
  end

  def to_str(io : IO, deep = true) : Nil
    io << @val

    unless @val == " "
      io << 'ǀ' << @dic << 'ǀ' << @idx << 'ǀ' << @key.size
    end

    deep && @succ.try do |x|
      io << '\t'
      x.to_str(io)
    end
  end

  def inspect(io : IO, deep = false) : Nil
    io << (val == " " ? val : "[#{@key}/#{@val}/#{@tag.to_str}/#{@dic}]")
    @succ.try(&.inspect(io)) if deep
  end
end
