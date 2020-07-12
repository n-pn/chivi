require "json"
require "colorize"
require "file_utils"

class ValueSet
  getter file : String

  getter list = Set(String).new
  forward_missing_to @list

  def initialize(@file, preload : Bool = false)
    load!(@file) if preload && exists?
  end

  def exists?
    File.exists?(@file)
  end

  def load!(file : String = @file) : Void
    count = 0

    File.each_line(file) do |line|
      @list << line.strip
      count += 1
    end

    puts "- <value_set> [#{file.colorize.blue}] loaded \
            (lines: #{count.colorize.blue})."
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
    File.open(@file, "a") { |io| io.puts(key) }
  end

  def to_s
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO)
    @list.each { |key| io.puts(key) }
  end

  def save!(file : String = @file) : Void
    File.write(file, self)
    puts "- <value_set> [#{file.colorize.yellow}] saved \
            (entries: #{size.colorize.yellow})."
  end

  # class methods

  DIR = File.join("var", "value_sets")
  FileUtils.mkdir_p(DIR)

  def self.path_for(name : String)
    File.join(DIR, "#{name}.txt")
  end

  CACHE = {} of String => ValueSet

  def self.load(name : String, cache = true, preload = true) : self
    unless data = CACHE[name]?
      data = new(path_for(name), preload: preload)
      CACHE[name] = data if cache
    end

    data
  end
end
