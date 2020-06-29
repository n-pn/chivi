require "json"
require "colorize"
require "file_utils"

class ValueIndex
  SEP = "ǁ"
  LBL = "value_index".colorize(:blue)

  class Item
    getter key : String
    getter val : Float64
    property prev : Item? = nil
    property succ : Item? = nil

    def initialize(@key, @val)
    end

    def eql?(key : String)
      @key == key
    end

    def to_s(io : IO)
      io << key << SEP << val
    end
  end

  def initialize(@file : String, preload : Bool = false)
    @head = Item.new("", 0_f64)
    @data = {} of String => Float64

    load!(@file) if preload
  end

  def load!(file : String = @file)
    if File.exists?(file)
      lines = File.read_lines(file)
      lines.each { |line| set!(line) }

      puts "- <#{LBL}> [#{file.colorize(:cyan)}] loaded."
    else
      puts "- <#{LBL}> [#{file.colorize(:red)}] not found!"
    end

    self
  end

  # atomic update
  def add!(key : String, val : Float64) : Void
    add!(Item.new(key, val))
  end

  # :ditto:
  def add!(item : Item) : Void
    File.open(@file, "a") { |io| io.puts(item) }
    set!(item)
  end

  # delete entry by key
  def del!(key : String)
    File.open(@file, "a") { |io| io.puts(key) }
    rem!(key, @head)
  end

  # :nodoc:
  def set!(line : String) : Void
    cols = line.split(SEP, 2)
    key = cols[0]

    if val = cols[1]?.try(&.to_f?)
      set!(Item.new(key, val))
    else
      rem!(key, @head)
    end
  rescue err
    puts "- <#{LBL}> error parsing line `#{line.colorize(:red)}`: #{err.message.colorize(:red)}"
  end

  # :nodoc:
  def set!(key : String, val : Float64)
    set!(Item.new(key, val))
  end

  # :nodoc:
  def set!(item : Item, node : Item = @head) : Void
    return if item.val < 0

    while node.val > item.val
      return if node.key == item.key
      return unless node = node.succ
    end

    if prev = node.prev
      item.prev = prev
      prev.succ = item
    else
      @head = item
    end

    item.succ = node
    node.prev = item

    rem!(item.key, node) # remove duplicate
  end

  # :nodoc:
  def rem!(key : String, node : Item? = @head)
    return unless node
    return unless node = index(key, node)

    if prev = node.prev
      prev.succ = node.succ
    end

    if succ = node.succ
      succ.prev = node.prev
    end
  end

  def index(key : String, node : Item? = @head)
    return unless node

    while node.key != key
      return unless node = node.succ
    end

    node
  end

  def value(key : String) : Float64?
    index(key).try(&.val)
  end

  def save! : self
    File.open(@file, "w") do |io|
      each { |item| io.puts(item) }
    end

    puts "- <#{LBL}> [#{@file.colorize(:cyan)}] saved."
    self
  end

  def each(node = @head)
    while node
      yield node unless node.key.empty?
      node = node.succ
    end
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

  def to_a
    res = [] of Tuple(String, Float64)
    each { |x| res << {x.key, x.val} }
    res
  end
end

# ValueIndex.setup!

test = ValueIndex.new("test.txt", preload: true)
pp test.to_a

test.add!("a", 1.0)
test.add!("b", 2.0)
test.add!("c", 1.1)
test.add!("d", 1.2)
test.add!("e", 0.2)

# pp test.value("b")
pp test.to_a

test.add!("b", 0.2)
# pp test.value("b")
pp test.to_a

test.add!("b", 3.0)
# pp test.value("b")
pp test.to_a

test.add!("a", 3.0)
pp test.to_a

test.save!
