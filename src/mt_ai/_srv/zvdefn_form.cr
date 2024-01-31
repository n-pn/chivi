require "json"

require "../data/pg_dict"
require "../data/pg_defn"

require "../../_util/char_util"
require "../../_util/viet_util"

class MT::ZvdefnForm
  include JSON::Serializable

  getter zstr : String

  getter vstr : String
  getter attr : String

  getter cpos : String
  getter rank : Int16 = 1

  getter d_no : Int32 = 0
  getter lock : Bool = true

  getter pdict : String = ""
  getter m_alg : String = ""
  getter m_con : String = ""
  getter zfrom : Int32 = 0

  def after_initialize
    @zstr = @zstr.gsub(/\p{C}+/, " ").strip
    @zstr = CharUtil.to_canon(@zstr, upcase: true)

    @vstr = @vstr.gsub(/\p{C}+/, " ").strip.unicode_normalize(:nfkc)
    @vstr = VietUtil.fix_tones(@vstr)

    @attr = MtAttr.parse_list(@attr).to_str
  end

  def load_dict!(vu_id : Int32)
    case @d_no
    when 2 then PgDict.load!("regular")
    when 0 then PgDict.load!("qt#{vu_id}")
    else        PgDict.load!(@pdict)
    end
  end

  def to_pg(vu_id : Int32, uname : String, privi : Int32)
    dict = self.load_dict!(vu_id)
    defn = PgDefn.init(dict.d_id, cpos: @cpos, zstr: @zstr)

    p_min = dict.p_min
    p_min += 1 if @lock || defn.plock > 1

    if privi < p_min
      raise Unauthorized.new "Bạn cần quyền hạn tối thiểu là #{p_min} để thêm/sửa từ"
    end

    defn.vstr = @vstr
    defn.attr = @attr
    defn.rank = @rank

    defn.plock = @lock ? 2_i16 : 1_i16
    defn.plock = -defn.plock if @vstr.empty?

    defn.uname = uname
    defn.mtime = TimeUtil.cv_mtime

    {dict, defn}
  end

  def save!(pdict : String, uname : String = "", privi = 4, persist : Bool = true)
    d_id = gen_d_id(uname)
    zdict = PgDict.load!(@dname)

    zterm = init_pg_term(zdict, uname)
    p_min = zdict.p_min + zterm.plock

    fresh = zterm.mtime < 0
  end
end
