require "./mt_base"
require "./mt_term"

class M1::MtList < M1::MtNode
  getter list = [] of MtDefn | MtList

  def initialize(
    head : MtNode,
    tail : MtNode,
    @tag : PosTag = PosTag::Unkn,
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
      @list.last.fix_succ!(node)
      @list << node
      node = node.succ?
    end

    if flip
      @list.last.fix_succ!(nil)
      tail.fix_succ!(head)
      tail.fix_prev!(nil)
      @list.unshift(tail)
    else
      @list.last.fix_succ!(tail)
      @list << tail
    end

    # puts "==#fold_list=="
    # puts head.colorize.blue
    # puts tail.colorize.blue
    # puts "==:fold_list=="
    # puts self.colorize.blue
    # puts "==/fold_list=="
  end

  def modifier?
    false
  end

  def add_head!(node : MtDefn)
    self.fix_prev!(node.prev?)

    if fold = TlRule.fold_left(@list.first, node)
      @list[0] = fold
    else
      @list.unshift(node)
    end
  end

  def add_head!(node : MtNode)
    self.fix_prev!(node.prev?)
    @list.unshift(node)
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

  def full_sentence? : Bool
    return false unless list.first.popens?
    list.last.prev? { |x| x.pstops? || x.tilde? || x.ellip? } || false
  end

  ###

  def apply_cap!(cap : Bool = true) : Bool
    cap_2 = @list.reduce(cap || full_sentence?) { |a, x| x.apply_cap!(a) }
    cap_2 || (cap && @tag.paren_expr?)
  end

  def regen_list!
    head = @list.first
    @list.clear

    while head
      @list << head
      head = head.succ?
    end
  end

  def to_txt(io : IO) : Nil
    @list.each do |node|
      io << ' ' if node.space_before?(node.prev?)
      node.to_txt(io)
    end
  end

  def to_mtl(io : IO = STDOUT) : Nil
    io << '〈' << @dic << '\t'

    @list.each do |node|
      io << "\t " if node.space_before?(node.prev?)
      node.to_mtl(io)
    end

    io << '〉'
  end

  def inspect(io : IO = STDOUT, pad = 0) : Nil
    io << " " * pad << "{" << @tag.tag << "/" << @dic << "}" << '\n'

    @list.each(&.inspect(io, pad + 2))

    io << " " * pad << "{/" << @tag.tag << "/" << @dic << "}"
    io << '\n' if pad > 0

    # gets
  end
end
