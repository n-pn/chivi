require "json"
require "colorize"
require "file_utils"

class ValueIndex
  SEP = "ǁ"
  LBL = "value_index".colorize(:blue)

  struct Item
    getter key : String
    getter val : Float64

    def initialize(@key, @val)
    end

    def eql?(key : String)
      @key == key
    end

    def to_s(io : IO)
      io << key << SEP << val
    end
  end

  getter data = [] of Item
  delegate each, to: @data
  delegate reverse_each, to: @data

  def initialize(@file : String, preload : Bool = false, reorder : Bool = false)
    load!(@file, reorder) if preload
  end

  # :nodoc:
  def load!(file : String = @file, reorder : Bool = true)
    if File.exists?(file)
      lines = File.read_lines(file)
      lines.each do |line|
        cols = line.split(SEP, 2)

        key = cols[0]
        val = cols[1]?.try(&.to_f?) || -1_f64

        set!(key, val, reorder: false)
        # rescue err
        #   puts "- <value_index> error parsing line `#{line.colorize(:red)}`: #{err.message.colorize(:red)}"
      end

      puts "- <value_index> [#{file.colorize(:cyan)}] loaded."
    else
      puts "- <value_index> [#{file.colorize(:red)}] not found!"
    end

    sort! if reorder
    self
  end

  # atomic update
  def add!(key : String, val : Float64, reorder : Bool = true) : Void
    File.open(@file, "a") { |io| io << key << SEP << val << "\n" }
    set!(key, val, reorder: reorder)
  end

  # delete entry by key
  def del!(key : String)
    File.open(@file, "a") { |io| io << key << "\n" }
    set!(key, -1_f64, reorder: false)
  end

  # :nodoc:
  def set!(key : String, val : Float64 = -1_f64, reorder : Bool = true) : Void
    if val < 0
      @data.reject!(&.eql?(key))
      return
    end

    if idx = index(key)
      @data[idx] = Item.new(key, val)
    else
      @data << Item.new(key, val)
    end

    sort! if reorder
  end

  # :nodoc:
  def sort! : self
    @data.sort_by!(&.val)
    self
  end

  # :nodoc:
  def index(key : String)
    @data.index(&.eql?(key))
  end

  # :nodoc:
  def to_s(io : IO)
    each { |x| io << x.key << SEP << x.val << "\n" }
  end

  # :nodoc:
  def save!(file : String = @file) : self
    File.write(file, self)

    puts "- <#{LBL}> [#{@file.colorize(:cyan)}] saved."
    self
  end

  # class methods

  ROOT = File.join("var", "appcv", "_indexes")

  def self.setup!
    FileUtils.mkdir_p(ROOT)
  end

  def self.reset!
    FileUtils.rm_rf(ROOT)
    setup!
  end

  def self.path(name : String)
    File.join(ROOT, type, "#{name}.txt")
  end

  @@cache = {} of String => ValueIndex

  def self.load!(name : String)
    @@cache[name] ||= new(path(name), preload: true, reorder: true)
  end
end

# ValueIndex.setup!

# test = ValueIndex.new("test.txt", preload: true, reorder: true)
# puts test

# test.add!("a", 1.0)
# test.add!("b", 2.0)
# test.add!("c", 1.1)
# test.add!("d", 1.2)
# test.add!("e", 0.2)

# # puts test.value("b")
# puts test

# test.add!("b", 0.2)
# # puts test.value("b")
# puts test

# test.add!("b", 3.0)
# # puts test.value("b")
# puts test

# test.add!("a", 3.0)
# puts test

# test.save!
