class QT::WordDict
  DIR = "var/dicts/qtran/%{name}-words.tsv"

  def self.load(name : String)
    new(DIR % {name: name})
  end

  @data = Trie.new

  def initialize(file : String)
    load_file!(file)
  end

  def load_file!(file : String)
    File.each_line(file) do |line|
      args = line.split('\t')
      next unless key = args[0]?
      # next if key.size > 1

      if val = args[1]?
        add(key, val)
      else
        delete(key)
      end
    end
  end

  def add(key : String, val : String)
    node = @data

    key.each_char do |char|
      trie = node.trie ||= Hash(Char, Trie).new
      node = trie[char] ||= Trie.new
    end

    node.data = val
  end

  def delete(key : String)
    node = @data

    key.each_char do |char|
      return unless (trie = node.trie) && (node = trie[char]?)
    end

    node.data = nil
  end

  def scan(key : String)
    node = @data

    key.each_char do |char|
      return unless (trie = node.trie) && (node = trie[char]?)
      next unless data = node.data
      yield data
    end
  end

  def scan(chars : Array(Char), offset = 0)
    node = @data

    offset.upto(chars.size - 1) do |i|
      char = chars.unsafe_fetch(i)
      return unless (trie = node.trie) && (node = trie[char]?)
      next unless data = node.data
      yield data, i &- offset
    end
  end

  # def find(key : String)
  #   node = @data

  #   key.each_char do |char|
  #     return unless (trie = node.trie) && (node = trie[char]?)
  #   end

  #   node.data
  # end

  class Trie
    property data : String? = nil
    property trie : Hash(Char, Trie)? = nil
  end
end
