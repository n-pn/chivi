require "./value_map"

class CV::OrderMap < CV::ValueMap
  class Node
    getter key : String
    property val : Int32
    property prev : Node?
    property succ : Node?

    def initialize(@key, @val = -1, @prev = nil, @succ = nil)
    end

    def set_prev(node : self) : Nil
      if prev = @prev
        prev.succ = node
        node.prev = prev
      end

      node.succ = self
      @prev = node
    end

    def set_succ(node : self) : Nil
      if succ = @succ
        succ.prev = node
        node.succ = succ
      end

      node.prev = self
      @succ = node
    end

    def set_far_prev(node : self) : Nil
      prev = self

      while prev = prev.prev
        if prev.val < node.val
          return prev.set_succ(node)
        end
      end
    end

    def set_far_succ(node : self) : Nil
      succ = self

      while succ = succ.succ
        if succ.val > node.val
          return succ.set_prev(node)
        end
      end
    end

    def unlink!
      @prev.try(&.succ = @succ)
      @succ.try(&.prev = @prev)
    end
  end

  class PrevIter
    include Iterator(Node)

    def initialize(@curr : Node, @done : Node)
    end

    def next
      if @curr != @done
        @curr = @curr.prev.not_nil!
      else
        stop
      end
    end
  end

  class SuccIter
    include Iterator(Node)

    def initialize(@curr : Node, @done : Node)
    end

    def next
      if @curr != @done
        @curr = @curr.succ.not_nil!
      else
        stop
      end
    end
  end

  class List
    getter data : Hash(String, Node)
    getter head : Node
    getter tail : Node

    def initialize
      @data = {} of String => Node

      @head = Node.new("_head_", Int32::MIN)
      @tail = Node.new("_tail_", Int32::MAX)
      @head.set_succ(@tail)

      @_min = 0
      @_max = 0
      @_avg = 0
    end

    def add(key : String, val : Int32) : Nil
      if old_node = @data[key]?
        return if old_node.val == val

        old_node.val = val
        node = old_node
        node.unlink!
      else
        node = @data[key] = Node.new(key, val)
      end

      # fix order
      if @data.size == 1
        @_max = val
        @_min = val
        @tail.set_prev(node)
      elsif val >= @_max
        @_max = val
        @tail.set_prev(node)
      elsif val <= @_min
        @_min = val
        @head.set_succ(node)
      elsif @_max &- val < val &- @_min
        @tail.set_far_prev(node)
      else
        @head.set_far_succ(node)
      end
    end

    def del(key : String) : Nil
      @data[key]?.try(&.unlink!)
    end

    def each(node : Node = @head)
      SuccIter.new(node.not_nil!, @tail)
    end

    def reverse_each(node : Node = @tail)
      PrevIter.new(node, @head)
    end

    def each(node = @head.succ) : Nil
      while node
        break if node == @tail
        yield node
        node = node.succ
      end
    end

    def reverse_each(node = @tail.prev) : Nil
      while node
        break if node == @head
        yield node
        node = node.prev
      end
    end
  end

  getter _idx = List.new

  def set(key : String, val : Int32, ext = [] of String) : Bool
    return false unless super(key, [val.to_s].join(ext))
    @_idx.add(key, val)
    true
  end

  def set(key : String, vals : Array(String)) : Bool
    return false unless super(key, vals)

    if val = vals[0]?.try(&.to_i?)
      @_idx.add(key, val)
    else
      @_idx.del(key)
    end

    true
  end

  def del(key : String)
    @_idx.del(key)
    super
  end

  def get_idx(key : String) : Node?
    @_idx.data[key]?
  end

  def get_val(key : String) : Int32?
    get_idx(key).try(&.val)
  end

  def each
    @_idx.each do |node|
      yield(node.key, @data[node.key])
    end
  end
end
