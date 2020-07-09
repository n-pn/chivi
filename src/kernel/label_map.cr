require "json"
require "colorize"
require "file_utils"

class LabelMap
  SEP = "ǁ"

  getter file : String

  getter hash = Hash(String, String).new
  getter keys = Hash(String, Array(String)).new { |h, k| h[k] = [] of String }

  delegate size, to: @hash
  delegate each, to: @hash
  delegate fetch, to: @hash

  def initialize(@file, preload : Bool = false)
    load!(@file) if preload && exists?
  end

  def exists?
    File.exists?(@file)
  end

  def load!(file : String = @file) : Void
    count = 0

    File.each_line(file) do |line|
      key, val = line.strip.split(SEP, 2)
      val.empty? ? delete(key) : upsert(key, val)
      count += 1
    rescue err
      puts "- <label_map> error parsing line `#{line}`: #{err.colorize(:red)}"
    end

    puts "- <label_map> [#{file.colorize(:blue)}] loaded \
            (#{count.colorize(:blue)} lines)."
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
    io << key << SEP << val << "\n"
  end

  def save!(file : String = @file) : Void
    File.write(file, self)

    puts "- <label_map> [#{file.colorize(:yellow)}] saved \
            (#{size.colorize(:yellow)} entries)."
  end

  # class methods

  DIR = File.join("var", "label_maps")
  FileUtils.mkdir_p(DIR)

  def self.path_for(name : String)
    File.join(DIR, "#{name}.txt")
  end

  CACHE = {} of String => self

  def self.load(name : String, cache = true, preload = true) : self
    unless item = CACHE[name]?
      item = new(path_for(name), preload: preload)
      CACHE[name] = item if cache
    end

    item
  end
end

# test = LabelMap.new("tmp/label_map.txt")
# test.upsert("a", "b")
# test.upsert("b", "b")

# puts test.fetch("a")
# puts test.keys("b")

# test.save!
