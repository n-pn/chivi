require "colorize"
require "../../_utils/time_utils"

module FlatMap(T)
  FLUSH_MAX = 10

  getter file : String

  getter values = {} of String => T
  getter mtimes = {} of String => Int32
  getter buffer = Array(String).new(FLUSH_MAX)

  delegate size, to: @values
  delegate has_key?, to: @values

  def initialize(@file : String, preload : Bool = true)
    @label = "#{{{ @type.stringify.underscore }}}: #{file}"
    load!(@file) if preload && File.exists?(@file)
  end

  def get_value(key : String) : T?
    @values[key]?
  end

  def get_mtime(key : String) : Int32
    @mtimes[key]? || 0
  end

  def get_rtime(key : String) : Time
    TimeUtils.rtime(get_mtime(key))
  end

  abstract def value_decode(input : String) : T
  abstract def value_encode(value : T) : String
  abstract def value_empty?(value : T) : Bool

  def entry_encode(io : IO, key : String, value : T, mtime : Int32) : Nil
    io << key << '\t' << value_encode(value)
    io << '\t' << mtime if mtime > 0
  end

  abstract def upsert(key : String, value : T, mtime = TimeUtils.mtime) : Bool

  def upsert!(key : String, value : T, mtime = TimeUtils.mtime) : Bool
    return false unless upsert(key, value, mtime)

    @buffer << key
    flush! if @buffer.size >= FLUSH_MAX

    true # return true if the value is inserted/updated
  end

  def flush! : Nil
    File.open(@file, "a") do |io|
      @buffer.uniq.each do |key|
        entry_encode(io, key, @values[key], get_mtime(key))
        io << '\n'
      end
    end

    @buffer.clear
  end

  def reset! : Nil
    @values.clear
    @mtimes.clear
  end

  delegate each, to: @values
  delegate reverse_each, to: @values

  def inspect(io : IO) : Nil
    io << '['

    each do |key, value|
      io << '⟨' << key
      io << "|" << value_encode(value)

      mtime = get_mtime(key)
      io << "|" << mtime if mtime > 0

      io << '⟩'
    end

    io << ']'
  end

  def load!(file : String) : Nil
    count = 0

    timer = Time.measure do
      File.each_line(file) do |line|
        cls = line.split('\t')

        key = cls[0]
        value = value_decode(cls[1]? || "")
        mtime = cls[2]?.try(&.to_i?) || 0

        upsert(key, value, mtime)
        count += 1
      rescue err
        puts "- <#{@label}> error: #{err} on `#{line}`".colorize.red
      end
    end

    time = timer.total_milliseconds.round.to_i
    puts "- <#{@label}> loaded (lines: #{count}, time: #{time}ms)".colorize.blue
  end

  def save! : Nil
    File.open(file, "w") do |io|
      each do |key, value|
        # pp [key, value]
        mtime = get_mtime(key)
        next if mtime == 0 && value_empty?(value)

        entry_encode(io, key, value, mtime)
        io << '\n'
      end
    end

    puts "- <#{@label}> saved (count: #{@values.size}, fixed: #{@mtimes.size})".colorize.cyan
  rescue err
    puts "- <#{@label}> saves error: #{err}".colorize.red
  end
end
