require "colorize"
require "file_utils"
require "../../_utils/time_utils"

class Chivi::VpDict
  class Item
    getter key : String         # primary key
    getter vals : Array(String) # main values
    getter alts : Array(String) # for extra data, like attributes

    getter mtime : Int32  # modification time by total minutes from epoch
    getter uname : String # username
    getter plock : Int32  # permission lock

    getter extra : String # extra infomations

    def initialize(@key, @vals, @alts = [""],
                   @mtime = Utils.TimeUtil.mtime,
                   @uname = "", @plock = 0, @extra = "")
    end

    def empty?
      @vals.empty?
    end

    def blank?
      @vals.empty? && @alts.empty?
    end

    def short?
      @mtime == 0
    end

    def to_s(trunc = false) : String
      String.build { |io| to_s(io, trunc: trunc) }
    end

    def to_s(io : IO, trunc = false) : Nil
      if trunc || short?
        {@key, @val, @alt}.join(io, '\t')
      else
        {@key, @val, @alt, @mtime, @uname, @plock, @extra}.join(io, '\t')
      end
    end

    def puts(io : IO, trunc = false) : Nil
      to_s(io, trunc: trunc)
      io << '\n'
    end

    def inspect(io : IO, trunc = false) : Nil
      io << '⟨'
      io << @key

      io << '|'
      @vals.join(io, '¦')

      io << '|'
      @alts.join(io, '¦')

      unless trunc || short?
        io << 'ǁ'
        {@mtime, @uname, @plock, @mtime}.join(io, '|')
      end

      io << '⟩'
    end

    def merge(other : self) : self
      if other.plock > plock || (other.plock == plock && other.mtime >= @mtime)
        @vals = (other.vals + @vals).uniq!
        @alts = (other.alts + @alts).uniq!

        @mtime = other.mtime
        @uname = other.uname
        @plock = other.plock
      else
        @vals.concat(other.vals).uniq!
        @alts.concat(other.alts).uniq!
      end

      self
    end

    def self.from(other : self, dlock = other.plock)
      new(other.key, [""], [""], mtime: 0, plock: dlock).merge(other)
    end

    def self.from(line : String, trunc = false, dlock = 1)
      # trunc: truncated version (skipping mtime, dname, plock even if existed)
      # short: without user activty

      cls = line.split('\t', 7)
      key = cols[0]

      vals = cols[1]?.try(&.split("|")) || [""]
      alts = cols[2]?.try(&.split("|")) || [""]

      if trunc || !(mtime = cls[3]?.try(&.to_i?))
        return new(key, vals, alts, mtime: 0, plock: dlock)
      end

      uname = cls[4]? || ""
      plock = cls[5]? || 1
      extra = cls[6]? || ""

      new(key, vals, alts, mtime, uname, plock, extra)
    end
  end

  class Node
    alias List = Array(Item)
    alias Trie = Hash(String, Node)

    getter item : Item? = nil
    getter trie = Trie.new

    def find_node!(key : String) : Node
      node = self
      key.each_char { |c| node = node.trie[c] ||= Node.new }
      node
    end

    def find_node(key : String) : Node?
      node = self
      key.each_char { |c| break unless node = node.trie[c]? }
      node
    end

    def fetch_item(key : String) : Item?
      find_node.try(&.item)
    end

    def each_item : Nil
      queue = [self]

      while node = queue.pop?
        node.trie.each_value do |node|
          queue << node
          next unless item = node.item
          yield item
        end
      end
    end

    def list_item(limit = 50, offset = 0) : List
      ary = List.new

      each_item do |item|
        next unless yield item

        if offset > 0
          offset -= 1
        else
          ary << item
          break if ary.size == limit
        end
      end

      ary
    end

    def scan_list(chars : Array(Char), index = 0) : Nil
      node = self

      index.upto(chars.size - 1) do |i|
        c = chars.unsafe_fetch(i)
        break unless node = node.trie[c]
        if item = node.item
          yield item
        end
      end
    end
  end

  class_property cwd = File.join("var", "chivi")
  class_property fix = "chivi"

  # renew: create new files

  def self.init(dic : String, fix = @@fix, cwd = @@cwd, dlock = 1, renew = false)
    dic_file = File.join(cwd, "#{dic}.tsv")
    fix_file = File.join(cwd, "#{dic}.#{fix}.tab")

    this = new(dic_file, fix_file, dlock: dlock)
    return this unless renew

    this
      .load!(dic_file, trunc: true, dlock: dlock)
      .load!(fix_file, trunc: false, dlock: 0)
  end

  getter dic_file : String
  getter fix_file : String

  getter dlock = 1 # default permission lock
  getter mtime = 0 # last modification time

  getter rnode = Node.new # root trie node
  getter items = Node::List.new

  def initialize(@dic_file, @fix_file, @dlock = 1)
  end

  def load!(file : String, trunc = false, dlock = @dlock) : self
    load(file) do |line|
      upsert(Item.from(line, trunc: trunc, dlock: dlock))
    rescue err
      puts "- <#{vp_dict}> error parsing `#{line}` : #{err}".colorize.red
    end

    self
  end

  def load(file : String) : Nil
    return unless File.exists?(file)
    count = 0

    time = Time.measure do
      File.each_line(file) do |line|
        line = line.strip
        next if line.blank?

        yield line
        count += 1
      end
    end

    time = time.total_milliseconds.round.to_i
    puts "- <#{vp_dict}> [#{file}] loaded (lines: #{count}, time: #{time}ms)".colorize(:blue)
  end

  def upsert!(item : Item, trunc = false)
    File.open(@fix_file, "a") { |io| item.puts(io, trunc: trunc) }
    upsert(item)
  end

  def upsert(new_item : Item) : Item
    node = @rnode.find_node!(new_item.key)

    # TODO: skip duplicates
    @fixes << new_item unless new_item.short?

    unless item = node.item
      item = Item.from(new_item, dlock: dlock)
      @items << item
      node.item = item
    end

    item.merge(new_item)
  end

  delegate each_item, to: @rnode
  delegate scan_item, to: @rnode
  delegate find_item, to: @rnode

  def save!(items = true, fixes = true)
    # TODO!
  end
end
