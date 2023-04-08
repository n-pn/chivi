require "./v0_node"

class MT::V0Data < Array(MT::V0Node)
  def to_txt(cap : Bool = true) : String
    fmt = cap ? FmtFlag::Initial : FmtFlag::Nospace
    String.build { |io| to_txt(io, fmt: fmt) }
  end

  def to_txt(io : IO, fmt = FmtFlag::Initial) : Nil
    each { |node| fmt = node.to_txt(io, fmt) }
  end

  def to_mtl(cap : Bool = true) : String
    fmt = cap ? FmtFlag::Initial : FmtFlag::Nospace
    String.build { |io| to_mtl(io, fmt: fmt) }
  end

  def to_mtl(io : IO, fmt = FmtFlag::Initial) : Nil
    each { |node| fmt = node.to_mtl(io, fmt) }
  end
end
