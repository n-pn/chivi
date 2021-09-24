require "./mt_node"
require "./mt_list/*"

class CV::MtList
  getter root = MtNode.new("", "")

  include Improving
  include ApplyCaps
  include PadSpaces

  def first? : MtNode?
    @root.succ
  end

  def concat!(list : self, node = @root)
    while node = node.succ
      unless node.succ
        node.set_succ(list.root)
        return self
      end
    end

    self
  end

  def prepend!(node : MtNode)
    @root.set_succ(node)
  end

  def single? : Bool
    @root.succ.try(&.succ.!) || false
  end

  def to_s : String
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO) : Nil
    each { |node| io << node.val }
  end

  def each(node = @root)
    while node = node.succ
      yield node
    end
  end

  def to_str : String
    String.build { |io| to_str(io) }
  end

  def to_str(io : IO) : Nil
    return unless node = @root.succ
    node.to_str(io)

    while node = node.succ
      io << '\t'
      node.to_str(io)
    end
  end

  def inspect(io : IO) : Nil
    node = @root
    while node = node.succ
      node.inspect(io)
    end
  end
end
