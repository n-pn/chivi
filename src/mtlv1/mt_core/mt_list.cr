require "./mt_node"
require "./tl_rule"

class CV::MtList
  getter head = MtNode.new("", "")

  def first?
    @head.succ?
  end

  def concat!(list : self)
    self.tail.set_succ!(list.first?)
    self
  end

  def tail(node = @head)
    while node = node.succ?
      return node unless node.succ?
    end

    @head
  end

  def prepend!(node : MtNode)
    @head.set_succ!(node)
  end

  def each(node = @head)
    while node = node.succ?
      yield node
    end
  end
end
