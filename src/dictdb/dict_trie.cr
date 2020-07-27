class DictTrie
  SEP_0 = "ǁ"
  SEP_1 = "¦"

  getter key : String
  property vals : Array(String)
  # extra data, can be used to mark attributes or priorities

  getter trie = Hash(Char, DictTrie).new

  def initialize(@key, @vals = [] of String)
  end

  def to_s
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO, trim = 4)
    vals = @vals.uniq
    vals = vals.last(trim) if trim > 0

    io << @key << SEP_0
    vals.join(io, SEP_1)
  end

  def puts(io : IO, trim = 4)
    to_s(io, trim)
    io << "\n"
  end

  def remove!
    @vals.clear
  end

  def removed?
    @vals.empty?
  end

  def each
    queue = [self]

    while node = queue.pop?
      node.trie.each_value do |node|
        queue << node
        yield node unless node.removed?
      end
    end
  end

  def to_a
    res = [] of DictTrie
    each { |node| res << node }
    res
  end

  def find!(key : String) : DictTrie
    node = self

    key.each_char do |char|
      node = node.trie[char] ||= DictTrie.new(node.key + char)
    end

    node
  end

  def find!(key : Array(Char), from = 0) : DictTrie
    node = self

    from.upto(key.size - 1) do |idx|
      char = key.unsafe_fetch(idx)
      node = node.trie[char] ||= DictTrie.new(node.key + char)
    end

    node
  end

  def find(key : String) : DictTrie?
    node = self

    key.each_char do |char|
      return nil unless node = node.trie[char]?
    end

    node unless node.removed?
  end

  def find(key : Array(Char), from = 0) : DictTrie?
    node = self

    from.upto(key.size - 1) do |idx|
      char = key.unsafe_fetch(idx)
      return nil unless node = node.trie[char]?
    end

    node unless node.removed?
  end

  def has_key?(key : String) : Bool
    find(key) != nil
  end

  def scan(chars : Array(Char), from = 0) : Void
    node = self

    from.upto(chars.size - 1) do |idx|
      char = chars.unsafe_fetch(idx)
      return unless node = node.trie[char]?
      yield node unless node.removed?
    end
  end

  def scan(input : String, from = 0) : Void
    scan(input.chars, from) { |node| yield node }
  end

  # class methods

  def self.parse(line : String)
    cols = line.split(SEP_0, 3)
    return cols[0], split(cols[1]?), cols[2]? || ""
  end

  def self.parse_legacy(line : String)
    cols = line.split("=", 2)
    return cols[0], split(cols[1]?, /[\/\|]/)
  end

  def self.split(vals : String?, sep = SEP_1)
    return vals.split(sep) if vals && !vals.empty?
    [] of String
  end
end
