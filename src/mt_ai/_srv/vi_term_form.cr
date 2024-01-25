require "json"

require "../data/pg_dict"

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

  def init_pg_term(dict : PgDict, uname : String)
    term = PgDefn.init(d_id: dict.d_id, cpos: @cpos, zstr: @zstr)

    unless self.on_delete?
      term.vstr = @vstr
      term.attr = @attr
      term.plock = @plock

      term.uname = uname
      term.mtime = TimeUtil.cv_mtime
    end

    term
  end

  def save!(uname : String = "", privi = 4, persist : Bool = true)
    zdict = PgDict.load!(@dname.sub("book", "wn").tr("/:", ""))
    zterm = init_pg_term(zdict, uname)
    p_min = zdict.p_min + zterm.plock

    if privi < p_min
      raise Unauthorized.new "Bạn cần quyền hạn tối thiểu là #{p_min} để thêm/sửa từ"
    end

    fresh = zterm.mtime < 0

    if self.on_delete?
      PgDefn.delete(zdict.d_id, ipos: zterm.ipos, zstr: zterm.zstr)
      TrieDict.delete_term(@dname, zstr: zstr, epos: zterm.ipos)

      spawn SqDefn.delete(zdict.d_id, zterm.ipos, zterm.zstr)
      spawn zdict.delete_term(zterm: zterm, fresh: fresh, persist: persist)
    else
      zterm = zterm.upsert!
      # TrieDict.add_term(@dname, zterm)

      spawn SqDefn.new(zterm).save!
      spawn zdict.add_term(zterm, fresh: fresh, persist: persist)
    end
  end
end
