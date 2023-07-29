require "sqlite3"

struct AI::MtDefn
  @defns = {} of String => String

  def initialize(vstr : String, vmap : String)
    vmap.split('|') do |item|
      xpos, vstr = item.split(':', 2)
      add_defn("xpos", vstr)
      @defns[xpos] = vstr
    end

    @defns["*"] = vstr
  end

  # EXTRA TAGS:
  # N: all nouns
  # V: all verbs/adjts
  # _C: all content words
  # _F: all function words

  SUPERSETS = {
    "VV" => {"V", "_C", "*"},
    "VA" => {"V", "_C", "*"},
    "NN" => {"N", "_C", "*"},
    "NT" => {"N", "_C", "*"},
  }

  def add_defn(xpos : String, vstr : String)
    @defns[xpos] = vstr
    return unless alts = SUPERSETS[xpos]?
    alts.each { |alt| @defns[alt] = vstr }
  end

  def get_defn(xpos : String) : String?
    @defns[xpos]?
  end

  def get_alt_defn(xpos : String) : String
    if alts = SUPERSETS[xpos]?
      alts.each do |alt|
        if vstr = @defns[alt]?
          return vstr
        end
      end
    end

    @defns["*"]
  end
end

class AI::MtDict
  alias Defns = Hash(String, AI::MtDefn)

  def self.load_vmap_from_db(db_path : String)
    defns = Defns.new

    DB.open("sqlite3:#{db_path}") do |db|
      db.query_each "select zstr, vstr, vmap from defns" do |rs|
        zstr, vstr, vmap = rs.read(String, String, String)
        defns[zstr] = MtDefn.new(vstr, vmap)
      end
    end

    defns
  end

  DIR = "var/mtdic/fixed"
  class_getter common : Defns { load_vmap_from_db("#{DIR}/common-main.dic") }

  getter defns : Defns

  def initialize(@wn_id : Int32, @uname = "")
    # TODO: load overrides
    @defns = self.class.common
  end

  def translate(zstr : String, xpos : String)
    return auto_translate(zstr, xpos) unless existed = @defns[zstr]?
    existed.get_defn(xpos) || existed.get_alt_defn(xpos)
  end

  def auto_translate(zstr : String, xpos : String)
    # FIXME: add simple translation machine here
    zstr
  end
end
