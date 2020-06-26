require "json"
require "colorize"
require "file_utils"

class BookIndex
  SEP  = "ǁ"
  ROOT = File.join("data", "books", "indexes")

  def self.setup!
    FileUtils.mkdir_p(ROOT)
  end

  alias Index = Hash(String, String)
  @data = Index.new

  include Enumerable(Index)
  delegate each, to: @data

  def initialize(@type : String, preload : Bool = false)
    @file = File.join(ROOT, "#{@type}.txt")
    load! if @preload
  end

  def load!
    if File.exists?(@file)
      lines = File.read_lines(@file)
      lines.each do |line|
        key, val = line.split(SEP, 2)
        upsert(key, val)
      end

      reorder! if reorder
      puts "- <book_index> [#{@type.colorize(:cyan)}] loaded \
            (#{@lines.size.colorize(:cyan)} entries)."
    else
      puts "- <book_index> [#{@type.colorize(:red)}] not found!"
    end

    self
  end

  # return true if changed
  def upsert(key : String, val : String) : Bool
    return false if @data[key]? == val
    @data[key] = val

    true
  end

  def delete(key : String)
    @data.delete(key)
  end

  def find(key : String) : String?
    @data[key]?
  end

  def existed?(key : String) : Bool
    @data.has_key?(key)
  end

  def save! : self
    File.open(@file, "w") do |io|
      @data.each { |key, val| io << key << SEP << val << "\n" }
    end

    puts "- <book_index> [#{@type.colorize(:cyan)}] saved."
    self
  end
end
