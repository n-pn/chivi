require "./mt_node"
require "./mt_list/*"

class CV::MtList
  include MTL::Grammars
  include MTL::PadSpace

  getter head = MtNode.new("", "")

  def first
    @head.succ
  end

  def concat!(list : self)
    self.tail.set_succ(list.first)
    self
  end

  def tail(node = @head)
    while node = node.succ
      return node unless node.succ
    end

    @head
  end

  def prepend!(node : MtNode)
    @head.set_succ(node)
  end

  def to_s : String
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO) : Nil
    each { |node| io << node.val }
  end

  def each(node = @head)
    while node = node.succ
      yield node
    end
  end

  def to_str : String
    String.build { |io| to_str(io) }
  end

  def to_str(io : IO) : Nil
    @head.succ.try(&.to_str(io))
  end

  def inspect(io : IO) : Nil
    @head.succ.try(&.inspect(io))
  end

  def capitalize!(cap = true)
    @head.succ.try(&.apply_cap!(cap))
    self
  end
end
