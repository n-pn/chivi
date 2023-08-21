require "json"
require "../data/v1_dict"
require "../../_util/char_util"

class M1::DefnForm
  include JSON::Serializable

  getter key : String
  getter val : String

  getter ptag : String = ""
  getter prio : Int32 = 2

  getter dic : Int32 = 0
  getter tab : Int32 = 1

  record Ctx, wn_id : Int32, input : String, index : Int32 do
    include JSON::Serializable

    def to_s
      "#{input}:#{index}:#{wn_id}"
    end
  end

  getter _ctx : Ctx | Nil = nil

  def after_initialize
    @key = @key.gsub(/[\p{C}\s]+/, " ").strip
    @key = CharUtil.to_canon(@key, upcase: true)

    @val = @val.gsub(/[\p{C}\s]+/, " ").strip.unicode_normalize(:nfkc)
    @val = @val.split(/[|ǀ]/, remove_empty: true).map!(&.strip).join('\t')

    @dic = -1 if @dic < 0
    @tab = 1 if @tab < 1
  end

  REG_PRIVI = {0, 2, 1, 3}

  def validate!(_privi = -1) : Nil
    req_privi = REG_PRIVI[@tab]
    req_privi -= 1 if @dic >= 0

    return unless req_privi > _privi
    raise Unauthorized.new("Yên cầu quyền hạn tối thiểu #{req_privi} để thêm từ")
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

    defn._ctx = @_ctx.to_s

    defn.tap(&.insert!)
  end
end
