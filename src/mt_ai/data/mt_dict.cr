require "sqlite3"
require "./mt_opts"
require "../util/*"
require "../../mtapp/sp_core"

struct AI::MtDefn
  getter vmap = {} of String => String
  getter opts = MtOpts::None

  def initialize(vmap : String = "")
    @opts = MtOpts::None

    vmap.split('ǀ') do |elem|
      ptag, vstr = elem.split(':', 2)
      @opts = MtOpts.for_punctuation(vstr) if ptag == "PU"
      @vmap[ptag] = vstr
      @vmap[""] ||= vstr
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

  def add_defn(ptag : String, vstr : String)
    @vmap[ptag] = vstr
    return unless alts = SUPERSETS[ptag]?
    alts.each { |alt| @vmap[alt] = vstr }
  end

  def get_defn(ptag : String) : String
    case val = @vstr
    when String then val
    else             val.fetch(ptag) { val[""] }
    end
  end
end

class AI::MtDict
  alias Defns = Hash(String, AI::MtDefn)

  def self.load_vmap_from_db(db_path : String)
    defns = Defns.new

    DB.open("sqlite3:#{db_path}") do |db|
      db.query_each "select zstr, vstr, vmap, xpos from defns" do |rs|
        zstr, vstr, vmap, ptag = rs.read(String, String, String, String)

        vstr = "" if vstr == "⛶"
        ptag = ptag.split(' ').first

        data = "#{ptag}:#{vstr}"
        data = "#{data}ǀ#{vmap}" unless vmap.blank?
        defns[zstr] = MtDefn.new(data)
      end
    end

    defns
  end

  DIR = "var/mtdic/fixed"
  class_getter generic : Defns { load_vmap_from_db("#{DIR}/common-main.dic") }

  class_getter fixture : Defns do
    defns = Defns.new

    File.each_line("./src/mt_ai/data/fixed.tsv") do |line|
      next if line.blank?
      zstr, vmap = line.split('\t')
      defns[zstr] = MtDefn.new(vmap)
    end

    defns
  end

  getter dicts : Array(Defns)

  def initialize(@wn_id : Int32, @uname = "")
    # TODO: load overrides
    @dicts = [
      self.class.fixture,
      Defns.new,
      self.class.generic,
    ]
  end

  def find(zstr : String, ptag : String) : {String, MtOpts}
    vstr = opts = nil

    @dicts.each do |dict|
      next unless defn = dict[zstr]?
      opts ||= defn.opts

      if vstr = defn.vmap[ptag]?
        opts = MtOpts::Hidden if vstr == ""
        return {vstr, opts}
      else
        vstr ||= defn.vmap[""]?
      end
    end

    if vstr
      return {vstr, opts || MtOpts::None}
    else
      init(zstr, ptag)
    end
  end

  def init(zstr : String, ptag : String)
    # FIXME: add simple translation machine here
    # FIXME: cache translation

    case ptag
    when "PU"
      vstr = CharUtil.normalize(zstr)
      {vstr, MtOpts.for_punctuation(vstr)}
    when "CD", "OD"
      {QtNumber.translate(zstr), MtOpts::None}
    else
      pp [zstr, ptag]
      {MT::SpCore.tl_hvname(zstr), MtOpts::None}
    end
  end
end
