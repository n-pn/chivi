require "colorize"
require "file_utils"

require "../common/file_util"
require "./dict_trie"

# TODO: rename?
class BaseDict
  LABEL = "base_dict"

  getter file : String
  getter trie = DictTrie.new("")
  getter size = 0

  def initialize(@file, mode : Int32 = 1, legacy : Bool = false)
    return if mode == 0
    load!(@file, legacy: legacy) if mode == 2 || File.exists?(@file)
  end

  def load!(file : String = @file, legacy = false) : Void
    sep_0 = legacy ? "=" : DictTrie::SEP_0
    sep_1 = legacy ? "=" : DictTrie::SEP_1

    FileUtil.each_line(file, LABEL) do |line|
      key, vals = DictTrie.parse(line, sep_0, sep_1)
      upsert(key, vals)
    rescue err
      FileUtil.log_error(LABEL, line, err)
    end
  end

  def delete!(key : String)
    append!(delete(key))
  end

  def delete(key : String)
    upsert(key, &.vals.push(""))
  end

  def upsert!(key : String, value : String)
    append!(upsert(key, value))
  end

  def upsert!(key : String, vals : Array(String))
    append!(upsert(key, vals))
  end

  def upsert!(key : String)
    node = upsert(key) { |node| yield node }
    append!(node)
  end

  def append!(node : DictTrie, trim = 1) : DictTrie
    FileUtil.append(@file) { |io| node.puts(io, trim: trim) }
    node
  end

  def upsert(key : String, value : String = "")
    upsert(key, &.vals = [value])
  end

  def upsert(key : String, vals : Array(String)) : DictTrie
    upsert(key, &.vals = vals)
  end

  def upsert(key : String) : DictTrie
    node = @trie.find!(key)

    @size += 1 if node.removed?
    yield node
    @size -= 1 if node.removed?
    node
  end

  include Enumerable(DictTrie)
  delegate each, to: @trie
  delegate scan, to: @trie
  delegate find, to: @trie
  delegate has_key?, to: @trie

  def save!(file : String = @file, trim = 0) : Void
    FileUtil.save(file, LABEL, @size) do |io|
      each { |node| node.puts(io, trim: trim) }
    end
  end

  # class methods

  DIR = File.join("var", "dictdb")

  def self.path_for(name : String)
    File.join(DIR, "#{name}.dic")
  end

  def self.read!(file : String, legacy : Bool = false)
    new(file, mode: 2, legacy: legacy)
  end

  CACHE = {} of String => BaseDict

  def self.load(name : String, mode : Int32 = 1)
    CACHE[name] ||= new(path_for(name), mode: mode, legacy: false)
  end

  def self.load!(file : String)
    load(file, mode: 2)
  end
end

# test = BaseDict.new("tmp/test_lex_dict.dic", preload: true)

# test.upsert("a", "a")
# test.upsert!("a", "b")

# puts test.find("a")

# test.upsert("b", "b")
# test.upsert("abc", "abc")
# test.upsert("bc", "bc")

# test.scan("abc".chars, from: 1) do |item|
#   puts item
# end

# test.scan("abcxyz".chars, from: 1) do |item|
#   puts item.to_s
# end

# test.save!(trim: 1)

# puts test.find("xy")
# puts test.find("xcbsf")

# test.upsert!("xx", "yy")
# test.delete!("xy")

# puts test.size

# test.upsert("xx") do |node|
#   node.vals.clear
# end

# puts test.size
