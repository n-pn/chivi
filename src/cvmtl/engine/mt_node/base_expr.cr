require "./mt_node"

module MT::BaseExpr
  abstract def each(&block : MtNode -> Nil)

  def to_txt(io : IO = STDOUT) : Nil
    prev = nil

    self.each do |node|
      io << ' ' if prev && node.add_space?(prev)
      node.to_txt(io)
      prev = node unless node.pos.passive?
    end
  end

  def apply_cap!(cap : Bool = false) : Bool
    each do |node|
      cap = node.apply_cap!(cap)
    end

    cap
  end

  def to_mtl(io : IO = STDOUT) : Nil
    io << "〈0\t"
    prev = nil

    self.each do |node|
      io << "\t " if prev && node.add_space?(prev)
      node.to_mtl(io)
      prev = node unless node.pos.passive?
    end

    io << '〉'
  end

  def inspect(io : IO = STDOUT, pad = 0) : Nil
    io << " " * pad << '{' << @tag.colorize.cyan << "}\n"
    self.each(&.inspect(io, pad + 2))
    io << " " * pad << "{/" << @tag.colorize.cyan << '}'
    io << '\n' if pad > 0
  end
end
