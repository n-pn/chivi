class CV::MtNode
  def to_txt : String
    String.build { |io| to_txt(io) }
  end

  def to_txt(io : IO)
    raise "Implement by inherited class!"
  end
end

class CV::MtTerm
  def to_txt(io : IO) : Nil
    io << @val
  end

  def to_mtl(io : IO) : Nil
    io << "\t" << @val

    # skip rendering if node is empty space
    return if @key == "" && @val == " "

    dic = @tag.puncts? || @val == "" ? 0 : @dic
    io << 'ǀ' << dic << 'ǀ' << @idx << 'ǀ' << @key.size
  end

  def inspect(io : IO = STDOUT, pad = -1) : Nil
    return if @key == "" && @val == " "
    io << " " * pad if pad >= 0
    io << "[#{@key}/#{@val}/#{@tag.tag}/#{@dic}/#{@idx}]"
    io << "\n" if pad >= 0
  end
end

class CV::MtList
  def to_txt(io : IO) : Nil
    node = @head

    while node
      node.to_txt(io)
      node = node.succ?
    end
  end

  def to_mtl(io : IO = STDOUT) : Nil
    node = @head

    while node
      node.to_mtl(io)
      node = node.succ?
    end
  end

  def inspect(io : IO = STDOUT, pad = 0) : Nil
    io << " " * pad << "{" << @tag.tag << "/" << @dic << "}" << "\n"

    node = @head
    while node
      node.inspect(io, pad + 2)
      node = node.succ?
    end

    io << " " * pad << "{/" << @tag.tag << "/" << @dic << "}" << "\n"
  end
end
