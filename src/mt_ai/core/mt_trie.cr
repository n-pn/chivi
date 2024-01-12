require "../data/sq_defn"
require "../data/sq_wseg"
require "../data/mt_defn"
require "../data/mt_wseg"

class MT::MtTrie
  class_getter essence : self { load!("essence") }
  class_getter regular : self { load!("regular") }

  class_getter suggest : self { load!("suggest") }
  class_getter nqnt_vi : self { load!("nqnt_vi") }

  CACHE = {} of Int32 => self

  def self.load!(name : String) : self
    d_id = MtDtyp.map_id(name)
    CACHE[d_id] ||= init!(d_id, name)
  end

  def self.init!(d_id : Int32, name : String)
    root = self.new
    time = Time.monotonic
    size = 0

    SqDefn.query_each(d_id) do |zstr, epos, defn|
      size &+= 1
      root[zstr].add_data(epos, defn) { MtWseg.new(zstr) }
    end

    tsv_file = "var/mtdic/wseg/#{name}.tsv"

    if File.file?(tsv_file)
      File.each_line(tsv_file) do |line|
        cols = line.split('\t')
        root[cols[0]].wseg = MtWseg.new(cols) unless cols.empty?
      end
    end

    time = Time.monotonic - time
    Log.info { "loading #{name} trie: #{time.total_milliseconds}ms, entries: #{size}" }

    root
  end

  def self.add_term(dname : String, wterm : MtWseg)
    CACHE[dname]?.try(&.[wstem.zstr] = wterm)
  end

  def self.delete_term(dname : String, zstr : String)
    CACHE[dname]?.try(&.[zstr] = nil)
  end

  ####

  property succ = {} of Char => MtTrie
  property vals : Hash(MtEpos, MtDefn)? = nil
  property defn : MtDefn? = nil
  property wseg : MtWseg? = nil

  # def []=(zstr : String, term : MtWseg?)
  #   self[zstr].term = term
  # end

  def [](zstr : String)
    zstr.each_char.reduce(self) do |node, char|
      # char = CharUtil.to_canon(char, true)
      node.succ[char] ||= MtTrie.new
    end
  end

  def []?(zstr : String)
    node = self
    zstr.each_char { |char| break unless node = node.succ[char]? }
    node
  end

  def add_data(epos : MtEpos, defn : MtDefn, & : MtWseg? ->) : Nil
    vals = @vals ||= {} of MtEpos => MtDefn
    vals[epos] = defn

    @defn = defn if epos.x? || !@defn
    @wseg = yield @wseg
  end

  def scan_wseg(input : Array(Char), start : Int32 = 0, &)
    node = self
    size = 0

    start.upto(input.size &- 1) do |idx|
      char = input.unsafe_fetch(idx)
      # char = CharUtil.to_canon(char, true)

      break unless node = node.succ[char]?
      next unless wseg = node.wseg

      yield idx &- start &+ 1, wseg
    end
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
end
