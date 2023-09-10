# require "../util/*"
require "../data/*"
require "./qt_core"
require "./tl_unit"

class MT::AiDict
  @main_dict : Entry
  @auto_dict : Entry

  @@cache = {} of String => self

  def self.load(pdict : String)
    @@cache[pdict] ||= new(pdict)
  end

  def initialize(@pdict : String = "combined")
    @main_dict = Entry.load(pdict)
    @auto_dict = Entry.new(pdict, :autogen)

    @dict_list = {@main_dict, Entry.regular, @auto_dict}
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "pdict", @pdict.sub('/', ':')
      jb.field "sizes", {@main_dict.size, Entry.regular.size, @auto_dict.size}
    }
  end

  def get(zstr : String, ipos : Int8) : {MtTerm, Int8}
    get?(zstr, ipos) || get_alt?(zstr) ||
      {init(zstr, ipos), Dtype::Autogen.to_i8}
  end

  def get?(zstr : String, ipos : Int8)
    @dict_list.each do |dict|
      dict.get?(zstr, ipos).try { |found| return found }
    end
  end

  def get_alt?(zstr : String)
    @dict_list.each do |dict|
      dict.any?(zstr).try { |found| return found }
    end
  end

  def init(zstr : String, ipos : Int8) : MtTerm
    case ipos
    when MtCpos::PU
      vstr = CharUtil.normalize(zstr)
      attr = MtAttr.parse_punct(zstr)
      @auto_dict.add(zstr, ipos, vstr, attr)
    when MtCpos::EM
      @auto_dict.add(zstr, ipos, zstr, MtAttr[Asis, Capx])
    when MtCpos["URL"]
      vstr = CharUtil.normalize(zstr)
      @auto_dict.add(zstr, ipos, vstr, MtAttr[Asis, Npos])
    when MtCpos::CD, MtCpos::OD
      vstr = TlUnit.translate(zstr) rescue QtCore.tl_hvword(zstr)
      @auto_dict.add(zstr, ipos, vstr, :none)
    when MtCpos::VV
      vstr = init_vv(zstr)
      @auto_dict.add(zstr, ipos, vstr, :none)
    when MtCpos::NR
      # TODO: call special name translation engine
      vstr = QtCore.tl_hvname(zstr)
      @auto_dict.add(zstr, ipos, vstr, :none)
    else
      vstr = QtCore.tl_hvword(zstr)
      @auto_dict.add(zstr, ipos, vstr, :none)
    end
  end

  def init_vv(zstr : String)
    if match = MtPair.vrd_pair.find_any(zstr)
      a_zstr, b_term = match
      a_term, _dic = get(a_zstr, MtCpos::VV)
      "#{a_term.vstr} #{b_term.a_vstr}"
    elsif zstr[0] == '一'
      b_term, _ = get(zstr[1..], MtCpos::VV)
      "#{b_term.vstr} một phát"
    elsif zstr[0] == '吓'
      b_term, _ = get(zstr[1..], MtCpos::VV)
      "dọa #{b_term.vstr}"
    else
      QtCore.tl_hvword(zstr)
    end
  end

  # def self.get_special?(astr : String, bstr : String)
  #   Entry.special.get?(astr, bstr).try(&.[0])
  # end

  # def self.get_special?(astr : String, *bstr : String)
  #   Entry.special.get?(astr, *bstr).try(&.[0])
  # end

  ###########

  enum Dtype : Int8
    Unknown = 0 # reserved
    Essence = 1 # top most level definitions, triumph all, for unique terms only
    Primary = 2 # book dict/priv dict/fixture dict that override regular terms
    Regular = 3 # glossaries shared for all books/projects
    Hintpri = 4 # cpos type "_" in primary dict
    Hintreg = 5 # cpos type "_" in regular dict
    Autogen = 6 # entries auto translated by system
  end

  class Entry
    getter data = {} of String => Hash(Int8, MtTerm)

    getter dname : String
    getter dtype : Dtype

    delegate size, to: @data

    def initialize(@dname : String, @dtype : Dtype = :primary)
    end

    # def get?(zstr : String, cpos : String)
    #   get?(zstr, MtCpos[cpos])
    # end

    def get?(zstr : String, ipos : Int8)
      return unless entry = @data[zstr]?
      return unless found = entry[ipos]?
      {found, @dtype.to_i8}
    end

    def any?(zstr : String)
      return unless entry = @data[zstr]?
      return unless found = entry[0]? || entry.first_value?
      {found, @dtype.to_i8 &+ 2_i8}
    end

    ####

    def add(zstr : String, cpos : String, vstr : String, attr : String) : MtTerm
      add(zstr, ipos: MtCpos[cpos], vstr: vstr, attr: attr)
    end

    def add(zstr : String, ipos : Int8, vstr : String, attr : String) : MtTerm
      entry = @data[zstr] ||= {} of Int8 => MtTerm
      entry[ipos] = MtTerm.new(vstr, attr: MtAttr.parse_list(attr))
    end

    def add(zstr : String, cpos : String, vstr : String, attr : MtAttr = :none) : MtTerm
      add(zstr, MtCpos[cpos], vstr, attr)
    end

    def add(zstr : String, ipos : Int8, vstr : String, attr : MtAttr = :none) : MtTerm
      entry = @data[zstr] ||= {} of Int8 => MtTerm
      entry[ipos] = MtTerm.new(vstr, attr)
    end

    def load_tsv!(dname : String = @dname)
      db_path = ViTerm.db_path(dname, "tsv")
      return self unless File.file?(db_path)

      File.each_line(db_path) do |line|
        cols = line.split('\t')
        next if cols.size < 3
        attr = MtAttr.parse_list(cols[3]?)
        add(cols[0], cols[1], cols[2], attr: attr)
      end

      self
    end

    def load_db3!(dname : String = @dname)
      ViTerm.db(dname).open_ro do |db|
        query = "select zstr, icpos, vstr, iattr from #{ViTerm.schema.table}"

        db.query_each(query) do |rs|
          zstr, ipos, vstr, iattr = rs.read(String, Int32, String, Int32)
          add(zstr, ipos: ipos.to_i8, vstr: vstr, attr: MtAttr.new(iattr))
        end
      end

      # ViTerm.db(dname).open_ro do |db|
      #   query = "select zstr, cpos, vstr, iattr from #{ViTerm.schema.table}"

      #   db.query_each(query) do |rs|
      #     zstr, cpos, vstr, iattr = rs.read(String, String, String, Int32)
      #     add(zstr, cpos: cpos, vstr: vstr, attr: MtAttr.new(iattr))
      #   end
      # end

      self
    rescue ex
      self
    end

    ###

    class_getter special : self { new("special", :essence).load_tsv! }
    class_getter regular : self { new("regular", :regular).load_db3!.load_tsv! }

    {% if flag?(:release) %}
      class_getter suggest : self { new("suggest", :suggest).load_db3! }
    {% else %}
      class_getter suggest : self { new("suggest", :suggest) }
    {% end %}

    # @@expire = {} of String => Time
    @@cached = {} of String => self

    def self.load(dname : String, dtype : Dtype = :primary)
      # @@expire[dname] = Time.utc + 10.minutes
      @@cached[dname] ||= new(dname, dtype).load_db3!.load_tsv!
    end
  end
end
