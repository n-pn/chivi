require "json"

require "../data/vi_term"
require "../data/vi_dict"

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
    @vstr = VietUtil.fix_tones(@vstr)

    @cpos = "_" unless @cpos.in?(MtCpos::ALL)
    @attr = MtAttr.parse_list(@attr).to_str

    @dname = @dname.sub(':', '/')
    @plock = 1 unless 0 <= @plock <= 2
  end

  def prev_term
    ViTerm.find(@zstr, @cpos, @dname)
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
