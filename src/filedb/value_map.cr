require "./_map_utils"

class ValueMap
  class Item
    include MapItem(String)

    def empty? : Bool
      @val.empty?
    end

    def self.from(line : String)
      cls = line.split('\t', 5)

      key = cls[0]
      val = cls[1]? || ""
      alt = cls[2]? || ""
      mtime = cls[3]?.try(&.to_i?) || 0

      new(key, val, alt, mtime)
    end
  end

  include FlatMap(Item)

  delegate each, to: @items
  delegate reverse_each, to: @items

  def upsert(item : Item) : Item?
    if old_item = @items[item.key]?
      return if old_item.consume(item) # skip if outdated or duplicate
      @upd_count += 1
      old_item
    else
      @ins_count += 1
      @items[item.key] = item
    end
  end
end

test = ValueMap.new("tmp/value_map.tsv", preload: false)
test.upsert!(ValueMap::Item.new(key: "a", val: "a"))
test.upsert!(ValueMap::Item.new(key: "b", val: "b", mtime: 0))

pp test.items

test.save!
