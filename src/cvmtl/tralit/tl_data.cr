require "./tl_node"

class TL::TlData < Deque(TL::TlNode)
  def to_txt(cap : Bool = true) : String
    String.build { |io| to_txt(io, cap: cap) }
  end

  def to_txt(io : IO, cap : Bool = true) : Nil
    prev = unsafe_fetch(0)
    apply_cap = prev.to_txt(io, cap)

    1.upto(size &- 1).each do |i|
      node = unsafe_fetch(i)
      io << ' ' unless no_space?(prev, node)
      apply_cap = node.to_txt(io, cap && apply_cap)
      prev = node
    end
  end

  def to_mtl(io : IO, cap : Bool = true) : Nil
    prev = unsafe_fetch(0)
    apply_cap = prev.to_mtl(io, cap)

    1.upto(size &- 1).each do |i|
      node = unsafe_fetch(i)
      io << "\t " unless no_space?(prev, node)
      apply_cap = node.to_mtl(io, cap && apply_cap)
      prev = node
    end
  end

  private def no_space?(prev : TlNode, node : TlNode)
    prev.tag.no_space_r? || node.tag.no_space_l?
  end
end