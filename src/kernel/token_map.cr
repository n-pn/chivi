require "json"
require "colorize"
require "file_utils"

# mapping key to a list of tokens
class TokenMap
  SEP_0 = "ǁ"
  SEP_1 = "¦"

  getter hash = Hash(String, Array(String)).new
  getter keys = Hash(String, Array(String)).new

  def initialize(@file : String, preload : Bool = false)
    load!(@file) if preload && exist?
  end

  def exist?
    File.exists?(@file)
  end

  def load!(file : String = @file) : Void
    File.each_line(file) do |line|
      cols = line.strip.split(SEP_0, 2)

      key = cols[0]
      vals = (cols[1]? || "").split(SEP_1)
      if vals.empty?
        delete(key)
      else
        upsert(key, vals)
      end
    rescue err
      puts "- <token_map> error parsing line `#{line.colorize(:red)}`: #{err.message.colorize(:red)}"
    end

    puts "- <token_map> [#{file.colorize(:cyan)}] loaded."
  end

  def search(tokens : Array(String))
    res = [] of String
    return res unless keys = min_keys_set(tokens)

    keys.each do |key|
      values = @hash[key]
      res << key if contains?(values, tokens)
    end

    res
  end

  private def contains?(values : Array(String), tokens : Array(String))
    return true if tokens.empty?

    values.each_with_index do |v, i|
      next unless v == tokens[0]

      j = 1
      while j < tokens.size
        break if values[i + j]? != tokens.unsafe_fetch(j)
        j += 1
      end

      return true if j == tokens.size
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
    vals.each do |val|
      @keys[val] ||= [] of String
      @keys[val] << key
    end
  end

  private def delete_key(key : String, vals : Array(String))
    vals.each do |val|
      next unless keys = @keys[val]?
      keys.delete(key)
    end
  end

  def append!(key : String, vals : Array(String))
    File.open(@file, "a") { |io| to_s(io, key, vals) }
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
    File.open(file, "w") do |io|
      @hash.each { |key, vals| to_s(io, key, vals) }
    end

    puts "- <token_map> [#{file.colorize(:yellow)}] saved \
            (#{size.colorize(:yellow)} entries)."
  end

  # class methods
  DIR = File.join("var", "token_maps")
  FileUtils.mkdir_p(DIR)

  def self.path_for(name : String)
    File.join(DIR, "#{name}.txt")
  end

  CACHE = {} of String => self

  def self.load(file : String) : self
    CACHE[file] ||= new(file, preload: true)
  end
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
