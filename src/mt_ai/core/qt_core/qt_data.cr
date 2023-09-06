require "./qt_node"

class MT::QtData < Array(MT::QtNode)
  def to_txt(cap : Bool = true, und : Bool = true) : String
    String.build { |io| to_txt(io, cap, und) }
  end

  def to_txt(io : IO, cap : Bool = true, und : Bool = true)
    each { |node| cap, und = node.to_txt(io, cap, und) }
  end

  def to_mtl(cap : Bool = true, und : Bool = true) : String
    String.build { |io| to_mtl(io, cap, und) }
  end

  def to_mtl(io : IO, cap : Bool = true, und : Bool = true)
    each { |node| cap, und = node.to_mtl(io, cap, und) }
  end
end
