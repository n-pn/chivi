require "colorize"
require "file_utils"

require "../common/file_util"
require "./trie_node"

# TODO: rename?
class TrieDict
  LABEL = "trie_dict"

  getter file : String
  getter time = Time.utc(2020, 1, 1)

  getter root = TrieNode.new("")
  getter size = 0

  def initialize(@file, preload : Bool = false, legacy : Bool = false)
    load!(@file) if preload && exists?
  end

  def time=(time : Time)
    @time = time if @time < time
  end

  def exists?
    File.exists?(@file)
  end

  def load_legacy!(file : String = @file) : Void
    FileUtil.each_line(file, LABEL) do |line|
      key, vals = TrieNode.parse_legacy(line)
      upsert(key, vals)
    rescue err
      FileUtil.log_error(LABEL, line, err)
    end
  end

  def load!(file : String = @file) : Void
    FileUtil.each_line(file, LABEL) do |line|
      key, vals, extra = TrieNode.parse(line)
      upsert(key, vals, extra)
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

  def upsert!(key : String, value : String, extra = "")
    append!(upsert(key, value, extra))
  end

  def upsert!(key : String, vals : Array(String), extra = "")
    append!(upsert(key, vals, extra))
  end

  def upsert!(key : String)
    node = upsert(key) { |node| yield node }
    append!(node)
  end

  def append!(node : TrieNode, trim = 1) : TrieNode
    FileUtil.append(@file) { |io| node.puts(io, trim: trim) }
    node
  end

  def upsert(key : String, value : String = "", extra = "")
    upsert(key) do |node|
      node.vals = [value]
      node.extra = extra
    end
  end

  def upsert(key : String, vals : Array(String), extra = "") : TrieNode
    upsert(key) do |node|
      node.vals = vals
      node.extra = extra
    end
  end

  def upsert(key : String) : TrieNode
    node = @root.find!(key)

    @size += 1 if node.removed?
    yield node
    @size -= 1 if node.removed?
    node
  end

  include Enumerable(TrieNode)
  delegate each, to: @root
  delegate scan, to: @root
  delegate find, to: @root
  delegate has_key?, to: @root

  def save!(file : String = @file, trim = 0) : Void
    FileUtil.save(file, LABEL, @size) do |io|
      each { |node| node.puts(io, trim: trim) }
    end
  end

  # class methods

  DIR = File.join("var", "dictdb")
  FileUtils.mkdir_p(File.join(DIR, "unique"))

  def self.path_for(dname : String)
    File.join(DIR, "#{dname}.dic")
  end

  def self.init(name : String)
    new(path_for(name), preload: false)
  end

  def self.load!(name : String)
    new(path_for(name), preload: true)
  end

  def self.read(file : String)
    new(file, preload: true)
  end

  def self.read_legacy(file : String)
    new(file, preload: false).tap(&.load_legacy!)
  end

  CACHE = {} of String => TrieDict

  def self.preload!(name : String)
    CACHE[name] ||= load!(name)
  end

  class_getter cc_cedict : TrieDict { load!("system/cc_cedict") }
  class_getter trungviet : TrieDict { load!("system/trungviet") }
  class_getter tradsim : TrieDict { load!("system/tradsim") }
  class_getter binh_am : TrieDict { load!("system/binh_am") }

  class_getter hanviet : TrieDict { preload!("hanviet") }
  class_getter generic : TrieDict { preload!("generic") }
  class_getter suggest : TrieDict { preload!("suggest") }
  class_getter combine : TrieDict { preload!("combine") }

  def self.load_unique(dname : String)
    preload!("unique/#{dname}")
  end

  def self.load_unsure(dname : String)
    case dname
    when "hanviet" then hanviet
    when "generic" then generic
    when "combine" then combine
    when "suggest" then suggest
    else                load_unique(dname)
    end
  end

  def self.for_convert(dname = "combine")
    special = dname == "combine" ? combine : load_unique(dname)
    {hanviet, generic, special}
  end
end

# test = TrieDict.new("tmp/test_lex_dict.dic", preload: true)

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
