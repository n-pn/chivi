class M1::VpHint
  DIR = "var/vhint"

  class_getter seed_vals : self { new("#{DIR}/phrase/legacy", 256) }
  class_getter user_vals : self { new("#{DIR}/phrase/viuser", 256) }

  class_getter seed_tags : self { new("#{DIR}/postag/bd_lac", 256) }
  class_getter user_tags : self { new("#{DIR}/postag/viuser", 256) }

  ##########

  class Trie
    property vals : Array(String)? = nil
    getter hash = Hash(Char, Trie).new { |h, c| h[c] = Trie.new }
    forward_missing_to @hash
  end

  getter data : Hash(Int32, Trie)

  def initialize(@root : String, @split = 128)
    Dir.mkdir_p(@root)
    @data = Hash(Int32, Trie).new(initial_capacity: @split)
  end

  def get_trie(char : Char)
    group = char.ord % @split
    @data[group] ||= read_trie(File.join("#{@root}/#{group}.tsv"))
  end

  def read_trie(file : String, trie = Trie.new) : Trie
    return trie unless File.exists?(file)

    File.each_line(file) do |line|
      vals = line.split('\t')
      vals.shift?.try { |key| upsert(key, vals, trie) }
    end

    trie
  end

  def upsert(key : String, vals : Array(String), node = get_trie(key[0]))
    key.each_char { |c| node = node.hash[c] }
    node.vals = vals.empty? ? nil : vals
  end

  def upsert!(key : String, vals : Array(String))
    upsert(key, vals)
    atomic_save!(key, vals)
  end

  def append(key : String, vals : Array(String), node = get_trie(key[0]))
    key.each_char { |c| node = node.hash[c] }
    node.vals = node.vals.try(&.concat(vals).uniq!) || vals
  end

  def append!(key : String, vals : Array(String))
    vals = append(key, vals)
    atomic_save!(key, vals)
  end

  def atomic_save!(key : String, vals : Array(String))
    file = File.join("#{@root}/#{key[0]}.tsv")

    File.open(file, "a") do |io|
      io << '\n' << key << '\t' << vals.join('\t')
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
