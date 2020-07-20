require "json"
require "colorize"
require "file_utils"

require "../common/file_util"

class OrderMap
  LABEL = "order_map"
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
      io << @key << SEP_0 << @val
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

  # modes: 0 => init, 1 => load if exists, 2 => force load, raise exception if not exists
  def initialize(@file : String, mode : Int32 = 1)
    @first = Node.new("", Int64::MAX)
    @last = Node.new("", Int64::MIN)
    @first.set_right(@last)

    return if mode == 0
    load!(@file) if mode == 2 || File.exists?(file)
  end

  def load!(file : String = @file) : Void
    FileUtil.each_line(file, LABEL) do |line|
      key, val = line.strip.split(SEP_0, 2)

      if val = val.try(&.to_i64?)
        upsert(key, val)
      else
        delete(key)
      end
    rescue err
      FileUtil.log_error(LABEL, line, err)
    end
  end

  def upsert!(key : String, val : Int64, force : Bool = false) : Void
    append!(key, val) if upsert(key, val, force)
  end

  def upsert(key : String, val : Int64, force = false) : Node?
    if node = fetch(key)
      return unless force || node.val < val

      node.val = val
      @first.set_right(node) if val >= @first.right!.val
    else
      node = Node.new(key, val)
      @first.set_right(node)
      @data[key] = node
    end

    node.move_right || node.move_left || node
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
    @data.fetch(key, nil) unless key.empty?
  end

  def value(key : String) : Int64?
    fetch(key).try(&.val)
  end

  def each(node : Node = @first)
    while node = node.right
      yield node unless node == @last
    end
  end

  def reverse_each(node : Node = @last)
    while node = node.left
      yield node unless node == @first
    end
  end

  def append!(key : String, val : Int64) : Void
    FileUtil.append(@file) { |io| to_s(io, key, val) }
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
    FileUtil.save(file, LABEL, @data.size) { |io| to_s(io) }
  end

  # class methods

  DIR = File.join("var", "bookdb")
  FileUtils.mkdir_p(File.join("indexes", "orders"))

  # file path relative to `DIR`
  def self.path_for(name : String)
    File.join(DIR, "#{name}.txt")
  end

  # file name relative to `DIR`
  def self.name_for(file : String)
    File.sub("#{DIR}/", "").sub(".txt", "")
  end

  # check file exists in `DIR`
  def self.exists?(name : String)
    File.exists?(path_for(file))
  end

  # read random file, raising FileNotFound if not existed
  def self.read!(file : String) : OrderMap
    new(file, mode: 2)
  end

  # load file if exists, else raising exception
  def self.load!(name : String) : OrderMap
    new(path_for(name), mode: 2)
  end

  # load file if exists, else return nil
  def self.load(name : String) : OrderMap
    new(path_for(name), mode: 1)
  end

  # create new file from fresh
  def self.init(name : String) : OrderMap
    new(path_for(name), mode: 0)
  end

  CACHE = {} of String => OrderMap

  def self.preload!(name : String) : OrderMap
    CACHE[name] ||= load!(name)
  end

  def self.preload(name : String) : OrderMap
    CACHE[name] ||= load(name)
  end

  def self.flush! : Void
    CACHE.each_value { |map| map.save! }
  end

  class_getter top_authors : OrderMap { preload("_import/top_authors") }
  class_getter book_access : OrderMap { preload("indexes/orders/book_access") }
  class_getter book_update : OrderMap { preload("indexes/orders/book_update") }
  class_getter book_weight : OrderMap { preload("indexes/orders/book_weight") }
  class_getter book_rating : OrderMap { preload("indexes/orders/book_rating") }
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
