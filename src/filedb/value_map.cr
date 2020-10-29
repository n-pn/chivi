require "./_map_utils"

class ValueMap
  include FlatMap(String)

  def upsert(key : String, value : String, mtime = TimeUtils.mtime) : String?
    if old_value = get_value(key)
      case get_mtime(key) <=> mtime
      when 1
        return
      when 0
        return if value == old_value
      end
    end

    @mtimes[key] = mtime if mtime > 0
    @values[key] = value
  end

  def value_decode(input : String?) : String
    input || ""
  end

  def value_encode(value : String) : String
    value
  end

  def value_empty?(value : String) : Bool
    value.empty?
  end
end

# test = ValueMap.new("tmp/value_map.tsv", preload: false)
# test.upsert!("a", "a")
# test.upsert!("b", "b", mtime: 0)

# pp test
# test.save!
