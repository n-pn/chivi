require "./_map_utils"

class TokenMap
  class Item
    include MapItem(Array(String))

    def self.from(line : String)
      cls = line.split('\t', 5)

      key = cls[0]
      val = cls[1]?.try(&.split("  ")) || [""]
      alt = cls[2]? || ""
      mtime = cls[3]?.try(&.to_i?) || 0

      new(key, val, alt, mtime)
    end

    def empty? : Bool
      @val.empty? || @val.first.empty?
    end

    def val_str(io : IO) : Nil
      @val.join(io, "  ")
    end
  end

  include FlatMap(Item)

  alias Index = Hash(String, Item)
  getter _keys = Hash(String, Index).new { |h, k| h[k] = Index.new }

  delegate each, to: @items
  delegate reverse_each, to: @items

  def upsert(item : Item) : Item?
    if old_item = @items[item.key]?
      old_val = old_item.val
      return if old_item.consume(item) # skip if outdated or duplicate

      (old_val - item.val).each { |val| _keys[val].delete(item.key) }
      (item.val - old_val).each { |val| _keys[val][item.key] = item }

      @upd_count += 1
      old_item
    else
      @ins_count += 1
      item.val.each { |val| _keys[val][item.key] = item }
      @items[item.key] = item
    end
  end
end
