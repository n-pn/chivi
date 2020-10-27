require "colorize"
require "../_utils/time_utils"

module MapItem(T)
  getter key : String

  getter val : T
  getter alt : String

  getter mtime : Int32

  def initialize(@key, @val, @alt = "", @mtime = TimeUtils.mtime)
  end

  def rtime
    TimeUtils.rtime(mtime)
  end

  abstract def empty? : Bool

  def val_str : String
    String.build { |io| val_str(io) }
  end

  def val_str(io : IO) : Nil
    io << @val
  end

  def blank?
    empty? && @alt.empty?
  end

  def fixed?
    @mtime > 0
  end

  def eql?(other : self)
    @val == other.val && @alt == other.alt
  end

  def to_s
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO) : Nil
    io << key

    if fixed?
      io << '\t' << val_str << '\t' << @alt << '\t' << @mtime
    elsif @alt.empty?
      io << '\t' << val_str unless empty?
    else
      io << '\t' << val_str << '\t' << @alt
    end
  end

  def puts(io : IO)
    to_s(io)
    io << '\n'
  end

  def inspect(io : IO) : Nil
    io << '⟨' << @key

    if fixed?
      io << '|' << val_str << '|' << @alt << '|' << @mtime
    elsif @alt.empty?
      io << '|' << val_str unless empty?
    else
      io << '|' << val_str << '|' << @alt
    end

    io << '⟩'
  end

  def consume(other : self) : Bool
    return false if other.mtime < @mtime
    return false if self.eql?(other)

    @val = other.val
    @alt = other.alt
    @mtime = other.mtime

    true
  end
end

module FlatMap(T)
  getter file : String
  getter items = {} of String => T

  getter ins_count = 0
  getter upd_count = 0

  delegate size, to: @items
  delegate fetch, to: @items
  delegate has_key?, to: @items

  def initialize(@file : String, preload : Bool = true)
    load!(@file) if preload && File.exists?(@file)
  end

  getter label : String { {{ @type.stringify.underscore }} }

  def load!(file : String) : Nil
    load!(file) do |line|
      upsert(T.from(line))
    rescue err
      puts "- <#{label}> [#{File.basename(file)}] error: #{err} on `#{line}`".colorize.red
    end
  end

  def load!(file : String) : Nil
    count = 0

    time = Time.measure do
      File.each_line(file) do |line|
        line = line.strip
        next if line.blank?

        yield line
        count += 1
      end
    end

    time = time.total_milliseconds.round.to_i
    puts "- <#{label}> [#{File.basename(file)}] loaded (lines: #{count}, time: #{time}ms)".colorize.blue
  end

  abstract def upsert(item : T) : T?

  def upsert!(item : T)
    return unless upsert(item)
    File.open(@file, "a", &.puts(item))
  end

  def save!(skip_blank : Bool = true)
    File.open(file, "w") do |io|
      @items.each_value do |item|
        next if skip_blank && item.blank?
        io.puts(item)
      end
    end

    puts "- <#{label}> saved (insert: #{@ins_count}, update: #{@upd_count})".colorize.cyan

    # reset counter after save
    @ins_count = 0
    @upd_count = 0
  rescue err
    puts "- <#{label}> saving error: #{err}".colorize.red
  end

  def clear! : Nil
    @items.clear
    @ins_count = 0
    @upd_count = 0
  end

  abstract def each(&block : T -> _)
  abstract def reverse_each(&block : T -> _)

  def inspect(io : IO)
    io << '['
    each(&.inspect(io))
    io << ']'
  end
end
