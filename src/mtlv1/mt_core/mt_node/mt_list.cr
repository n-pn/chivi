require "./mt_term"

class CV::MtList < CV::MtNode
  getter list = [] of MtTerm | MtList

  def initialize(
    head : MtTerm | MtList,
    tail : MtTerm | MtList,
    @tag : PosTag = PosTag::None,
    @dic = 0,
    @idx = 1,
    flip = false
  )
    self.fix_prev!(head.prev?)
    self.fix_succ!(head.succ?)

    node = head

    while node && node != tail
      @list << node
      node = node.succ?
    end

    if flip
      @list.unshift(tail)
    else
      @list << tail
    end
  end

  def starts_with?(key : String | Char)
    @list.any?(&.starts_with?(key))
  end

  def ends_with?(key : String | Char)
    @list.any?(&.ends_with?(key))
  end

  def find?(key : String | Char)
    @list.find(&.find?(key))
  end

  ###

  def apply_cap!(cap : Bool = true) : Bool
    @list.reduce(cap) { |memo, node| node.apply_cap!(memo) }
  end

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
