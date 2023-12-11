require "json"

require "../data/vi_term"
require "../data/zv_dict"

require "../../_util/char_util"
require "../../_util/viet_util"

class MT::ViTermForm
  include JSON::Serializable

  getter zstr : String
  getter vstr : String

  getter cpos : String
  getter attr : String

  getter dname : String
  getter plock : Int16 = 0_i16

  getter toks : Array(Int32) = [] of Int32
  getter ners : Array(String) = [] of String

  getter posr : Int16 = 2_i16
  getter segr : Int16 = 2_i16

  getter fixp : String = ""

  struct Context
    getter fpath : String = ""
    getter mt_rm : String = ""

    getter pdict : String = ""
    getter wn_id : Int32 = 0

    getter vtree : String = ""
    getter zfrom : Int32 = 0

    include JSON::Serializable
  end

  getter _ctx : Context | Nil = nil

  def after_initialize
    @zstr = @zstr.gsub(/\p{C}+/, " ").strip
    @zstr = CharUtil.to_canon(@zstr, upcase: true)

    @vstr = @vstr.gsub(/\p{C}+/, " ").strip.unicode_normalize(:nfkc)
    @vstr = VietUtil.fix_tones(@vstr)

    @cpos = "X" unless MtEpos.parse?(@cpos)
    @attr = MtAttr.parse_list(@attr).to_str

    @dname = @dname.sub(':', '/')
    @plock = 0_i16 unless 0 <= @plock <= 2

    @fixp = "" if @fixp.blank? || @fixp == @cpos
  end

  getter? on_delete : Bool { @vstr.empty? && !@attr.includes?("Hide") }

  def save!(uname : String = "", privi = 4, persist : Bool = true)
    zdict = ZvDict.load!(@dname.sub("book", "wn").tr("/:", ""))

    if privi < zdict.p_min
      raise Unauthorized.new "Bạn cần quyền hạn tối thiểu là #{zdict.p_min} để thêm/sửa từ"
    end

    zterm = zdict.load_term(cpos: @cpos, zstr: @zstr)
    fresh = zterm.mtime < 0
    p_min = zdict.p_min + zterm.plock

    if @plock < p_min && privi < p_min + 1
      raise Unauthorized.new "Từ đã bị khoá, bạn cần quyền hạn tối thiểu là #{p_min + 1} để đổi khoá"
    end

    if @vstr.empty? && !@attr.includes?("Hide")
      return zdict.delete_term(zterm: zterm, persist: persist)
    end

    zterm.vstr = @vstr
    zterm.attr = @attr
    zterm.plock = @plock

    zterm.uname = uname
    zterm.mtime = TimeUtil.cv_mtime

    zterm = zterm.upsert!
    zdict.add_term(zterm, fresh: fresh, persist: true)
  end
end
