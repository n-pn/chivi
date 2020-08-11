require "colorize"
require "file_utils"

require "../../utils/file_util"

require "./shared/dict_item"
require "./shared/dict_trie"

# TODO: rename?
class Libcv::Lexicon
  LABEL = "lexicon"

  getter file : String
  getter root = DictTrie.new
  getter size = 0

  def initialize(@file, mode : Int32 = 1, type : Int32 = 0)
    return if mode == 0
    load!(@file, type: type) if mode == 2 || File.exists?(@file)
  end

  def load!(file = @file, type = 0) : Void
    FileUtil.each_line(file, LABEL) do |line|
      item = DictItem.parse(line, type: type)
      upsert(item, freeze: false)
    rescue err
      FileUtil.log_error(LABEL, line, err)
    end
  end

  def upsert(item : DictItem, freeze = true)
    node = @root.find!(key)

    @size += 1 if node.removed?
    node = yield node
    @size -= 1 if node.removed?

    File.open(@file, "a", &.puts(node)) if freeze
    node
  end

  def delete(key : String, freeze = true)
    upsert(key, freeze, &.vals = [] of String)
  end

  include Enumerable(DictTrie)
  delegate each, to: @root
  delegate scan, to: @root
  delegate find, to: @root
  delegate has_key?, to: @root

  def save!(file : String = @file) : Void
    FileUtil.save(file, LABEL, @size) { |io| each(&.puts(io)) }
  end

  # class methods

  DIR = File.join("var", "libcv", "lexicon")

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
