require "json"
require "colorize"
require "file_utils"

class LabelMap
  SEP_0 = "ǁ"

  getter file : String

  getter hash = Hash(String, String).new
  getter keys = Hash(String, Array(String)).new { |h, k| h[k] = [] of String }

  delegate size, to: @hash
  delegate each, to: @hash
  delegate fetch, to: @hash
  delegate has_key?, to: @hash

  def initialize(@file, preload : Bool = true)
    load!(@file) if preload
  end

  def load!(file : String = @file) : Void
    count = 0

    elapsed = Time.measure do
      File.each_line(file) do |line|
        key, val = line.strip.split(SEP_0)
        val.empty? ? delete(key) : upsert(key, val)
        count += 1
      rescue err
        puts "- <label_map> error parsing line `#{line}`: #{err.colorize(:red)}"
      end
    end

    elapsed = elapsed.total_milliseconds.round.to_i
    puts "- <label_map> [#{file.colorize.blue}] loaded \
            (lines: #{count.colorize.blue}) \
            time: #{elapsed.colorize.blue}ms)."
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
    File.open(@file, "a") { |io| to_s(io, key, val) }
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
    File.write(file, self)

    puts "- <label_map> [#{file.colorize.yellow}] saved \
            (entries: #{size.colorize.yellow})."
  end

  # class methods

  DIR = File.join("var", "lookup", "labels")
  FileUtils.mkdir_p(DIR)

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
    new(file, preload: true)
  end

  def self.load!(name : String) : LabelMap
    load(name) || raise "<labep_map> name [#{name}] not found!"
  end

  def self.load(name : String) : LabelMap?
    file = path_for(name)
    new(file, preload: true) if File.exists?(file)
  end

  def self.init(name : String) : LabelMap
    new(path_for(name), preload: false)
  end

  # load existing or create a new one
  def self.get_or_create(name : String) : LabelMap
    load(name) || init(name)
  end

  CACHE = {} of String => LabelMap

  def self.preload!(name : String) : LabelMap
    CACHE[name] ||= load!(name)
  end

  class_getter mapping : LabelMap { preload!("slug--ubid") }
end

# test = LabelMap.new("tmp/label_map.txt")
# test.upsert("a", "b")
# test.upsert("b", "b")

# puts test.fetch("a")
# puts test.keys("b")

# test.save!
