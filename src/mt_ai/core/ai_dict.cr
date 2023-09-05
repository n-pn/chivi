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

  def initialize(pdict : String = "combined")
    @main_dict = Entry.load(pdict)
    @auto_dict = Entry.new(pdict, :autogen)

    @dict_list = {
      @main_dict,
      Entry.regular,
      @auto_dict,
      Entry.suggest,
    }
  end

  def get(zstr : String, cpos : String) : {MtTerm, Int32}
    get?(zstr, cpos) || get_alt?(zstr) || {init(zstr, cpos), Dtype::Autogen.to_i}
  end

  def get?(zstr : String, cpos : String)
    @dict_list.each do |dict|
      dict.get?(zstr, cpos).try { |found| return found }
    end
  end

  def get_alt?(zstr : String)
    @dict_list.each do |dict|
      dict.any?(zstr).try { |found| return found }
    end
  end

  def init(zstr : String, cpos : String) : MtTerm
    case cpos
    when "PU"
      vstr = CharUtil.normalize(zstr)
      pecs = MtPecs.parse_punct(zstr)
      @auto_dict.add(zstr, cpos, vstr, pecs)
    when "EM"
      @auto_dict.add(zstr, cpos, zstr, MtPecs[Ncap, Capx])
    when "URL"
      vstr = CharUtil.normalize(zstr)
      @auto_dict.add(zstr, cpos, vstr, MtPecs[Ncap])
    when "CD", "OD"
      vstr = TlUnit.translate(zstr) rescue QtCore.tl_hvword(zstr)
      @auto_dict.add(zstr, cpos, vstr, :none)
    when "NR"
      # TODO: call special name translation engine
      vstr = QtCore.tl_hvname(zstr)
      @auto_dict.add(zstr, cpos, vstr, :none)
    else
      vstr = QtCore.tl_hvword(zstr)
      @auto_dict.add(zstr, cpos, vstr, :none)
    end
  end

  def self.get_special?(astr : String, bstr : String)
    Entry.special.get?(astr, bstr).try(&.[0])
  end

  def self.get_special?(astr : String, *bstr : String)
    Entry.special.get?(astr, *bstr).try(&.[0])
  end

  ###########

  enum Dtype
    Unknown = 0 # reserved
    Essence = 1 # top most level definitions, triumph all, for unique terms only
    Primary = 2 # book dict/priv dict/fixture dict that override regular terms
    Regular = 3 # glossaries shared for all books/projects
    Suggest = 4 # collected from multi sources as fallback
    Autogen = 5 # entries auto translated by system
  end

  class Entry
    getter data = {} of String => Hash(String, MtTerm)

    getter dname : String
    getter dtype : Dtype

    def initialize(@dname : String, @dtype : Dtype = :primary)
    end

    def get?(zstr : String, cpos : String)
      return unless entry = @data[zstr]?
      return unless found = entry[cpos]?
      {found, @dtype.to_i}
    end

    def get?(zstr : String, *cpos_list : String)
      return unless entry = @data[zstr]?

      cpos_list.each do |cpos|
        next unless found = entry[cpos]
        return found
      end
    end

    def any?(zstr : String)
      return unless entry = @data[zstr]?
      return unless found = entry["_"]? || entry.first_value?
      {found, @dtype.to_i}
    end

    ####

    def add(zstr : String, cpos : String, vstr : String, pecs : String | Nil) : MtTerm
      entry = @data[zstr] ||= {} of String => MtTerm
      entry[cpos] = MtTerm.new(vstr, pecs: MtPecs.parse_list(pecs))
    end

    def add(zstr : String, cpos : String, vstr : String, pecs : MtPecs = :none) : MtTerm
      entry = @data[zstr] ||= {} of String => MtTerm
      entry[cpos] = MtTerm.new(vstr, pecs)
    end

    def load_tsv!(dname : String = @dname)
      db_path = MtDefn.db_path(dname, "tsv")
      return self unless File.file?(db_path)

      File.each_line(db_path) do |line|
        cols = line.split('\t')
        next if cols.size < 3
        # puts cols
        add(cols[0], cols[1], cols[2], cols[3]?)
      end

      self
    end

    def load_db3!(dname : String = @dname)
      MtDefn.db(dname).open_ro do |db|
        db.query_each("select zstr, cpos, vstr, ipecs from defns") do |rs|
          zstr, cpos, vstr, pecs = rs.read(String, String, String, Int32)
          add(zstr, cpos, vstr, MtPecs.new(pecs))
        end
      end

      self
    rescue ex
      self
    end

    ###

    class_getter essence : self { new("essence", :essence).load_tsv! }
    class_getter special : self { new("special", :essence).load_tsv! }
    class_getter regular : self { new("regular", :regular).load_db3! }
    class_getter suggest : self { new("suggest", :suggest).load_db3! }

    # @@expire = {} of String => Time
    @@cached = {} of String => self

    def self.load(dname : String, dtype : Dtype = :primary)
      # @@expire[dname] = Time.utc + 10.minutes
      @@cached[dname] ||= new(dname, dtype).load_db3!.load_tsv!
    end
  end
end
