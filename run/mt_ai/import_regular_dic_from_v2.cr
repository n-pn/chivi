require "../../src/_util/char_util"
require "../../src/_util/viet_util"
require "../../src/mt_ai/data/mt_defn"

INP_PATH = "var/mtdic/fixed/common-main.dic"

regular = [] of {String, String, String, Int32}
suggest = [] of {String, String, String, Int32}

struct Input
  include DB::Serializable
  include DB::Serializable::NonStrict

  getter zstr : String
  getter vstr : String
  getter vmap : String
  getter xpos : String
  getter feat : String

  getter uname : String
  getter mtime : Int64
  getter _flag : Int32

  def fix_input!
  end

  def to_terms(_lock = 2)
    @zstr = CharUtil.to_canon(@zstr, true)
    @vstr = @vstr == "⛶" ? "" : @vstr.strip

    _lock = 1 if @_flag < 2

    cpos_list = xpos.split(' ')
    cpos_list = ["_"] if cpos_list.size > 3

    terms = cpos_list.map do |cpos|
      gen_term(cpos, @vstr, _lock)
    end

    unless @vmap.blank?
      @vmap.split('ǀ') do |item|
        cpos, vstr = item.split(':')
        terms << gen_term(cpos, vstr.strip, _lock)
      end
    end

    terms # .uniq!(&.cpos)
  end

  def gen_term(cpos : String, vstr : String, _lock = 2)
    MT::MtDefn.new(
      zstr: @zstr,
      cpos: cpos,
      vstr: VietUtil.fix_tones(vstr),
      pecs: map_pecs(cpos),
      uname: @uname,
      mtime: @mtime,
      _lock: @_flag < _lock ? 1 : _lock,
      _flag: @_flag
    )
  end

  def map_pecs(cpos : String)
    case cpos
    when "PU"
      MT::MtPecs.parse_punct(@zstr).to_s.gsub(" | ", " ")
    else
      return "" if @feat.empty?
      @feat.split(' ').map { |x| MAP_FEAT[x] }.join(' ')
    end
  end

  MAP_FEAT = {
    "plural" => "Nplr",
    "attrib" => "Ndes",
    "person" => "Nper",
    "locati" => "Nloc",
    "perprn" => "Pn_p",
    "demprn" => "Pn_d",
    "intprn" => "Pn_i",
    "vditra" => "Vdit",
    "vintra" => "Vint",
    "vmodal" => "Vmod",
  }

  def map_flag(flag = @_flag)
    case flag
    when .< 2 then 1
    when .> 3 then 3
    else           2
    end
  end
end

# feat = DB.connect("sqlite3:#{INP_PATH}?immutable=1") do |db|
#   db.query_all "select feat from defns where feat <> ''", as: String
# end

# puts feat.compact_map(&.split(' ')).uniq!

inputs = DB.connect("sqlite3:#{INP_PATH}?immutable=1") do |db|
  db.query_all "select * from defns where vstr <> ''", as: Input
end

output = inputs.flat_map(&.to_terms(2))
output.uniq! { |x| {x.zstr, x.cpos} }

regular, suggest = output.partition(&._lock.> 1)
puts output.size, regular.size, suggest.size

MT::MtDefn.db("regular").open_tx do |db|
  regular.each(&.upsert!(db: db))
end

MT::MtDefn.db("suggest").open_tx do |db|
  suggest.each(&.upsert!(db: db))
end
