require "./value_map"

class CV::TokenMap < CV::ValueMap
  alias Index = Hash(String, Array(String))
  getter _idx = Hash(String, Index).new { |h, k| h[k] = Index.new }

  def set(key : String, vals : Array(String)) : Bool
    old_vals = get(key)
    return false unless super

    (old_vals - vals).each { |v| @_idx[v].delete(key) } if old_vals
    vals.each { |v| @_idx[v][key] = vals }

    true
  end

  def del(key : String)
    get(key).try(&.each { |v| @_idx[v].delete(key) })
    super
  end

  def glob(val : String) : Index
    @_idx[val]? || Index.new
  end

  def glob(tsv : Array(String)) : Index
    return glob(tsv.first) if tsv.size == 1
    return Index.new unless index = glob_min(tsv)
    index.select { |_key, vals| fuzzy_match?(vals, tsv) } || Index.new
  end

  private def glob_min(tsv : Array(String))
    ret = nil
    min = Int32::MAX

    tsv.each do |val|
      return unless index = glob(val)

      if index.size < min
        ret = index
        min = index.size
      end
    end

    ret
  end

  private def fuzzy_match?(vals : Array(String), tsv : Array(String))
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

# puts test.glob("a")
# puts test.glob(["b"])
