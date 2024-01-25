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
    return unless dict = CACHE[dname]?
    dict[wstem.zstr] = wterm
  end

  def self.add_term(dname : String, input : PgDefn)
    return unless dict = CACHE[dname]?

    node = dict.root[zstr]

    defn = MtDefn.new(
      vstr: input.vstr,
      attr: input.attr,
      dnum: MtDnum.from(input.d_id, input.plock)
    )
    node.add_data(defn)

    node.defs.try(&.delete(epos))
  end

  def self.delete_term(dname : String, zstr : String, epos : MtEpos)
    return unless dict = CACHE[dname]?
    return unless node = dict.root[zstr]?
    node.defs.try(&.delete(epos))
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

    time = Time.measure { self.load_from_db3!(@d_id) }
    Log.info { "loading #{name} trie: #{time.total_milliseconds}ms, entries: #{@size}" }
  end

  def load_from_db3!(d_id = @d_id)
    SqDefn.query_each(d_id) do |zstr, epos, defn|
      @root[zstr].add_data(epos, defn) { TrieDict.calc_prio(zstr.size) }
      @size &+= 1
    end
  end

  def self.calc_prio(size : Int32, prio : Int16 = 2)
    prio == 0 ? 0_i16 : size.to_i16 &* (prio &+ size.to_i16)
  end

  # def load_from_tsv!(name = @name)
  #   tsv_file = "var/mtdic/wseg/#{name}.tsv"
  #   return unless File.file?(tsv_file)

  #   File.each_line(tsv_file, chomp: true) do |line|
  #     next if line.blank?
  #     wseg = MtWseg.new(line.split('\t'))
  #     @root[wseg.zstr].wseg = wseg
  #   end
  # end

  # @[AlwaysInline]
  # def get_defn?(zstr : String, cpos : String)
  #   @root.get_defn?(zstr: zstr, epos: MtEpos.parse(cpos))
  # end

  # @[AlwaysInline]
  # def get_defn?(zstr : String, epos : MtEpos)
  #   @root[zstr]?.try(&.defs).try(&.[epos]?)
  # end

  @[AlwaysInline]
  def any_defn?(zstr : String)
    @root[zstr]?.try(&.any_defn?)
  end

  def scan_wseg(input : Array(Char), start : Int32 = 0, &)
    node = @root

    start.upto(input.size &- 1) do |index|
      char = input.unsafe_fetch(index)
      # char = CharUtil.to_canon(char, true)
      char = char - 32 if 'ａ' <= char <= 'ｚ'
      break unless node = node.succ.try(&.[char]?)
      yield index &- start &+ 1, node.prio if node.prio >= 0
    end
  end

  ####

  class Trie
    property prio : Int16 = -1_i16
    property succ : Hash(Char, self)? = nil
    property defs : {MtEpos, MtDefn} | Hash(MtEpos, MtDefn) | Nil = nil

    def [](zstr : String)
      zstr.each_char.reduce(self) do |node, char|
        succ = node.succ ||= {} of Char => Trie
        # char = char - 32 if 'ａ' <= char <= 'ｚ'
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

    def add_data(epos : MtEpos, defn : MtDefn) : Nil
      case prev = @defs
      in Nil
        @defs = {epos, defn}
      in Tuple(MtEpos, MtDefn)
        @defs = {
          prev[0] => prev[1],
          epos    => defn,
        }
      in Hash
        prev[epos] = defn
      end

      @prio = yield if @prio < 0
    end

    @[AlwaysInline]
    def get_defn?(cpos : String)
      get_defn?(epos: MtEpos.parse(cpos))
    end

    def get_defn?(epos : MtEpos)
      case defs = @defs
      in Nil then {nil, nil}
      in Tuple
        {epos == defs[0] ? defs[1] : nil, defs[1]}
      in Hash
        {defs[epos]?, defs.first_value}
      end
    end

    def any_defn?
      case defs = @defs
      in Nil then nil
      in Tuple
        defs[1]
      in Hash
        defs.first_value
      end
    end
  end
end
