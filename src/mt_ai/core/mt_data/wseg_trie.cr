require "../../data/sq_wseg"

class MT::WsegTrie
  class_getter regular : self { load!("regular") }
  class_getter nqnt_vi : self { load!("nqnt_vi") }
  class_getter word_hv : self { load!("word_hv") }
  class_getter name_hv : self { load!("name_hv") }

  CACHE = {} of String => self

  def self.load!(name : String) : self
    CACHE[name] ||= new(name)
  end

  @[AlwaysInline]
  def self.add(dname : String, input : SqWseg) : Nil
    return unless dict = CACHE[dname]?
    input.rank < 0 ? dict.del(input) : dict.add(input)
  end

  @[AlwaysInline]
  def self.del(dname : String, input : SqWseg) : Nil
    CACHE[dname]?.try(&.del(input))
  end

  getter name : String
  getter d_id : Int32
  getter root = Node.new

  def initialize(@name, reset : Bool = false)
    @d_id = MtDtyp.map_id(name)
    time = Time.measure { self.load_from_db3!(@d_id) }
    Log.info { "loading [#{name}]: #{time.total_milliseconds}ms, total: #{@size}" }
  end

  def load_from_db3!(d_id = @d_id)
    SqWseg.query_each(d_id) { |zstr, rank| self.add(zstr, rank) }
  end

  @[AlwaysInline]
  def add(wseg : SqWseg)
    self.add(wseg.zstr, WsegData.new(wseg))
  end

  @[AlwaysInline]
  def add(zstr : String, rank : String)
    @root[zstr].prio = SpWseg.calc_prio(zstr.size, rank)
  end

  @[AlwaysInline]
  def del(wseg : SqWseg)
    self.del(wseg.zstr)
  end

  @[AlwaysInline]
  def del(zstr : String)
    @root[zstr]?.try(&.prio = -1)
  end

  ####

  def prefix_match(input : Array(Char), start : Int32 = 0, &)
    node = @root

    start.upto(input.size &- 1) do |index|
      char = input.unsafe_fetch(index)
      char = char - 32 if 'ａ' <= char <= 'ｚ' || 'a' <= char <= 'z'

      break unless node = node.succ.try(&.[char]?)
      next if node.prio < 0

      yield index &- start &+ 1, node.prio
    end
  end

  ####

  class Node
    property prio : Int32 = -1
    # property seps : Int32 = 0
    property trie : Hash(Char, self)? = nil

    def [](zstr : String)
      zstr.each_char.reduce(self) do |node, char|
        trie = node.trie ||= {} of Char => Node
        char = char - 32 if 'ａ' <= char <= 'ｚ' || 'a' <= char <= 'z'
        trie[char] ||= Node.new
      end
    end

    def []?(zstr : String)
      node = self

      zstr.each_char do |char|
        return unless trie = node.trie
        char = char - 32 if 'ａ' <= char <= 'ｚ' || 'a' <= char <= 'z'
        return unless node = trie[char]?
      end

      node
    end
  end
end
