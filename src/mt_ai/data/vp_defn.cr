require "./vp_term"
require "./vp_pecs"

#   # EXTRA TAGS:
#   # N: all nouns
#   # V: all verbs/adjts
#   # C: all content words
#   # F: all function words

#   SUPERSETS = {
#     "VV" => {"V", "C"},
#     "VA" => {"V", "C"},
#     "NN" => {"N", "C"},
#     "NT" => {"N", "C"},
#   }

class AI::VpDefn
  struct Entry
    getter vstr : String
    getter pecs : VpPecs

    def initialize(@vstr, @pecs = :none)
    end
  end

  enum Dtype
    Unknown = 0 # reserved
    Essence = 1 # top most level definitions, triumph all, for unique terms only
    Primary = 2 # book dict/priv dict/fixture dict that override regular terms
    Regular = 3 # glossaries shared for all books/projects
    Suggest = 4 # collected from multi sources as fallback
    Autogen = 5 # entries auto translated by system
  end

  getter data = {} of String => Hash(String, Entry)

  getter dname : String
  getter dtype : Dtype

  def initialize(@dname : String, @dtype : Dtype = :primary)
  end

  def get?(zstr : String, cpos : String)
    return unless entry = @data[zstr]?
    return unless found = entry[cpos]?
    {found.vstr, found.pecs, @dtype.to_i}
  end

  def any?(zstr : String)
    return unless entry = @data[zstr]?
    return unless found = entry["_"]? || entry.first_value?
    {found.vstr, found.pecs, @dtype.to_i}
  end

  ####

  def add(zstr : String, cpos : String, vstr : String, pecs : String | Nil) : Entry
    entry = @data[zstr] ||= {} of String => Entry
    entry[cpos] = Entry.new(vstr, VpPecs.parse_list(pecs))
  end

  def add(zstr : String, cpos : String, vstr : String, pecs : VpPecs = :none) : Entry
    entry = @data[zstr] ||= {} of String => Entry
    entry[cpos] = Entry.new(vstr, pecs)
  end

  def load_tsv!(dname : String = @dname)
    db_path = VpTerm.db_path(dname, "tsv")

    File.each_line(db_path) do |line|
      cols = line.split('\t')
      add(cols[0], cols[1], cols[2], cols[3]?) if cols.size > 2
    end

    self
  end

  def load_db3!(dname : String = @dname)
    VpTerm.db(dname).open_ro do |db|
      db.query_each("select zstr, cpos, vstr, pecs from terms") do |rs|
        zstr, cpos, vstr, pecs = rs.read(String, String, String, String)
        add(zstr, cpos, vstr, pecs)
      end
    end

    self
  end

  class_getter essence : self { new("essence", :essence).load_tsv! }
  class_getter regular : self { new("regular", :regular).load_db3! }
  class_getter suggest : self { new("suggest", :suggest).load_db3! }

  # @@expire = {} of String => Time
  @@cached = {} of String => self

  def self.load(dname : String, dtype : Dtype = :primary)
    # @@expire[dname] = Time.utc + 10.minutes
    @@cached[dname] ||= new(dname, dtype).load_db3!.load_tsv!
  end
end
