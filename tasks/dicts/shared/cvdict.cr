require "colorize"

class Cvdict
  SEP_0 = "ǁ"
  SEP_1 = "¦"

  alias Data = Hash(String, Array(String))

  getter file : String
  getter data = Data.new

  def initialize(@file : String)
  end

  def self.sep_0(file = @file)
    File.extname(file) == ".txt" ? "=" : "ǁ"
  end

  def self.sep_1(file = @file)
    File.extname(file) == ".txt" ? "/" : "¦"
  end

  def self.load!(file : String)
    return new(file).load! if File.exists?(file)
    raise "File [#{file.colorize(:red)}] not found!"
  end

  def load!(file : String = @file)
    print "- loading [#{file.colorize(:blue)}]... "
    count = 0

    sep_0 = Cvdict.sep_0(file)
    sep_1 = Cvdict.sep_1(file)

    File.read_lines(file).each do |line|
      next if line.empty? || line[0] == '#'

      rows = line.split(sep_0, 2)
      next if rows.size != 2

      key, val = rows

      if val.empty?
        del(key)
      else
        set(key, val.split(sep_1).uniq)
      end

      count += 1
    end

    puts "done, entries: #{count.to_s.colorize(:blue)}"
    self
  end

  def merge!(that : String, mode : Symbol = :old_first)
    merge!(Cvdict.load!(that), mode)
  end

  def merge!(that : Cvdict, mode : Symbol = :old_first)
    print "- merging [#{@file.colorize(:yellow)}] with [#{that.file.colorize(:yellow)}], mode: [:#{mode.to_s.colorize(:yellow)}]... "

    count = 0
    @data.merge!(that.data) do |k, v1, v2|
      count += 1
      resolve(v1, v2, mode)
    end

    puts "done, conflict: #{count.to_s.colorize(:yellow)}"
    self
  end

  def keys
    @data.keys
  end

  def vals
    @data.values
  end

  def size
    @data.size
  end

  def get(key : String)
    @data[key]?
  end

  def get_first(key : String)
    if vals = @data[key]?
      return vals[0]
    end
  end

  def includes?(key : String)
    @data.has_key?(key)
  end

  def add(key : String, val : String)
    if vals = @data[key]?
      vals << val
      vals.uniq!
    else
      @data[key] = [val]
    end
  end

  def del(key : String)
    @data.delete key
  end

  def set(key : String, val : String, mode = :old_first)
    set(key, val.split(/[\/|¦]/).uniq, mode)
  end

  def set(key : String, val : Array(String), mode = :old_first)
    @data[key] = resolve(get(key), val, mode)
  end

  def resolve(old_val : Array(String)?, new_val : Array(String), mode = :old_first)
    return new_val if old_val.nil?

    case mode
    when :keep_old  then old_val
    when :keep_new  then new_val
    when :new_first then new_val.concat(old_val).uniq
    when :old_first then old_val.concat(new_val).uniq
    else
      raise "Unknown mode #{:mode}"
    end
  end

  def fetch(key : String)
    if val = get(key)
      val.first
    else
      key
    end
  end

  def translate(input : String, joiner = "")
    input.split("").map { |c| fetch(c) }.join(joiner)
  end

  def save!(file = @file, keep = 99, sort = false)
    print "- saving [#{file.colorize(:green)}]... "

    sep_0 = Cvdict.sep_0(file)
    sep_1 = Cvdict.sep_1(file)

    data = sort ? @data.to_a.sort_by { |k, v| {k.size, k} } : @data.to_a

    File.open(file, "w") do |f|
      data.each do |key, val|
        f << key << sep_0 << val.first(keep).join(sep_1) << "\n"
      end
    end

    puts "done, entries: #{@data.size.to_s.colorize(:green)}"
    self
  end
end
