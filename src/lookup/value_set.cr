require "json"
require "colorize"
require "file_utils"

require "../common/file_util"

class ValueSet
  LABEL = "value_set"

  getter file : String
  getter list = Set(String).new
  forward_missing_to @list

  # modes: 0 => init, 1 => load if exists, 2 => force load, raise exception if not exists
  def initialize(@file : String, mode : Int32 = 1)
    return if mode == 0
    load!(@file) if mode == 2 || File.exists?(file)
  end

  def load!(file : String = @file) : Void
    FileUtil.each_line(file, LABEL) do |line|
      @list << line.strip
    end
  end

  def upsert!(key : String) : Void
    append!(key) if upsert(key)
  end

  def upsert(key : String)
    @list.add(key)
  end

  def delete!(key : String) : Void
    append!(key, "") if delete(key)
  end

  def delete(key : String)
    @list.delete(key)
  end

  def append!(key : String) : Void
    FileUtil.append(@file, &.puts(key))
  end

  def to_s
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO)
    @list.each { |key| io.puts(key) }
  end

  def save!(file : String = @file) : Void
    FileUtil.save(file, LABEL, @list.size) { |io| to_s(io) }
  end

  # class methods

  DIR = File.join("var", "bookdb")
  FileUtils.mkdir_p(File.join(DIR, "_import"))

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
  def self.read!(file : String) : ValueSet
    new(file, mode: 2)
  end

  def self.read(file : String) : ValueSet
    new(file, mode: 1)
  end

  # load file if exists, else raising exception
  def self.load!(name : String) : ValueSet
    new(path_for(name), mode: 2)
  end

  # load file if exists, else return nil
  def self.load(name : String) : ValueSet?
    new(path_for(name), mode: 1)
  end

  # create new file from fresh
  def self.init(name : String) : ValueSet
    new(path_for(name), mode: 0)
  end

  CACHE = {} of String => ValueSet

  def self.preload!(name : String) : ValueSet
    CACHE[name] ||= load!(name)
  end

  def self.preload(name : String) : ValueSet
    CACHE[name] ||= load(name)
  end

  def self.flush!
    CACHE.each_value { |item| item.save! }
  end

  class_getter skip_titles : ValueSet { preload("_import/skip_titles") }
  class_getter skip_genres : ValueSet { preload("_import/skip_genres") }
end
