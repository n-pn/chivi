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
    return unless node = CACHE[dname]?.try(&[zstr])
    defn = MtDefn.new(vstr: input.vstr, attr: input.attr, dnum: MtDnum.from(input.d_id, input.plock))
    node.add_data(defn) { TrieDict.calc_prio(input.zstr.size) }
  end

  def self.delete_term(dname : String, zstr : String, epos : MtEpos) : Nil
    return unless dict = CACHE[dname]?
    dict[zstr]?.try(&.delete(epos))
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
    Log.info { "loading [#{name}]: #{time.total_milliseconds}ms, total: #{@size}" }
  end

  def load_from_db3!(d_id = @d_id)
    SqDefn.query_each(d_id) do |zstr, epos, defn|
      self.[zstr].add_data(epos, defn) { TrieDict.calc_prio(zstr.size) }
      @size &+= 1
    end
  end

  def self.calc_prio(size : Int32, prio : Int16 = 2)
    prio == 0 ? 0_i16 : size.to_i16 &* (prio &+ size.to_i16)
  end

  def [](zstr : String)
    zstr.each_char.reduce(self.root) do |node, char|
      succ = node.succ ||= {} of Char => Trie
      # char = char - 32 if 'ａ' <= char <= 'ｚ'debug
      succ[char] ||= Trie.new
    end
  end

  def []?(zstr : String)
    node = self.root

    zstr.each_char do |char|
      return unless succ = node.succ
      char = char - 32 if 'ａ' <= char <= 'ｚ'
      return unless node = succ[char]?
    end

    node
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

  @[AlwaysInline]
  def get_defn?(zstr : String, cpos : String)
    get_defn?(zstr: zstr, epos: MtEpos.parse(cpos))
  end

  @[AlwaysInline]
  def get_defn?(zstr : String, epos : MtEpos)
    self[zstr]?.try(&.get_defn?(epos))
  end

  @[AlwaysInline]
  def any_defn?(zstr : String)
    self[zstr]?.try(&.any_defn?)
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

  record Data, epos : MtEpos, defn : MtDefn

  class Trie
    property prio : Int16 = -1_i16
    property succ : Hash(Char, self)? = nil
    property data : Array(Data) | Data | Nil = nil

    def add_data(epos : MtEpos, defn : MtDefn, &) : Nil
      new_data = Data.new(epos, defn)

      case data = @data
      in Nil
        @data = new_data
      in Data
        @data = [data, new_data]
      in Array
        data << new_data
      end

      @prio = yield if @prio < 0
    end

    @[AlwaysInline]
    def get_defn?(cpos : String)
      get_defn?(epos: MtEpos.parse(cpos))
    end

    def get_defn?(epos : MtEpos)
      case data = @data
      in Nil then {nil, nil}
      in Data
        {epos == data.epos ? data.defn : nil, data.defn}
      in Array
        {data.find(&.epos.== epos).try(&.defn), data.first.defn}
      end
    end

    def any_defn?
      case data = @data
      in Nil   then nil
      in Data  then data.defn
      in Array then data.first.defn
      end
    end

    def delete(epos : MtEpos)
      case data = @data
      in Nil then return
      in Data
        return unless data.epos == epos
        @data = nil
        @prio = -1_i16 if @prio > 0
      in Array
        data.reject!(&.epos.== epos)
        @data = data.first if data.size == 1
      end
    end
  end
end
