class CV::VpHint
  DIR = "var/vphints"

  class_getter cc_cedict : self { new("#{DIR}/lookup/cc_cedict", 128) }
  class_getter trungviet : self { new("#{DIR}/lookup/trungviet", 128) }
  class_getter trich_dan : self { new("#{DIR}/lookup/trich_dan", 128) }

  class_getter val_hints : self { new("#{DIR}/phrase/val_hints", 128) }

  ##########

  class Trie
    property vals : Array(String)? = nil
    getter hash = Hash(Char, Trie).new { |h, c| h[c] = Trie.new }
    forward_missing_to @hash
  end

  getter data : Hash(Int32, Trie)

  def initialize(@root : String, @split = 128)
    Dir.mkdir_p(@root)
    @data = Hash(Int32, Trie).new { |h, g| h[g] = load_trie(g) }
  end

  def load_trie(group : Int32) : Trie
    trie = Trie.new
    file = File.join("#{@root}/#{group}.tsv")
    read_trie(trie, file) if File.exists?(file)
    trie
  end

  def get_trie(char : Char)
    @data[char.ord % @split]
  end

  def read_trie(trie : Trie, file : String) : Nil
    File.each_line(file) do |line|
      vals = line.split('\t')
      vals.shift?.try { |key| add(key, vals, trie) }
    end
  end

  def find(key : String)
    node = get_trie(key[0])

    key.each_char { |c| return unless node = node[c] }
    node.vals
  end

  def scan(key : String)
    node = get_trie(key[0])
    str = ""

    key.each_char do |char|
      return unless node = node[char]
      str += char
      next unless vals = node.vals
      yield str, vals
    end
  end

  def scan(chars : Array(Char), idx = 0)
    node = get_trie(chars[idx])
    str = ""

    idx.upto(chars.size - 1) do |i|
      char = chars.unsafe_fetch(i)
      return unless node = node[char]

      str += char
      next unless vals = node.vals
      yield str, vals
    end
  end

  def add(key : String, vals : Array(String), node = get_trie(key[0]))
    key.each_char { |c| node = node.hash[c] }
    node.vals = vals.empty? ? nil : vals
  end

  def add!(key : String, vals : Array(String))
    add(key, vals)

    File.open(File.join("#{@root}/#{key[0]}.tsv"), "a") do |io|
      io << '\n' << key << '\t' << vals.join('\t')
    end
  end

  def save!
    @data.each { |group, trie| save_trie!(group, trie) }
  end

  def save_trie!(group : Int32, trie : Trie)
    path = File.join("#{@root}/#{group}.tsv")
    file = File.open(path, "w")

    queue = [{"", trie}]
    count = 0

    while entry = queue.pop?
      key, node = entry
      node.hash.each { |c, t| queue << {key + c, t} }
      next unless vals = node.vals

      count &+= 1
      file << key << '\t' << vals.join('\t') << '\n'
    end

    # Log.info { "- #{path} saved, entries: #{count}" }
    file.close
  end
end
