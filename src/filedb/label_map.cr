require "json"
require "colorize"
require "file_utils"

class LabelMap
  SEP = "ǁ"

  getter file : String
  getter data = Hash(String, String).new
  forward_missing_to @data

  def initialize(@file, preload : Bool = false)
    load!(@file) if preload && exists?
  end

  def exists?
    File.exists?(@file)
  end

  def load!(file : String = @file) : Void
    File.each_line(file) do |line|
      key, val = line.strip.split(SEP, 2)
      if val.empty?
        @data.delete(key)
      else
        @data[key] = val
      end
    rescue err
      puts "- <map_label> error parsing line `#{line}`: #{err.colorize(:red)}"
    end

    puts "- <map_label> [#{file.colorize(:cyan)}] loaded."
  end

  def fetch(key : String)
    @data.fetch(key, nil)
  end

  def upsert!(key : String, val : String) : Void
    append!(key, val) if upsert(key, val)
  end

  def upsert(key : String, val : String) : String?
    if old_val = fetch(key)
      return nil if val == old_val
      @data[key] = val
    else
      @data.delete(key)
    end
  end

  def delete!(key : String) : Void
    append!(key, "") if delete(key)
  end

  def delete(key : String) : String
    @data.delete(key)
  end

  def append!(key : String, val = "") : Void
    File.open(@file, "a") { |io| to_s(io, key, val) }
  end

  def to_s
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO)
    @data.each { |key, val| to_s(io, key, val) }
  end

  private def to_s(io : IO, key : String, val : String)
    io << key << SEP << val << "\n"
  end

  def save!(file : String = @file) : Void
    File.write(file, self)
    puts "- <map_label> [#{file.colorize(:cyan)}] saved, entries: #{size}."
  end

  # class methods

  DIR = File.join("var", "label_maps")
  FileUtils.mkdir_p(DIR)

  def self.path_for(name : String)
    File.join(DIR, "#{name}.txt")
  end

  def self.load!(name : String, preload : Bool = true)
    new(path_for(name), preload: preload)
  end

  CACHE = {} of String => LabelMap

  def self.load_cache!(name : String, preload : Bool = true)
    CACHE[name] ||= load!(name, preload: preload)
  end
end
