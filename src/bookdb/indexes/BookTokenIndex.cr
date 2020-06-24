require "json"
require "colorize"
require "file_utils"

class BookTokenIndex
  SEP  = "ǁ"
  ROOT = File.join("data", "indexes", "tokens")

  def self.setup!
    FileUtils.mkdir_p(ROOT)
  end

  @@cache = {} of String => BookTokenIndex

  def self.load!(type : String)
    @@cache[type] ||= new(@type, preload: true)
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

  def load!(reorder : Bool = false)
    if File.exists?(@file)
      lines = File.read_lines(@file)

      lines.each do |line|
        uuid, value = line.split(SEP, 2)
        upsert(uuid, value.try(&.to_f) || 0.0, reorder: false)
      end

      reorder! if reorder
      puts "- [order_index] `#{@file.colorize(:cyan)}` loaded."
    else
      puts "- [order_index] `#{@file.colorize(:red)}` not found!"
    end

    self
  end

  def upsert(uuid : String, value : Float64, reorder : Bool = true)
    if index = @data.index { |first, _| uuid == first }
      return if @data[index][1] >= value
      @data[index] = {uuid, value}
    else
      @data << {uuid, value}
    end

    reorder! if reorder
    @changed = true
  end

  def save!
    File.open(@file, "w") do |f|
      @data.each do |uuid, value|
        f << uuid << SEP << value << "\n"
      end
    end
  end

  def reorder!
    @data.sort_by!(&.[1])
  end

  def changed?
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
