require "json"
require "../data/vi_term"
require "../../_util/char_util"
require "../../_util/viet_util"

class MT::ViTermForm
  include JSON::Serializable

  getter zstr : String
  getter vstr : String

  getter cpos : String
  getter attr : String

  getter dname : String
  getter plock : Int32

  struct Context
    getter wn_id : Int32
    getter ctree : String
    getter ztext : String
    getter zfrom : Int32
    include JSON::Serializable
  end

  getter _ctx : Context | Nil = nil

  def after_initialize
    @zstr = @zstr.gsub(/\p{C}+/, " ").strip
    @zstr = CharUtil.to_canon(@zstr, upcase: true)

    @vstr = @vstr.gsub(/\p{C}+/, " ").strip.unicode_normalize(:nfkc)
    @vstr = VietUtil.fix_tones(@vistr)
  end

  def min_privi(dname = @dname)
    case dname
    when "regular", "suggest"  then 1
    when .starts_with?("book") then 0
    when .starts_with?("priv") then 0
    when 2
    end
  end

  def validate!(_privi : Int32 = -1, prev = ViTerm.find(@zstr, @cpos, @dname))
    min_plock = prev ? prev.plock : 0
    min_privi = self.min_privi(@dname) + min_plock

    if _privi < min_privi
      raise Unauthorized.new "Bạn cần quyền hạn tối thiểu là #{min_privi} để thêm/sửa từ"
    end

    if @plock < min_plock && _privi < min_privi &+ 1
      raise Unauthorized.new "Từ đã bị khoá, bạn cần quyền hạn tối thiểu là #{min_privi + 1} để đổi khoá"
    end
  end

  def save!(uname : String, mtime = ViTerm.mtime) : ViTerm
    term = ViTerm.new(
      zstr: @zstr, cpos: @cpos,
      vstr: @vstr, attr: @attr,
      uname: uname, mtime: mtime,
      plock: @plock
    )

    term.tap(&.insert!(db: ViTerm.db(@dname)))
  end
end
