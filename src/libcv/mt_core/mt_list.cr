require "./mt_node"
require "./mt_list/*"

class CV::MtList
  include Improving
  include ApplyCaps
  include PadSpaces

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
    return unless node = @head.succ
    node.to_str(io)

    while node = node.succ
      io << '\t'
      node.to_str(io)
    end
  end

  def inspect(io : IO) : Nil
    node = @head
    while node = node.succ
      node.inspect(io)
    end
  end
end
