require "./_shared"

class Oldcv::OrderMap
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

  include OldFlatFile(Int64)

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
    read_file(file) do |key, val|
      if val = val.try(&.to_i64?)
        upsert(key, val)
      else
        delete(key)
      end
    end
  end

  def upsert(key : String, val : Int64, force = false) : Node?
    if node = fetch(key)
      return unless force || node.val != val

      node.val = val
      @first.set_right(node) if val >= @first.right!.val
    else
      node = Node.new(key, val)
      @first.set_right(node)
      @data[key] = node
    end

    node.move_right || node.move_left || node
  end

  def delete(key : String) : Bool
    return false unless node = @data.delete(key)
    !!node.unlink_self
  end

  def fetch(key : String) : Node?
    @data[key]?
  end

  def value(key : String) : Int64?
    @data[key]?.try(&.val)
  end

  def each(node : Node = @first)
    while node = node.right
      return if node == @last
      yield node
    end
  end

  def reverse_each(node : Node = @last)
    while node = node.left
      return if node == @first
      yield node
    end
  end

  def to_s(io : IO, val : Int64) : Void
    io << val
  end

  def to_s(io : IO) : Void
    each do |node|
      puts(io, node.key, node.val)
    end
  end

  # class Oldcv::methods

  DIR = "_db/_oldcv"
  FileUtils.mkdir_p(File.join(DIR, "indexes", "orders"))

  # file path relative to `DIR`
  def self.path_for(name : String)
    File.join(DIR, "#{name}.txt")
  end

  def self.load_name(name : String, mode = 1)
    load(path_for(name), mode: mode)
  end

  class_getter author_rating : OrderMap { load_name("_import/author_rating") }
  class_getter author_voters : OrderMap { load_name("_import/author_voters") }
  class_getter author_weight : OrderMap { load_name("_import/author_weight") }

  class_getter book_access : OrderMap { load_name("indexes/orders/book_access") }
  class_getter book_update : OrderMap { load_name("indexes/orders/book_update") }
  class_getter book_weight : OrderMap { load_name("indexes/orders/book_weight") }
  class_getter book_rating : OrderMap { load_name("indexes/orders/book_rating") }
  class_getter book_voters : OrderMap { load_name("indexes/orders/book_voters") }
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
