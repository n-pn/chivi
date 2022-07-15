require "./mt_term"

class CV::MtList < CV::MtNode
  getter list = [] of MtTerm | MtList

  def initialize(
    head : MtNode,
    tail : MtNode,
    @tag : PosTag = PosTag::None,
    @dic = 0,
    @idx = 1,
    flip = false
  )
    self.fix_prev!(head.prev?)
    self.fix_succ!(tail.succ?)

    head.fix_prev!(nil)
    tail.fix_succ!(nil)

    @list << head
    node = head.succ?

    while node && node != tail
      @list << node
      node = node.succ?
    end

    if flip
      @list.last.fix_succ!(nil)
      tail.fix_succ!(head)
      @list.unshift(tail)
    else
      @list << tail
    end

    # puts "==#fold_list=="
    # pp head
    # pp tail
    # puts "==:fold_list=="
    # pp self
    # puts "==/fold_list=="
  end

  def modifier?
    false
  end

  def add_head!(node : MtList)
    self.fix_prev!(node.prev?)
    @list.unshift(node)
  end

  def add_head!(node : MtTerm)
    self.fix_prev!(node.prev?)

    if fold = TlRule.fold_left(@list.first, node)
      @list[0] = fold
    else
      @list.unshift(node)
    end
  end

  ######

  def each
    @list.each do |node|
      yield node
    end
  end

  def to_int?
    nil
  end

  def starts_with?(key : String | Char)
    @list.any?(&.starts_with?(key))
  end

  def ends_with?(key : String | Char)
    @list.any?(&.ends_with?(key))
  end

  def find_by_key(key : String | Char)
    @list.find(&.find_by_key(key))
  end

  def space_before?(prev : MtList)
    true
  end

  def space_before?(prev : MtTerm)
    !(prev.val.blank? || prev.popens?)
  end

  ###

  def apply_cap!(cap : Bool = true) : Bool
    @list.reduce(cap) { |memo, node| node.apply_cap!(memo) }
  end

  def to_txt(io : IO) : Nil
    @list.first.to_txt(io)

    @list.each_cons_pair do |prev, node|
      io << ' ' if node.space_before?(prev)
      node.to_txt(io)
    end
  end

  def to_mtl(io : IO = STDOUT) : Nil
    io << '〈' << @dic << '\t'
    @list.first.to_mtl(io)

    @list.each_cons_pair do |prev, node|
      io << "\t " if node.space_before?(prev)
      node.to_mtl(io)
    end

    io << '〉'
  end

  def inspect(io : IO = STDOUT, pad = 0) : Nil
    io << " " * pad << "{" << @tag.tag << "/" << @dic << "}" << '\n'
    @list.each(&.inspect(io, pad &+ 2))
    io << " " * pad << "{/" << @tag.tag << "/" << @dic << "}"
    io << '\n' if pad > 0
  end
end
