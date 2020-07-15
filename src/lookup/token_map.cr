require "json"
require "colorize"
require "file_utils"

# mapping key to a list of tokens
class TokenMap
  SEP_0 = "ǁ"
  SEP_1 = "¦"

  getter hash = Hash(String, Array(String)).new
  getter keys = Hash(String, Set(String)).new

  forward_missing_to @hash

  def initialize(@file : String, preload : Bool = false)
    load!(@file) if preload
  end

  def load!(file : String = @file) : Void
    count = 0

    elapsed = Time.measure do
      File.each_line(file) do |line|
        cols = line.strip.split(SEP_0, 2)

        key = cols[0]
        vals = (cols[1]? || "").split(SEP_1)

        vals.empty? ? delete(key) : upsert(key, vals)
        count += 1
      rescue err
        puts "- <token_map> error parsing line `#{line.colorize.red}`: #{err}"
      end
    end

    elapsed = elapsed.total_milliseconds.round.to_i
    puts "- <token_map> [#{file.colorize.blue}] loaded \
            (lines: #{count.colorize.blue}) \
            time: #{elapsed.colorize.blue}ms)."
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

    puts "- <token_map> [#{file.colorize.yellow}] saved \
            (entries: #{@hash.size.colorize.yellow})."
  end

  # class methods
  DIR = File.join("var", "lookup", "tokens")
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
  def self.read!(file : String) : TokenMap
    new(file, preload: true)
  end

  # load file if exists, else raising exception
  def self.load!(name : String) : TokenMap
    load(name) || raise "<token_map> name [#{name}] not found!"
  end

  # load file if exists, else return nil
  def self.load(name : String) : TokenMap?
    file = path_for(name)
    new(file, preload: true) if File.exists?(file)
  end

  # create new file from fresh
  def self.init(name : String) : TokenMap
    new(path_for(name), preload: false)
  end

  # load existing or create a new one
  def self.get_or_create(name : String) : TokenMap
    load(name) || init(name)
  end

  CACHE = {} of String => TokenMap

  def self.preload!(name : String) : TokenMap
    CACHE[name] ||= load!(name)
  end

  class_getter title_zh : TokenMap { preload!("ubid--title_zh") }
  class_getter title_hv : TokenMap { preload!("ubid--title_hv") }
  class_getter title_vi : TokenMap { preload!("ubid--title_vi") }
  class_getter author_zh : TokenMap { preload!("ubid--author_zh") }
  class_getter author_vi : TokenMap { preload!("ubid--author_vi") }
  class_getter genres_vi : TokenMap { preload!("ubid--genres_vi") }
  class_getter tags_vi : TokenMap { preload!("ubid--tags_vi") }
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
