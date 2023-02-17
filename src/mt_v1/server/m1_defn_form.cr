require "json"
require "../data/v1_dict"

class M1::DefnForm
  include JSON::Serializable

  getter dic : Int32 = 0
  getter tab : Int32 = 1

  getter key : String
  getter val : String

  getter ptag : String = ""
  getter prio : Int32 = 2

  getter _ctx : String

  def after_initialize
    @key = @key.gsub(/[\p{C}\s]+/, " ").strip
    @val = @val.gsub(/[\p{C}\s]+/, " ").strip.unicode_normalize(:nfkc)
  end

  private def min_privi(dic : Int32)
    case dic
    when -4, .>(0)    then 0 # novel dicts or combine
    when -1, -10, -11 then 1 # regular, hanviet, pin_yin
    else                   2 # system dicts
    end
  end

  def validate!(privi = -1) : Nil
    reg_privi = min_privi(@dic)

    if reg_privi > privi
      raise Unauthorized.new("Yên cầu quyền hạn tối thiểu #{reg_privi} để thêm từ")
    end

    @tab = privi == reg_privi ? 2 : 1
  end

  def save!(uname : String, mtime = DbDefn.mtime) : DbDefn
    defn = DbDefn.new

    defn.dic = @dic
    defn.tab = @tab

    defn.key = @key
    defn.val = @val

    defn.ptag = @ptag
    defn.prio = @prio

    defn.uname = uname
    defn.mtime = mtime

    defn._ctx = @_ctx

    defn.tap(&.save!)
  end
end
