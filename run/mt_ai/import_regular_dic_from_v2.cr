require "../../src/_util/char_util"
require "../../src/_util/viet_util"
require "../../src/mt_ai/data/vi_term"

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
  getter mtime : Int32
  getter _flag : Int32

  def to_terms(privi = 2)
    @zstr = CharUtil.to_canon(@zstr, true)
    @vstr = @vstr == "⛶" ? "" : @vstr.strip

    privi = 1 if @_flag < 2

    cpos_list = xpos.split(' ')
    cpos_list = ["_"] if cpos_list.size > 3

    terms = cpos_list.map do |cpos|
      gen_term(cpos, @vstr, privi)
    end

    unless @vmap.blank?
      @vmap.split('ǀ') do |item|
        cpos, vstr = item.split(':')
        terms << gen_term(cpos, vstr.strip, privi)
      end
    end

    terms # .uniq!(&.cpos)
  end

  def gen_term(cpos : String, vstr : String, privi = 2)
    term = MT::ViTerm.new(
      zstr: @zstr, cpos: cpos,
      vstr: vstr, prop: map_prop(cpos),
    )

    term.uname = @uname
    term.mtime = @mtime
    term.privi = @_flag < privi ? 1 : privi
    term._flag = @_flag

    term
  end

  def map_prop(cpos : String)
    case cpos
    when "PU"
      MT::MtProp.parse_punct(@zstr)
    else
      return "" if @feat.empty?
      prop = MT::MtProp::None

      @feat.split(' ') do |feat|
        MAP_FEAT[feat]?.try { |x| prop |= x }
      end
      prop
    end
  end

  MAP_FEAT = {
    # "plural" => MT::MtProp::Nplr,
    "attrib" => MT::MtProp::Ndes,
    "perprn" => MT::MtProp[Nper, Npos],
    "person" => MT::MtProp[Nper, Npos],
    "locati" => MT::MtProp[Nloc, Npos],
    "demprn" => MT::MtProp::Pn_d,
    "intprn" => MT::MtProp::Pn_i,
    "vditra" => MT::MtProp::Vdit,
    "vintra" => MT::MtProp::Vint,
    "vmodal" => MT::MtProp::Vmod,
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

regular, suggest = output.partition(&.privi.> 1)
puts output.size, regular.size, suggest.size

MT::ViTerm.db("regular").open_tx do |db|
  regular.each(&.upsert!(db: db))
end

MT::ViTerm.db("suggest").open_tx do |db|
  suggest.each(&.upsert!(db: db))
end
