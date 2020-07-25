require "json"
require "colorize"
require "file_utils"

require "../common/file_util"

# mapping key to a list of tokens
class TokenMap
  LABEL = "token_map"
  SEP_0 = "ǁ"
  SEP_1 = "¦"

  getter file : String
  getter hash = Hash(String, Array(String)).new
  getter keys = Hash(String, Set(String)).new

  forward_missing_to @hash

  # modes: 0 => init, 1 => load if exists, 2 => force load, raise exception if not exists
  def initialize(@file : String, mode : Int32 = 1)
    return if mode == 0
    load!(@file) if mode == 2 || File.exists?(file)
  end

  def load!(file : String = @file) : Void
    count = 0

    FileUtil.each_line(file, LABEL) do |line|
      cols = line.strip.split(SEP_0, 2)

      key = cols[0]
      vals = (cols[1]? || "").split(SEP_1)

      vals.empty? ? delete(key) : upsert(key, vals)
    rescue err
      FileUtil.log_error(LABEL, line, err)
    end
  end

  def keys(val : String)
    @keys[val]?
  end

  def search(tokens : Array(String))
    return fuzzy_search(tokens) if tokens.size > 0
    keys(tokens.first) || Set(String).new
  end

  def fuzzy_search(tokens : Array(String))
    output = Set(String).new
    return output unless key_set = min_keys_set(tokens)

    key_set.each do |key|
      values = @hash[key]
      output << key if fuzzy_match?(values, tokens)
    end

    output
  end

  private def fuzzy_match?(values : Array(String), tokens : Array(String))
    return true if tokens.empty?

    token_index = 0

    values.each do |value|
      next unless value == tokens[token_index]
      token_index += 1
      return true if token_index == tokens.size
    end

    false
  end

  private def min_keys_set(vals : Array(String))
    res = nil
    min = Int32::MAX

    vals.each do |val|
      return unless set = @keys[val]?

      if set.size < min
        res = set
        min = set.size
      end
    end

    res
  end

  def upsert!(key : String, vals : Array(String))
    append!(key, vals) if upsert(key, vals)
  end

  def upsert(key : String, vals : Array(String))
    if olds = @hash[key]?
      delete_key(key, olds - vals)
      insert_key(key, vals - olds)
    else
      insert_key(key, vals)
    end

    @hash[key] = vals
  end

  def delete!(key : String)
    append!(key, [] of String) if delete(key)
  end

  def delete(key : String)
    if vals = @hash.delete(key)
      delete_key(key, vals)
      vals
    end
  end

  private def insert_key(key : String, vals : Array(String))
    vals.uniq.each do |val|
      list = @keys[val] ||= Set(String).new
      list << key
    end
  end

  private def delete_key(key : String, vals : Array(String))
    vals.each do |val|
      next unless list = @keys[val]?
      list.delete(key)
    end
  end

  def append!(key : String, vals : Array(String))
    FileUtil.append(@file) { |io| to_s(io, key, vals) }
  end

  def to_s
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO)
    @hash.each { |key, vals| to_s(io) }
  end

  def to_s(io : IO, key : String, vals : Array(String))
    io << key << SEP_0
    vals.join(io, SEP_1)
    io << "\n"
  end

  def save!(file : String = @file) : Void
    FileUtil.save(file, LABEL, @hash.size) do |io|
      @hash.each { |key, vals| to_s(io, key, vals) }
    end
  end

  # class methods
  DIR = File.join("var", "bookdb")
  FileUtils.mkdir_p(File.join(DIR, "indexes", "tokens"))

  # file path relative to `DIR`
  def self.path_for(name : String) : String
    File.join(DIR, "#{name}.txt")
  end

  # file name relative to `DIR`
  def self.name_for(file : String) : String
    File.sub("#{DIR}/", "").sub(".txt", "")
  end

  # check file exists in `DIR`
  def self.exists?(name : String) : Bool
    File.exists?(path_for(file))
  end

  # read random file, raising FileNotFound if not existed
  def self.read!(file : String) : TokenMap
    new(file, mode: 2)
  end

  def self.read(file : String) : TokenMap
    new(file, mode: 1)
  end

  # load file if exists, else raising exception
  def self.load!(name : String) : TokenMap
    new(path_for(name), mode: 2)
  end

  # load file if exists, else create a new one
  def self.load(name : String) : TokenMap
    new(path_for(name), mode: 1)
  end

  # create new file from fresh
  def self.init(name : String) : TokenMap
    new(path_for(name), mode: 0)
  end

  CACHE = {} of String => TokenMap

  def self.preload!(name : String) : TokenMap
    CACHE[name] ||= load!(name)
  end

  def self.preload(name : String) : TokenMap
    CACHE[name] ||= load(name)
  end

  def self.flush! : Void
    CACHE.each_value { |map| map.save! }
  end

  class_getter zh_author : TokenMap { preload("indexes/tokens/zh_author") }
  class_getter vi_author : TokenMap { preload("indexes/tokens/vi_author") }

  class_getter zh_title : TokenMap { preload("indexes/tokens/zh_title") }
  class_getter vi_title : TokenMap { preload("indexes/tokens/vi_title") }
  class_getter hv_title : TokenMap { preload("indexes/tokens/hv_title") }

  class_getter vi_genres : TokenMap { preload("indexes/tokens/vi_genres") }
  class_getter vi_tags : TokenMap { preload("indexes/tokens/vi_tags") }
end

# test = TokenMap.new("tmp/token_map.txt")

# test.upsert("a", ["a", "b", "c"])
# test.upsert("b", ["b", "c"])
# test.upsert("c", ["c"])

# puts test.search(["a", "b", "c"])
# puts test.search(["b", "c"])
# puts test.search(["c", "b"])
# puts test.search(["c"])

# test.save!
