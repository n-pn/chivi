require "colorize"

class DictLogs
  EPOCH = Time.utc(2020, 1, 1)
  SEP_0 = "ǁ"

  class Log
    def self.mtime(time = Time.utc)
      (time - EPOCH).total_minutes.to_i
    end

    getter mtime : Int32  # time by total minutes since the EPOCH
    getter uname : String # user name
    getter level : Int32  # user power level

    getter key : String
    getter vals : String
    getter extra : String

    def self.parse!(line : String)
      cols = line.split(SEP_0)

      mtime, uname, level, key = cols
      vals = cols.fetch(4, "")
      extra = cols.fetch(5, "")

      new(mtime.to_i, uname, level.to_i, key, vals, extra)
    end

    def initialize(@mtime, @uname, @level, @key, @vals = "", @extra = "")
    end

    def to_s
      String.build { |io| to_s(io) }
    end

    def to_s(io : IO)
      {@mtime, @uname, @level, @key, @vals, @extra}.join(io, SEP_0)
    end

    def puts(io : IO)
      to_s(io)
      io << "\n"
    end

    def better_than?(other : Item)
      return @mtime >= other.mtime if @level == other.level
      @level > other.level
    end
  end

  getter file : String
  getter time = EPOCH

  getter logs = [] of Log
  getter best = {} of String => Log

  delegate size, to: @logs
  delegate each, to: @logs

  def initialize(@file, preload : Bool = false)
    load!(@file) if preload && exists?
  end

  def exists?
    File.exists?(file)
  end

  def load!(file : String = @file) : Void
    lines = File.read_lines(@file)

    lines.each do |line|
      append(Item.parse!(line))
    rescue
      puts "- <dict_logs> error parsing line: `#{line.colorize(:red)}`."
    end

    puts "- <dict_logs> [#{@file.colorize(:cyan)}] loaded \
            (#{lines.size.colorize(:cyan)} entries)."
  end

  def sort! : Void
    @logs.sort_by!(&.mtime)
  end

  def insert!(item : Item)
    append!(item)
    insert(item)
  end

  def append!(item : Item)
    File.open(@file, "a") { |io| item.puts(io) }
  end

  def insert(item : Item) : Void
    @logs << item
    return if @best[item.key]?.try(&.better_than?(item))
    @best[item.key] = item
  end

  def save!(sort : Bool = false)
    sort! if sort
    @logs.uniq!

    File.open(@file, "w") do |io|
      @logs.each { |item| io.puts(item) }
    end

    puts "- <dict_log> [#{@file.colorize(:cyan)}] saved."
    self
  end
end
