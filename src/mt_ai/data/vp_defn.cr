require "./vp_term"
require "./vp_pecs"

# struct AI::VpDefn
#   getter vmap = {} of String => String
#   getter opts = MtOpts::None

#   def initialize(vmap : String = "")
#     @opts = MtOpts::None

#     vmap.split('ǀ') do |elem|
#       cpos, vstr = elem.split(':', 2)
#       @opts = MtOpts.for_punctuation(vstr) if cpos == "PU"
#       @vmap[cpos] = vstr
#       @vmap[""] ||= vstr
#     end
#   end

#   # EXTRA TAGS:
#   # N: all nouns
#   # V: all verbs/adjts
#   # _C: all content words
#   # _F: all function words

#   SUPERSETS = {
#     "VV" => {"V", "_C"},
#     "VA" => {"V", "_C"},
#     "NN" => {"N", "_C"},
#     "NT" => {"N", "_C"},
#   }

#   def add(cpos : String, vstr : String)
#     @vmap[cpos] = vstr
#     return unless alts = SUPERSETS[cpos]?
#     alts.each { |alt| @vmap[alt] = vstr }
#   end

#   def get_defn(ptag : String) : String
#     case val = @vstr
#     when String then val
#     else             val.fetch(ptag) { val[""] }
#     end
#   end
# def self.load_vmap_from_db(db_path : String)
#   defns = Defns.new

#   DB.open("sqlite3:#{db_path}") do |db|
#     db.query_each "select zstr, vstr, vmap, xpos from defns" do |rs|
#       zstr, vstr, vmap, ptag = rs.read(String, String, String, String)

#       vstr = "" if vstr == "⛶"
#       ptag = ptag.split(' ').first

#       data = "#{ptag}:#{vstr}"
#       data = "#{data}ǀ#{vmap}" unless vmap.blank?
#       defns[zstr] = VpDefn.new(data)
#     end
#   end

#   defns
# end
# end

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
