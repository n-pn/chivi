require "colorize"
require "file_utils"

require "../../_utils/file_util"
require "./base_dict/dict_trie"

# TODO: rename?
class Oldcv::Engine::BaseDict
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
      upsert(key, vals, freeze: false)
    rescue err
      FileUtil.log_error(LABEL, line, err)
    end
  end

  def upsert(key : String, val : String = "", freeze = true)
    upsert(key, freeze: freeze, &.vals = [val])
  end

  def upsert(key : String, vals : Array(String), freeze = true)
    upsert(key, freeze: freeze, &.vals = vals)
  end

  def upsert(key : String, freeze : Bool = false) : DictTrie
    node = @trie.find!(key)

    @size += 1 if node.removed?
    yield node
    @size -= 1 if node.removed?

    File.open(@file, "a", &.puts(node)) if freeze
    node
  end

  def delete(key : String, freeze = true)
    upsert(key, freeze, &.vals = [] of String)
  end

  include Enumerable(DictTrie)
  delegate each, to: @trie
  delegate scan, to: @trie
  delegate find, to: @trie
  delegate has_key?, to: @trie

  def save!(file : String = @file) : Void
    FileUtil.save(file, LABEL, @size) { |io| each(&.puts(io)) }
  end

  # class Oldcv::methods

  DIR = "_db/dictdb/legacy"

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
# test.upsert("a", "b", freeze: true)

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

# test.upsert("xx", "yy", freeze: true)
# test.delete("xy", freeze: true)

# puts test.size

# test.upsert("xx") do |node|
#   node.vals.clear
# end

# puts test.size
