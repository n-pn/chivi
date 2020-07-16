require "json"
require "colorize"
require "file_utils"

require "../common/file_util"

class ValueSet
  LABEL = "value_set"

  getter file : String
  getter list = Set(String).new
  forward_missing_to @list

  def initialize(@file, preload : Bool = true)
    load!(@file) if preload
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

  DIR = File.join("var", "lookup", "values")
  FileUtils.mkdir_p(DIR)

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
    new(file, preload: true)
  end

  # load file if exists, else raising exception
  def self.load!(name : String) : ValueSet
    load(name) || raise "<#{LABEL}> name [#{name}] not found!"
  end

  # load file if exists, else return nil
  def self.load(name : String) : ValueSet?
    file = path_for(name)
    new(file, preload: true) if File.exists?(file)
  end

  # create new file from fresh
  def self.init(name : String) : ValueSet
    new(path_for(name), preload: false)
  end

  # load existing or create a new one
  def self.get_or_create(name : String) : ValueSet
    load(name) || init(name)
  end

  CACHE = {} of String => ValueSet

  def self.preload!(name : String) : ValueSet
    CACHE[name] ||= load!(name)
  end

  class_getter skip_titles : ValueSet { preload!("skip-titles") }
  class_getter skip_genres : ValueSet { preload!("skip-genres") }
end
