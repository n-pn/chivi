require "colorize"

class LogFile
  SEP0 = "ǁ"

  struct Item
    EPOCH = Time.utc(2020, 1, 1)

    getter mtime : Int32
    getter dict : String
    getter key : String
    getter val : String
    getter user : String
    getter power : Int32

    def self.parse!(line : String)
      mtime, dict, key, val, user, level = line.split(SEP)
      mtime = mtime.to_i? || 0
      level = level.to_i? || 0
      new(mtime, dict, key, val, user, level)
    end

    def self.mtime(time = Time.utc)
      (time - EPOCH).total_minutes.to_i
    end

    def initialize(@mtime, @dict, @key, @val, @user, @power)
    end

    def to_s(io : IO)
      io << @mtime << SEP0 << @dict
      io << SEP0 << @key << SEP0 << @val
      io << SEP0 << @user << SEP0 << @power
    end
  end

  alias Data = Array(Item)

  getter file : String
  getter data : Data = Data.new
  delegate size, to: @data

  # getter time : Time = Item::EPOCH

  def initialize(@file, preload : Bool = false)
    load! if preload
  end

  def load! : self
    lines = File.read_lines(@file)

    lines.each do |line|
      upsert(Item.parse!(line))
    rescue
      puts "- <dict_log> [#{line.colorize(:cyan)}] \
            error parsing line: `#{line.colorize(:red)}.`"
    end

    puts "- <dict_log> [#{@file.colorize(:cyan)}] loaded \
          (#{lines.size.colorize(:cyan)} entries)."
    self
  end

  def append(dict : String, key : String, val : String = "", user : String = "guest", power : Int32 = 0, mtime : Int32 = Item.mtime)
    append(Item.new(mtime, dict, key, val, user, power))
  end

  def append(item : Item)
    File.open(@file, "a") { |io| io.puts(item) }
    upsert(item)
  end

  def upsert(item : Item)
    @data << item
  end

  def reorder! : Void
    @data.sort_by!(&.mtime)
  end

  def save!(reorder : Bool = false)
    reorder! if reorder

    @data.uniq!
    File.open(@file, "w") do |io|
      @data.each { |item| io.puts(item) }
    end

    puts "- <dict_log> [#{@file.colorize(:cyan)}] saved."
    self
  end
end
