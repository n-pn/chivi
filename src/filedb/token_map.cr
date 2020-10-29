require "./_map_utils"

class TokenMap
  include FlatMap(Array(String))

  alias Index = Hash(String, Array(String))
  getter _index = Hash(String, Index).new { |h, k| h[k] = Index.new }

  def upsert(key : String, value : Array(String), mtime = TimeUtils.mtime) : Array(String)?
    if old_value = get_value(key)
      case get_mtime(key) <=> mtime
      when 1
        return
      when 0
        return if value == old_value
      end

      (old_val - value).each { |val| @_index[val].delete(key) }
    end

    value.each { |val| @_index[value][key] = value }

    @mtimes[key] = mtime if mtime > 0
    @values[key] = value
  end

  VAL_SPLIT = "  "

  def value_decode(input : String?) : Array(String)
    return [] of String if input.nil? || input.blank?
    input.split(VAL_SPLIT)
  end

  def value_encode(value : Array(String)) : String
    value.join(VAL_SPLIT)
  end

  def value_empty?(value : Array(String)) : Bool
    value.empty? || value.first.empty?
  end

  def get_index(val : String) : Index?
    @_index[val]?
  end

  def search(query : Array(String)) : Index
    return get_index(query.first) if query.size == 1
    return Index.new unless index = get_min_index(query)
    index.select { |_key, value| fuzzy_match?(value, query) }
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
