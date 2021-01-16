require "./value_map"

class CV::TokenMap < CV::ValueMap
  @@klass = "token_map"

  alias Index = Set(String)
  getter _idx = Hash(String, Index).new { |h, k| h[k] = Index.new }

  def set(key : String, vals : Array(String)) : Bool
    old_vals = get(key)
    return false unless super

    (old_vals - vals).each { |v| @_idx[v].delete(key) } if old_vals
    vals.each { |v| @_idx[v].add(key) }

    true
  end

  def del(key : String)
    get(key).try(&.each { |v| @_idx[v].delete(key) })
    super
  end

  def has_val?(val : String)
    !keys(val).empty?
  end

  def keys(val : String) : Index
    @_idx[val]? || Index.new
  end

  def keys(tsv : Array(String)) : Index
    return keys(tsv.first) if tsv.size == 1

    res = Index.new
    return res unless set = keys_min(tsv)

    set.each do |key|
      next unless vals = get(key)
      res.add(key) if fuzzy_match?(tsv, vals)
    end

    res
  end

  private def keys_min(tsv : Array(String)) : Index?
    ret = nil
    min = Int32::MAX

    tsv.each do |val|
      return unless set = keys(val)

      if set.size < min
        ret = set
        min = set.size
      end
    end

    ret
  end

  private def fuzzy_match?(tsv : Array(String), vals : Array(String)) : Bool
    return false if vals.size < tsv.size

    idx = 0

    vals.each do |val|
      next unless val == tsv[idx]
      idx += 1
      return true if idx == tsv.size
    end

    false
  end
end

# test = CV::TokenMap.new(".tmp/token_map.tsv", mode: 0)
# test.set("a", "a")
# test.set("b", "b\ta")

# puts test.keys("a")
# puts test.keys(["b"])
