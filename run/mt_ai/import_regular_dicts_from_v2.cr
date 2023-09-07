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

  def to_terms
    @zstr = CharUtil.to_canon(@zstr, true)
    @vstr = @vstr == "⛶" ? "" : @vstr.strip

    _lock = map_flag_to_lock(@_flag)

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

  def gen_term(cpos : String, vstr : String, _lock = 1)
    term = MT::ViTerm.new(zstr: @zstr, cpos: cpos, vstr: vstr, attr: map_attr(cpos))

    term.uname = @uname
    term.mtime = @mtime

    term._lock = _lock
    term._flag = @_flag

    term
  end

  def map_attr(cpos : String)
    case cpos
    when "PU"
      MT::MtAttr.parse_punct(@zstr)
    else
      return "" if @feat.empty?
      attr = MT::MtAttr::None
      @feat.split(' ') { |feat| MAP_FEAT[feat]?.try { |x| attr |= x } }
      attr
    end
  end

  MAP_FEAT = {
    # "plural" => MT::MtAttr::Nplr,
    "attrib" => MT::MtAttr::Ndes,
    "perprn" => MT::MtAttr[Nper, Npos],
    "person" => MT::MtAttr[Nper, Npos],
    "locati" => MT::MtAttr[Nloc, Npos],
    "demprn" => MT::MtAttr::Pn_d,
    "intprn" => MT::MtAttr::Pn_i,
    "vditra" => MT::MtAttr::Vdit,
    "vintra" => MT::MtAttr::Vint,
    "vmodal" => MT::MtAttr::Vmod,
  }

  def map_flag_to_lock(flag = @_flag)
    case flag
    when .< 2 then 0
    when .> 3 then 2
    else           1
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

output = inputs.flat_map(&.to_terms)
output.uniq! { |x| {x.zstr, x.cpos} }

regular, suggest = output.partition(&._lock.> 0)
puts output.size, regular.size, suggest.size

MT::ViTerm.db("regular").open_tx do |db|
  regular.each(&.upsert!(db: db))
end

MT::ViTerm.db("suggest").open_tx do |db|
  suggest.each(&.upsert!(db: db))
end
