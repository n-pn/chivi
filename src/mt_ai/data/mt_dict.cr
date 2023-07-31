require "sqlite3"
require "./mt_opts"

struct AI::MtDefn
  getter vstr : String | Hash(String, String)
  getter opts = MtOpts::None

  def initialize(vstr : String, xpos : String, vmap : String = "")
    if xpos == "PU"
      @opts = MtOpts.for_punctuation(vstr)
    elsif vstr == "⛶"
      @opts = MtOpts::Hidden
      vstr = ""
    else
      @opts = MtOpts::None
    end

    if vmap.empty?
      @vstr = vstr
    else
      hash = {"" => vstr}
      vmap.split('ǀ') do |elem|
        xpos, vstr = elem.split(':', 2)
        hash[xpos] = vstr
      end

      @vstr = hash
    end
  end

  # EXTRA TAGS:
  # N: all nouns
  # V: all verbs/adjts
  # _C: all content words
  # _F: all function words

  SUPERSETS = {
    "VV" => {"V", "_C"},
    "VA" => {"V", "_C"},
    "NN" => {"N", "_C"},
    "NT" => {"N", "_C"},
  }

  def add_defn(xpos : String, vstr : String)
    @vmap[xpos] = vstr
    return unless alts = SUPERSETS[xpos]?
    alts.each { |alt| @vmap[alt] = vstr }
  end

  def get_defn(xpos : String) : String
    case val = @vstr
    when String then val
    else             val.fetch(xpos) { val[""] }
    end
  end
end

class AI::MtDict
  alias Defns = Hash(String, AI::MtDefn)

  def self.load_vmap_from_db(db_path : String)
    defns = Defns.new

    DB.open("sqlite3:#{db_path}") do |db|
      db.query_each "select zstr, vstr, vmap, xpos from defns" do |rs|
        zstr, vstr, vmap, xpos = rs.read(String, String, String, String)
        defns[zstr] = MtDefn.new(vstr, xpos, vmap)
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

  def find(zstr : String, xpos : String) : {String, MtOpts}
    return init(zstr, xpos) unless defn = @defns[zstr]?
    {defn.get_defn(xpos), defn.opts}
  end

  def init(zstr : String, xpos : String)
    # FIXME: add simple translation machine here
    # FIXME: cache translation

    case xpos
    when "PU"
      vstr = CharUtil.normalize(zstr)
      {vstr, MtOpts.for_punctuation(vstr)}
    when "CD"
      {translate_number(zstr), MtOpts::None}
    else
      pp [zstr, xpos]
      {zstr, MtOpts::None}
    end
  end

  def translate_number(zstr : String)
    case zstr
    when /^[\d+\p{P}]+$/ then CharUtil.normalize(zstr)
    else
      # TODO: translate hanzi numbers
      zstr
    end
  end
end
