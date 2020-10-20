require "colorize"
require "file_utils"

module OldFlatFile(T)
  SEP_0 = "ǁ"
  SEP_1 = "¦"

  getter file : String

  abstract def size
  abstract def load!

  # modes:
  # 0 => init
  # 1 => load if exists
  # 2 => force load, raise exception if not exists
  def initialize(@file, mode : Int32 = 1)
    return if mode == 0
    load!(@file) if mode == 2 || File.exists?(file)
  end

  private def read_file(file : String)
    count = 0

    time = Time.measure do
      File.each_line(file) do |line|
        line = line.strip
        next if line.blank?

        arr = line.split(SEP_0, 2)
        yield arr[0], arr[1]?

        count += 1
      rescue err
        puts "- <#{file}> error parsing `#{line}`: #{err}".colorize(:red)
      end
    end

    time = time.total_milliseconds.round.to_i
    puts "- <#{file}> loaded (lines: #{count}, time: #{time}ms)".colorize(:blue)
  end

  private def puts(io : IO, key : String, val : T)
    io << key << SEP_0
    to_s(io, val)
    io << "\n"
  end

  abstract def upsert(key : String, val : T)

  def upsert!(key : String, val : T)
    return unless upsert(key, val)
    File.open(@file, "a") { |io| puts(io, key, val) }
  end

  abstract def delete(key : String) : Bool

  def delete!(key : String)
    return unless delete(key)
    File.open(@file, "a") { |io| io.puts(key) }
  end

  abstract def to_s(io : IO, val : T) : Void
  abstract def to_s(io : IO) : Void

  def save!(file : String = @file) : Void
    measure = Time.measure { File.write(file, self) }
    measure = measure.total_milliseconds.round.to_i
    puts "- <#{file}> saved (entries: #{size}, time: #{measure}ms)".colorize(:green)
  end

  macro included
    CACHE = {} of String => self

    def self.load(file : String, mode : Int32 = 1) : self
      CACHE[file] ||= new(file, mode)
    end

    def self.flush!
      CACHE.each_value { |item| item.save! }
    end
  end
end
