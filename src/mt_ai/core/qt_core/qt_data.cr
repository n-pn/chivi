require "./qt_node"

class MT::QtData < Array(MT::QtNode)
  def to_txt(cap : Bool = true, pad : Bool = false) : String
    String.build { |io| to_txt(io, cap, pad) }
  end

  def to_txt(io : IO, cap : Bool, pad : Bool)
    each { |node| cap, pad = node.to_txt(io, cap, pad) }
  end

  def to_mtl(cap : Bool = true, pad : Bool = false) : String
    String.build { |io| to_mtl(io, cap, pad) }
  end

  def to_mtl(io : IO, cap : Bool, pad : Bool)
    each { |node| cap, pad = node.to_mtl(io, cap, pad) }
  end
end
