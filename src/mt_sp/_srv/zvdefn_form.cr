require "json"
require "../data/zv_defn"

class SP::ZvdefnForm
  include JSON::Serializable

  getter zstr : String

  getter vstr : String
  getter attr : String

  getter cpos : String
  getter rank : Int16 = 1

  getter d_idx : Int32 = 0
  getter _lock : Bool = false

  getter pdict : String = ""
  getter m_alg : String = ""
  getter m_con : String = ""
  getter zfrom : Int32 = 0

  def after_initialize
    @zstr = @zstr.gsub(/\p{C}+/, " ").strip
    @zstr = CharUtil.fast_sanitize(@zstr)
    @d_idx = 0 if @d_idx < 0
  end

  def dict_for(vu_id : Int32, d_idx = @d_idx)
    case d_idx
    when 0 then {"qt#{vu_id}", 0}
    when 2 then {"regular", 2}
    else        {@pdict, 1}
    end
  end

  def to_pg(vu_id : Int32, uname : String, privi : Int32)
    dict, p_min = dict_for(vu_id)
    defn = Zvdefn.init(dict: dict, cpos: @cpos, zstr: @zstr)

    p_min += 1 if @_lock || defn._lock > 1

    if privi < p_min
      raise Unauthorized.new "Bạn cần quyền hạn tối thiểu là #{p_min} để thêm/sửa từ"
    end

    defn.add_defn(@vstr, @attr, @rank)
    defn.add_meta(uname, _lock: @_lock ? 2_i16 : 1_i16)

    {dict, defn}
  end
end
