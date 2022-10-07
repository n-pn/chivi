require "./base_node"

class CV::BaseExpr
  abstract def each

  def to_txt(io : IO = STDOUT) : Nil
    prev = nil

    each do |node|
      io << ' ' if prev && node.space_before?(prev)
      node.to_txt(io)
      prev = node
    end
  end

  def to_mtl(io : IO = STDOUT) : Nil
    io << '〈' << @dic << '\t'
    prev = nil

    each do |node|
      io << "\t " if prev && node.space_before?(prev)
      node.to_mtl(io)
      prev = node
    end

    io << '〉'
  end
end
