require "./_map_utils"

class TokenMap
  include FlatMap(Array(String))

  alias Index = Hash(String, Array(String))
  getter _index = Hash(String, Index).new { |h, k| h[k] = Index.new }

  def upsert(key : String, value : Array(String), mtime = TimeUtils.mtime) : Bool
    if old_value = get_value(key)
      case get_mtime(key) <=> mtime
      when 1
        return false
      when 0
        return false if value == old_value
      end

      (old_value - value).each { |v| @_index[v].delete(key) }
    end

    @values[key] = value
    @mtimes[key] = mtime if mtime > 0
    value.each { |v| @_index[v][key] = value }

    true
  end

  VAL_SPLIT = "  "

  def value_decode(input : String) : Array(String)
    input.blank? ? [] of String : input.split(VAL_SPLIT)
  end

  def value_encode(value : Array(String)) : String
    value.join(VAL_SPLIT)
  end

  def value_empty?(value : Array(String)) : Bool
    value.empty? || value.first.empty?
  end

  def get_index(val : String) : Index
    @_index[val]? || Index.new
  end

  def search(query : Array(String)) : Index
    return get_index(query.first) if query.size == 1
    return Index.new unless index = get_min_index(query)
    index.select { |_key, value| fuzzy_match?(value, query) } || Index.new
  end

  private def get_min_index(query : Array(String))
    ret = nil
    min = Int32::MAX

    query.each do |token|
      return unless index = get_index(token)

      if index.size < min
        ret = index
        min = index.size
      end
    end

    ret
  end

  private def fuzzy_match?(value : Array(String), query : Array(String))
    return false if value.size < query.size

    m_idx = 0

    value.each do |val|
      next unless val == query[m_idx]
      m_idx += 1
      return true if m_idx == query.size
    end

    false
  end
end
