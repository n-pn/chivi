require "json"
require "colorize"
require "file_utils"

class OrderMap
  SEP_0 = "ǁ"

  class Node
    getter key : String
    property val : Int64

    property left : Node?
    property right : Node?

    def initialize(@key, @val)
    end

    def left!
      @left.not_nil!
    end

    def right!
      @right.not_nil!
    end

    # return self if effective, else return nil
    def set_left(node : self) : Node?
      return if node == @left
      node.unlink_self

      node.right = self
      node.left = @left

      @left.try(&.right = node)
      @left = node
    end

    # return self if effective, else return nil
    def set_right(node : self) : Node?
      return if node == @right
      node.unlink_self

      node.left = self
      node.right = @right

      @right.try(&.left = node)
      @right = node
    end

    # return self if effective, else return nil
    def move_left : Node?
      node = self

      while node = node.left
        break if @val < node.val
      end

      node.set_right(self) if node
    end

    # return self if effective, else return nil
    def move_right : Node?
      node = self

      while node = node.right
        break if @val >= node.val
      end

      node.set_left(self) if node
    end

    def unlink_self : Node
      @left.try(&.right = @right)
      @right.try(&.left = @left)

      self
    end

    def to_s(io : IO)
      io << "[" << @key << " : " << @val << "]"
    end

    def to_s
      String.build { |io| to_s(io) }
    end
  end

  getter file : String
  getter data = {} of String => Node
  delegate size, to: @data
  delegate has_key?, to: @data

  getter first : Node
  getter last : Node

  def initialize(@file, preload : Bool = true)
    @first = Node.new("", Int64::MAX)
    @last = Node.new("", Int64::MIN)
    @first.set_right(@last)

    load!(@file) if preload && exist?
  end

  def exist?
    File.exists?(@file)
  end

  def load!(file : String = @file) : Void
    File.each_line(file) do |line|
      key, val = line.split(SEP_0, 2)
      if val = val.try(&.to_i64?)
        upsert(key, val)
      else
        delete(key)
      end
    rescue err
      puts "- <map_value> error parsing line `#{line}`: #{err.colorize(:red)}"
    end

    puts "- <map_value> [#{file.colorize(:cyan)}] loaded."
  end

  def upsert!(key : String, val : Int64, force : Bool = false) : Void
    append!(key, val) if upsert(key, val, force)
  end

  def upsert(key : String, val : Int64, force = false) : Node?
    if node = fetch(key)
      return if !force && node.val >= val

      node.val = val
      @first.set_right(node) if val >= @first.right!.val
    else
      node = Node.new(key, val)
      @first.set_right(node)
      @data[key] = node
    end

    pivot_sort(node)
  end

  private def pivot_sort(node : Node) : Node
    node.move_right || node.move_left
    # puts "#{node}, left: #{node.left}, right: #{node.right}"
    node
  end

  def delete!(key : String) : Void
    append!(key, "") if delete(key)
  end

  def delete(key : String) : Node?
    if node = @data.delete(key)
      node.unlink_self
    end
  end

  def fetch(key : String) : Node?
    @data.fetch(key, nil)
  end

  def each(node = @first)
    while node = node.right
      yield node unless node == @last
    end
  end

  def reverse_each(node = @last)
    while node = node.left
      yield node unless node == @first
    end
  end

  def append!(key : String, val : Int64) : Void
    File.open(@file, "a") { |io| to_s(io, key, val) }
  end

  def to_s
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO)
    reverse_each { |node| to_s(io, node.key, node.val) }
  end

  private def to_s(io : IO, key : String, val : Int64)
    io << key << SEP_0 << val << "\n"
  end

  def save!(file : String = @file) : Void
    File.write(file, self)
    puts "- <order_map> [#{file.colorize(:cyan)}] saved, entries: #{size}."
  end

  # class methods

  DIR = File.join("var", "appcv", "order_maps")
  FileUtils.mkdir_p(DIR)

  def path_for(name : String)
    File.join(DIR, "#{type}.txt")
  end

  def load(name : String, preload : Bool = true) : OrderMap
    new(path_for(name), preload: preload)
  end

  CACHE = {} of String => OrderMap

  def load_cached(name : String, preload : Bool = true) : OrderMap
    CACHE[name] ||= load(name, preload)
  end
end

# test = OrderMap.new("tmp/order_map.txt", false)

# test.upsert!("a", 10_i64)
# test.upsert!("b", 20_i64)
# test.upsert!("c", 11_i64)
# test.upsert!("e", 2_i64)
# test.upsert!("d", 12_i64)

# # puts test.value("b")
# puts test

# test.upsert!("b", 2_i64, true)
# # puts test.value("b")
# puts test

# test.upsert!("b", 30_i64)
# # puts test.value("b")
# puts test

# test.upsert!("a", 30_i64)
# puts test

# test.save!
