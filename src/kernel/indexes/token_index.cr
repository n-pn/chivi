require "json"
require "colorize"
require "file_utils"

class TokenIndex
  SEP = "ǁ"

  alias Data = Hash(String, Set(String))
  @data = Data.new { |h, k| h[k] = Set(String).new }

  def initialize(@file : String, preload : Bool = false)
    load! if preload
  end

  def load!(file : String = @file) : self
    if File.exists?(file)
      lines = File.read_lines(file)
      lines.each { |line| set!(line) }

      puts "- <token_index> [#{@type.colorize(:cyan)}] loaded."
    else
      puts "- <token_index> [#{@type.colorize(:red)}] not found!"
    end

    self
  end

  def set!(line : String) : Void
    cols = line.split(SEP, 2)

    key = cols[0]
    if val = cols[1]?
      set!(key, val)
    else
      del!(key)
    end
  rescue err
    puts "- <token_index> error parsing line `#{line.colorize(:red)}`: #{err.message.colorize(:red)}"
  end

  def set!(key : String, val : String)
    @data[key].add(val)
  end

  def del!(key, )

  def save! : self
    File.open(@file, "w") do |f|
      @data.each { |i| f.puts i }
    end

    puts "- <token_index> [#{@type.colorize(:cyan)}] saved."
    self
  end

  def reorder! : Void
    @data.sort_by!(&.weight)
  end

  def changed? : Bool
    @changed
  end

  def fetch(size : Int32 = 20, skip : Int32 = 0)
    @data.reverse_each do |uuid, _|
      if skip > 0
        skip -= 1
      else
        size -= 1
        break unless limit > 0
        yield uuid
      end
    end
  end

  # class methods
  ROOT = File.join("var", "appcv", "_indexes")

  def self.setup!
    FileUtils.mkdir_p(ROOT)
  end

  def self.path(type : String)
    File.join(ROOT, type)
  end

  @@cache = {} of String => TokenIndex

  def self.load!(type : String) : TokenIndex
    @@cache[type] ||= new(path(file), preload: true)
  end
end
