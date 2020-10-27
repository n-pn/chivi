require "./_map_utils"

class OrderMap
  class Item
    include MapItem(Int32)

    property prev : Item? = nil
    property succ : Item? = nil

    def self.from(line : String)
      cols = line.split('\t')

      key = cols[0]
      val = cols[1]?.try(&.to_i?) || 0
      alt = cols[2]? || ""
      mtime = cols[3]?.try(&.to_i?) || 0

      new(key, val, alt, mtime)
    end

    def empty? : Bool
      @val == 0
    end

    def set_prev(other : self) : Nil
      if node = @prev
        node.succ = other
        other.prev = node
      end

      @prev = other
      other.succ = self
    end

    def set_succ(other : self) : Nil
      if node = @succ
        node.prev = other
        other.succ = node
      end

      @succ = other
      other.prev = self
    end

    def set_far_prev(other : self) : Nil
      node = self

      while node = node.prev
        if node.val < other.val
          return node.set_succ(other)
        end
      end
    end

    def set_far_succ(other : self) : Nil
      node = self

      while node = node.succ
        if node.val > other.val
          return node.set_prev(other)
        end
      end
    end

    def unlink!
      @prev.try(&.succ = @succ)
      @succ.try(&.prev = @prev)
    end
  end

  include FlatMap(Item)

  getter head = Item.new(key: "", val: Int32::MIN, mtime: 0)
  getter tail = Item.new(key: "", val: Int32::MAX, mtime: 0)

  @min = Int32::MAX
  @max = Int32::MIN
  @avg = 0

  def upsert(item : Item) : Item?
    if old_item = @items[item.key]?
      return unless old_item.consume(item) # skip if outdated or duplicate

      @upd_count += 1
      old_item.unlink!
    else
      @ins_count += 1
      @items[item.key] = item

      if @items.size == 1
        @min = item.val
        @max = item.val
        @avg = item.val
        @tail.set_prev(item)

        return item
      end
    end

    # fix order
    if item.val >= @max
      @max = item.val
      @avg = (@max - @min) // 2
      @tail.set_prev(item)
    elsif item.val <= @min
      @min = item.val
      @avg = (@max - @min) // 2
      @head.set_succ(item)
    elsif old_item
      prev = old_item.prev.not_nil!
      succ = old_item.succ.not_nil!

      if item.val < prev.val
        if item.val >= @avg
          prev.set_far_prev(item)
        else
          @head.set_far_succ(item)
        end
      elsif item.val > succ.val
        if item.val <= @avg
          succ.set_far_succ(item)
        else
          @tail.set_far_prev(item)
        end
      else
        prev.set_succ(item)
      end
    elsif item.val >= @avg
      @tail.set_far_prev(item)
    else
      @head.set_far_succ(item)
    end

    item
  end

  def each(node = @head) : Nil
    while node = node.succ
      break if node == @tail
      yield node
    end
  end

  def reverse_each(node = @tail) : Nil
    while node = node.prev
      break if node == @head
      yield node
    end
  end
end
