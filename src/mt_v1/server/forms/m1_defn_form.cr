require "json"
require "../../data/v1_dict"

class M1::DefnForm
  include JSON::Serializable

  getter dic : String
  getter tab : Int32 = 0

  getter key : String
  getter val : String

  getter ptag : String = ""
  getter prio : Int32 = 2

  getter _ctx : String

  @[JSON::Field(ignore: true)]
  getter! vdict : DbDict

  def after_initialize
    @key = @key.gsub(/[\p{C}\s]+/, " ").strip
    @val = @val.gsub(/[\p{C}\s]+/, " ").strip.unicode_normalize(:nfc)
    @vdict = DbDict.get!(@dic)
  end

  private def min_privi(dic : Int32)
    case dic
    when -4, .>(0)    then {2, 1, 0, 2} # novel dicts or combine
    when -1, -10, -11 then {3, 2, 1, 3} # regular, hanviet, pin_yin
    else                   {4, 3, 2, 4} # system dicts
    end
  end

  def validate!(privi = -1) : Nil
    reg_privi = min_privi(vdict.id!)[@tab]? || 3

    if privi < reg_privi
      raise Unauthorized.new("Yên cầu quyền hạn tối thiểu #{reg_privi} để thêm từ")
    end
  end

  def save!(uname : String, mtime = DbDefn.mtime) : DbDefn
    defn = DbDefn.new

    defn.dic = vdict.id!
    defn.tab = @tab

    defn.key = @key
    defn.val = @val

    defn.ptag = @ptag
    defn.prio = @prio

    defn.uname = uname
    defn.mtime = mtime

    defn._ctx = @_ctx

    defn.save!(DbDefn.repo)

    vdict.update_after_term_added!(defn.mtime)

    defn

    # TODO: generate DbTerm from defn
  end
end
