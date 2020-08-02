require "json"
require "colorize"
require "file_utils"

require "../utils/file_util"

class LabelMap
  LABEL = "label_map"
  SEP_0 = "ǁ"
  SEP_1 = "¦"

  getter file : String

  getter hash = Hash(String, String).new
  getter keys = Hash(String, Array(String)).new { |h, k| h[k] = [] of String }

  delegate size, to: @hash
  delegate each, to: @hash
  delegate fetch, to: @hash
  delegate has_key?, to: @hash

  # modes: 0 => init, 1 => load if exists, 2 => force load, raise exception if not exists
  def initialize(@file, mode : Int32 = 1)
    return if mode == 0
    load!(@file) if mode == 2 || File.exists?(file)
  end

  def load!(file : String = @file) : Void
    FileUtil.each_line(file, LABEL) do |line|
      key, val = line.strip.split(SEP_0)
      val.empty? ? delete(key) : upsert(key, val)
    rescue err
      FileUtil.log_error(LABEL, line, err)
    end
  end

  def keys(val : String)
    @keys[val]?
  end

  def fetch(key : String)
    @hash.fetch(key, nil)
  end

  def upsert!(key : String, val : String) : Void
    append!(key, val) if upsert(key, val)
  end

  def upsert(key : String, val : String) : String?
    if old = fetch(key)
      return if val == old
      @keys[old].delete(key)
    end

    @keys[val] << key
    @hash[key] = val
  end

  def delete!(key : String) : Void
    append!(key, "") if delete(key)
  end

  def delete(key : String) : String?
    if old = @hash.delete(key)
      return old if @keys[old].delete(key)
    end
  end

  def append!(key : String, val = "") : Void
    FileUtil.append(@file) { |io| to_s(io, key, val) }
  end

  def to_s
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO)
    @hash.each { |key, val| to_s(io, key, val) }
  end

  private def to_s(io : IO, key : String, val : String)
    io << key << SEP_0 << val << "\n"
  end

  def save!(file : String = @file) : Void
    FileUtil.save(file, LABEL, @hash.size) { |io| to_s(io) }
  end

  # class methods

  DIR = File.join("var", "bookdb")
  FileUtils.mkdir_p(File.join(DIR, "_import", "fixes"))

  def self.path_for(name : String) : String
    File.join(DIR, "#{name}.txt")
  end

  def self.name_for(file : String) : String
    File.sub("#{DIR}/", "").sub(".txt", "")
  end

  def self.exists?(name : String) : Bool
    File.exists?(path_for(file))
  end

  def self.read!(file : String) : LabelMap
    new(file, mode: 2)
  end

  def self.read(file : String) : LabelMap
    new(file, mode: 1)
  end

  def self.load!(name : String) : LabelMap
    new(path_for(name), mode: 2)
  end

  def self.load(name : String) : LabelMap
    new(path_for(name), mode: 1)
  end

  def self.init(name : String) : LabelMap
    new(path_for(name), mode: 0)
  end

  CACHE = {} of String => LabelMap

  def self.preload!(name : String) : LabelMap
    CACHE[name] ||= load!(name)
  end

  def self.preload(name : String) : LabelMap
    CACHE[name] ||= load(name)
  end

  def self.flush!
    CACHE.each_value { |item| item.save! }
  end

  class_getter book_slug : LabelMap { preload("indexes/book_slug") }

  class_getter zh_author : LabelMap { preload("_import/fixes/zh_author") }
  class_getter vi_author : LabelMap { preload("_import/fixes/vi_author") }

  class_getter zh_title : LabelMap { preload("_import/fixes/zh_title") }
  class_getter vi_title : LabelMap { preload("_import/fixes/vi_title") }

  class_getter zh_genre : LabelMap { preload("_import/fixes/zh_genre") }
  class_getter vi_genre : LabelMap { preload("_import/fixes/vi_genre") }
end

# test = LabelMap.new("tmp/label_map.txt")
# test.upsert("a", "b")
# test.upsert!("b", "b")

# puts test.fetch("a")
# puts test.keys("b")

# test.save!
