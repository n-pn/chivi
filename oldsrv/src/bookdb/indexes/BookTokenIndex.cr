require "json"
require "colorize"
require "file_utils"

class BookTokenIndex
  SEP  = "ǁ"
  ROOT = File.join("data", "books", "indexes", "tokens")

  def self.setup!
    FileUtils.mkdir_p(ROOT)
  end

  @@cache = {} of String => BookTokenIndex

  def self.load!(type : String) : BookTokenIndex
    @@cache[type] ||= new(@type, preload: true)
  end

  struct Index
    SEP = "ǁ"

    getter uuid : String
    getter label : String
    getter weight : Float64

    def self.parse!(line : String)
      uuid, label, weight = line.split(SEP, 3)
      weight = weight.try(&.to_f) || 0.0
      new(uuid, label, weight)
    end

    def initialize(@uuid, @label, @weight)
    end

    def same?(other : Index) : Bool
      return true if @weight >= other.weight
      @label == other.label
    end

    def match?(label : String) : Bool
      return true if label.empty?
      label.includes?(@label)
    end

    def to_s(io : IO)
      io << uuid << SEP << label << SEP << weight
    end
  end

  alias Item = Tuple(String, Float64)
  @data = [] of Item

  include Enumerable(Item)
  delegate each, to: @data

  def initialize(@type : String, preload : Bool = false)
    @file = File.join(ROOT, "#{@type}.txt")
    @changed = false

    load! if preload
  end

  def load!(reorder : Bool = false) : self
    if File.exists?(@file)
      lines = File.read_lines(@file)

      lines.each do |line|
        uuid, value = line.split(SEP, 2)
        upsert(uuid, value.try(&.to_f) || 0.0, reorder: false)
      end

      reorder! if reorder
      puts "- <book_token_index> [#{@type.colorize(:cyan)}] loaded."
    else
      puts "- <book_token_index> [#{@type.colorize(:red)}] not found!"
    end

    self
  end

  def upsert(uuid : String, value : Float64, reorder : Bool = true) : Bool
    if index = @data.index { |first, _| uuid == first }
      return if @data[index][1] >= value
      @data[index] = {uuid, value}
    else
      @data << {uuid, value}
    end

    reorder! if reorder
    @changed = true
  end

  def save! : self
    File.open(@file, "w") do |f|
      @data.each { |i| f.puts i }
    end

    puts "- <book_token_index> [#{@type.colorize(:cyan)}] saved."
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
end
