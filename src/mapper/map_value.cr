require "json"
require "colorize"
require "file_utils"

class MapValue::Node
  getter key : String
  property val : Int64

  property prev : Node?
  property succ : Node?

  def initialize(@key, @val)
  end

  def set_prev!(node : self)
    node.succ = self
    node.prev = @prev

    @prev.try(&.succ = node)
    @prev = node
  end

  def set_succ!(node : self)
    node.prev = self
    node.succ = @succ

    @succ.try(&.prev = node)
    @succ = node
  end

  def unlink!
    @prev.try(&.succ = @succ)
    @succ.try(&.prev = @prev)
  end

  def to_s(io : IO)
    io << "[" << @key << " : " << @val << "]"
  end

  def to_s
    String.build { |io| to_s(io) }
  end
end

struct MapValue::Data
  getter data = {} of String => Node
  forward_missing_to @data

  def initialize
    @head = Node.new("", Int64::MAX)
    @tail = Node.new("", Int64::MIN)
    @head.set_succ!(@tail)
  end

  def upsert!(key : String, val : Int64) : Void
    if node = find(key)
      return if node.val == val
      node.val = val

      if @head.succ.try(&.val.< val)
        unless node.prev == @head
          node.unlink!
          @head.set_succ!(node)
        end

        return
      end

      if @tail.prev.try(&.val.> val)
        unless node.succ == @tail
          node.unlink!
          @tail.set_prev!(node)
        end

        return
      end
    else
      node = Node.new(key, val)
      @data[key] = node

      if @head.succ.try(&.val.< val)
        @head.set_succ!(node)
        return
      end

      if @tail.prev.try(&.val.> val)
        @tail.set_prev!(node)
        return
      end

      @head.set_prev!(node)
    end

    # sorting

    # move left
    prev = node.prev

    while prev && prev.val < val
      prev = prev.prev
    end

    if prev && prev != node.prev
      node.unlink!
      prev.set_succ!(node)
    end

    # move right
    succ = node.succ

    while succ && succ.val > val
      succ = succ.succ
    end

    if succ && succ != node.succ
      node.unlink!
      succ.set_prev!(node)
    end
  end

  def delete!(key : String)
    @data[key]?.try(&.unlink!)
  end

  def find(key : String) : Node?
    @data[key]?
  end

  def get_val(key : String) : Int64?
    @data[key]?.try(&.val)
  end

  def first
    @head.succ
  end

  def last
    @tail.prev
  end

  def each(node = first)
    while node && node != @tail
      yield node
      node = node.succ
    end
  end

  def reverse_each(node = last)
    while node && node != @head
      yield node
      node = node.prev
    end
  end

  def to_s(io : IO)
    io << "{ "
    each { |node| io << node << " " }
    io << "}"
  end

  def to_s
    String.build { |io| to_s(io) }
  end
end

struct MapValue::Bulk
  SEP = "ǁ"

  getter file : String
  getter data = Data.new
  forward_missing_to @data

  def initialize(@file, preload : Bool = true)
    load!(@file) if preload && exist?
  end

  def exist?
    File.exists?(@file)
  end

  def load!(file : String = @file) : Void
    File.each_line(file) do |line|
      key, val = line.split(SEP, 2)
      if val = val.try(&.to_i64?)
        @data.upsert!(key, val)
      else
        @data.delete!(key)
      end
    rescue err
      puts "- <map_value> error parsing line `#{line}`: #{err.colorize(:red)}"
    end

    puts "- <map_value> [#{file.colorize(:cyan)}] loaded."
  end

  def save!(file : String = @file) : Void
    File.write(file, self)
    puts "- <map_value> [#{file.colorize(:cyan)}] saved (entries: #{size})."
  end

  def upsert!(key : String, val : Int64) : Void
    File.open(@file, "a") { |io| io << key << SEP << val << "\n" }
    @data.upsert!(key, val)
  end

  def delete!(key : String) : Void
    File.open(@file, "a") { |io| io << key << SEP << "\n" }
    @data.delete!(key)
  end

  def to_s(io : IO)
    @data.reverse_each { |node| io << node.key << SEP << node.val << "\n" }
  end

  def to_s
    String.build { |io| to_s(io) }
  end
end

module MapValue
  extend self

  DIR = File.join("var", "appcv", "map_values")
  FileUtils.mkdir_p(DIR)

  def path_for(type : String)
    File.join(DIR, "#{type}.txt")
  end

  CACHE = {} of String => Bulk

  def load!(type : String)
    CACHE[type] ||= init!(type)
  end

  def init!(type : String, file = path_for(type))
    Bulk.new(file, preload: true)
  end
end

# test = MapValue.load!("test")

# test.upsert!("a", 10)
# test.upsert!("b", 20)
# test.upsert!("c", 11)
# test.upsert!("d", 12)
# test.upsert!("e", 2)

# # puts test.value("b")
# puts test

# test.upsert!("b", 2)
# # puts test.value("b")
# puts test

# test.upsert!("b", 30)
# # puts test.value("b")
# puts test

# test.upsert!("a", 30)
# puts test

# test.save!
