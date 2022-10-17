require "./has_pos_tag"

abstract class MT::MtNode
  include HasPosTag

  property! prev : MtNode
  property! succ : MtNode

  def prev?
    @prev.try { |x| yield x }
  end

  def succ?
    @succ.try { |x| yield x }
  end

  def fix_prev!(prev : Nil) : Nil
    @prev = nil
  end

  def fix_prev!(@prev : MtNode) : Nil
    prev.succ = self
  end

  def fix_succ!(succ : Nil) : Nil
    @succ = nil
  end

  def fix_succ!(@succ : MtNode) : Nil
    succ.prev = self
  end

  @[AlwaysInline]
  def real_prev : MtNode?
    # TODO: read beyond parenthesis
    return unless node = @prev
    node.start_puncts? || node.close_puncts? ? node.prev? : node
  end

  @[AlwaysInline]
  def real_succ : MtNode?
    # TODO: read beyond parenthesis
    return unless node = @succ
    node.start_puncts? || node.close_puncts? ? node.succ? : node
  end

  def swap_val!
    raise "only available for MonoNode"
  end

  def set!(val : String) : self
    raise "only available for MonoNode"
  end

  def set!(@tag : MtlTag) : self
    self
  end

  def set!(@pos : MtlPos) : self
    self
  end

  abstract def to_txt(io : IO) : Nil
  abstract def to_mtl(io : IO) : Nil
  abstract def inspect(io : IO) : Nil
  abstract def apply_cap!(cap : Bool) : Bool

  def add_space?(prev = self.prev) : Bool
    !(prev.pos.no_space_r? || @pos.no_space_l?)
  end
end

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
    io << " " * pad << "{" << @tag.colorize.cyan << " " << "}" << '\n'
    self.each(&.inspect(io, pad + 2))
    io << " " * pad << "{/" << @tag.colorize.cyan << "}"
    io << '\n' if pad > 0
  end
end

require "./node_base/*"
require "./node_expr/*"
require "./node_form/*"