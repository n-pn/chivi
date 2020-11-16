require "./_map_utils"

class OrderMap
  class Node
    getter key : String
    property value : Int32

    def initialize(@key, @value = -1)
    end

    property _prev : Node? = nil
    property _succ : Node? = nil

    def set_prev(node : self) : Nil
      if prev = @_prev
        prev._succ = node
        node._prev = prev
      end

      @_prev = node
      node._succ = self
    end

    def set_succ(node : self) : Nil
      if succ = @_succ
        succ._prev = node
        node._succ = succ
      end

      @_succ = node
      node._prev = self
    end

    def set_far_prev(node : self) : Nil
      prev = self

      while prev = prev._prev
        if prev.value < node.value
          return prev.set_succ(node)
        end
      end
    end

    def set_far_succ(other : self) : Nil
      node = self

      while node = node._succ
        if node.value > other.value
          return node.set_prev(other)
        end
      end
    end

    def unlink!
      @_prev.try(&._succ = @_succ)
      @_succ.try(&._prev = @_prev)
    end
  end

  include FlatMap(Int32)

  getter _index = {} of String => Node

  getter _head = Node.new("_head", Int32::MIN)
  getter _tail = Node.new("_tail", Int32::MAX)

  @_min = 0
  @_max = 0
  @_avg = 0

  def initialize(@file : String, preload : Bool = true)
    @_head.set_succ(@_tail)
    super(file, preload)
  end

  def upsert(key : String, value : Int32, mtime = TimeUtils.mtime) : Bool
    if old_value = get_value(key)
      case get_mtime(key) <=> mtime
      when 1
        return false
      when 0
        return false if value == old_value
      else
        if value == old_value
          @mtimes[key] = mtime
          return true
        end
      end

      node = @_index[key]
      node.value = value
      node.unlink!
    else
      @_index[key] = node = Node.new(key, value)
    end

    @values[key] = value
    @mtimes[key] = mtime if mtime > 0

    # fix order
    if @_index.size == 1
      @_max = value
      @_min = value
      @_tail.set_prev(node)
    elsif value >= @_max
      @_max = value
      @_tail.set_prev(node)
    elsif value <= @_min
      @_min = value
      @_head.set_succ(node)
    elsif @_max &- value < value &- @_min
      @_tail.set_far_prev(node)
    else
      @_head.set_far_succ(node)
    end

    true
  end

  def get_index(key : String) : Node?
    @_index[key]?
  end

  def each(node = @_head) : Nil
    while node = node._succ
      break if node == @_tail
      yield ({node.key, node.value})
    end
  end

  def reverse_each(node = @_tail) : Nil
    while node = node._prev
      break if node == @_head
      yield ({node.key, node.value})
    end
  end

  def value_decode(input : String) : Int32
    input.to_i? || -1
  end

  def value_encode(value : Int32) : String
    value.to_s
  end

  def value_empty?(value : Int32) : Bool
    value == -1
  end

  def first_key
    @_head.succ.not_nil!.key
  end

  def last_key
    @_tail.prev.not_nil!.key
  end
end
