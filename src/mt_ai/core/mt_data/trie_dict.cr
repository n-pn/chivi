require "../../data/sq_defn"
require "./mt_wseg"
require "./mt_defn"

class MT::TrieDict
  class_getter essence : self { load!("essence") }
  class_getter regular : self { load!("regular") }
  class_getter suggest : self { load!("suggest") }

  class_getter nqnt_vi : self { load!("nqnt_vi") }
  class_getter word_hv : self { load!("word_hv") }
  class_getter name_hv : self { load!("name_hv") }

  CACHE = {} of String => self

  def self.load!(name : String) : self
    CACHE[name] ||= new(name)
  end

  def self.add_term(dname : String, wterm : MtWseg)
    CACHE[dname]?.try(&.[wstem.zstr] = wterm)
  end

  def self.delete_term(dname : String, zstr : String)
    CACHE[dname]?.try(&.[zstr] = nil)
  end

  getter root = Trie.new
  getter size = 0
  getter d_id : Int32

  def initialize(@name : String, reset : Bool = false)
    @d_id = MtDtyp.map_id(name)
    return if reset

    time = Time.measure do
      self.load_from_db3!(@d_id)
      self.load_from_tsv!(@name)
    end

    Log.info { "loading #{name} trie: #{time.total_milliseconds}ms, entries: #{@size}" }
  end

  def load_from_db3!(d_id = @d_id)
    SqDefn.query_each(d_id) do |zstr, epos, defn|
      @root[zstr].add_data(epos, defn) { MtWseg.new(zstr) }
      @size &+= 1
    end
  end

  def load_from_tsv!(name = @name)
    tsv_file = "var/mtdic/wseg/#{name}.tsv"
    return unless File.file?(tsv_file)

    File.each_line(tsv_file, chomp: true) do |line|
      next if line.blank?
      wseg = MtWseg.new(line.split('\t'))
      @root[wseg.zstr].wseg = wseg
    end
  end

  @[AlwaysInline]
  def get_defn?(zstr : String, cpos : String)
    @root.get_defn?(zstr: zstr, epos: MtEpos.parse(cpos))
  end

  @[AlwaysInline]
  def get_defn?(zstr : String, epos : MtEpos)
    @root[zstr]?.try(&.vals).try(&.[epos]?)
  end

  def any_defn?(zstr : String)
    @root[zstr]?.try(&.defn)
  end

  def scan_wseg(input : Array(Char), start : Int32 = 0, &)
    node = @root
    size = 0

    start.upto(input.size &- 1) do |idx|
      char = input.unsafe_fetch(idx)
      # char = CharUtil.to_canon(char, true)
      break unless node = node.succ.try(&.[char]?)
      next unless wseg = node.wseg
      yield idx &- start &+ 1, wseg
    end
  end

  ####

  class Trie
    property succ : Hash(Char, self)? = nil
    property vals : Hash(MtEpos, MtDefn)? = nil
    property defn : MtDefn? = nil
    property wseg : MtWseg? = nil

    def [](zstr : String)
      zstr.each_char.reduce(self) do |node, char|
        # char = CharUtil.to_canon(char, true)
        succ = node.succ ||= {} of Char => Trie
        succ[char] ||= Trie.new
      end
    end

    def []?(zstr : String)
      node = self

      zstr.each_char do |char|
        return unless succ = node.succ
        return unless node = succ[char]?
      end

      node
    end

    def add_data(epos : MtEpos, defn : MtDefn, & : MtWseg? ->) : Nil
      vals = @vals ||= {} of MtEpos => MtDefn
      vals[epos] = defn
      @defn = defn if epos.x? || !defn

      @wseg = yield @wseg
    end

    @[AlwaysInline]
    def get_defn?(zstr : String, cpos : String)
      get_defn?(zstr: zstr, epos: MtEpos.parse(cpos))
    end

    @[AlwaysInline]
    def get_defn?(zstr : String, epos : MtEpos)
      self[zstr]?.try(&.vals).try(&.[epos]?)
    end

    def any_defn?(zstr : String)
      self[zstr]?.try(&.defn)
    end

    def scan_wseg(input : Array(Char), start : Int32 = 0, &)
      node = self
      size = 0

      start.upto(input.size &- 1) do |idx|
        char = input.unsafe_fetch(idx)
        # char = CharUtil.to_canon(char, true)
        break unless node = node.succ.try(&.[char]?)
        next unless wseg = node.wseg
        yield idx &- start &+ 1, wseg
      end
    end
  end
end
