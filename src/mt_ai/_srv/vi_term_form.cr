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

  def prev_term
    ViTerm.find(dict: @dname, zstr: @zstr, cpos: @cpos)
  end

  def save_to_disk!(uname : String,
                    mtime = TimeUtil.cv_mtime,
                    on_create : Bool = true) : Nil
    dname = @dname.sub("book", "wn").tr("/:", "")
    zvdict = ZvDict.load!(dname)

    if on_delete?
      zvdict.delete_term(self)
    else
      zvdict.add_term(self, uname)
    end

    spawn do
      db_path = ViTerm.db_path(@dname, "tsv")

      File.open(db_path, "a") do |file|
        file << '\n'
        {@zstr, @cpos, @vstr, @attr, uname, mtime, @plock}.join(file, '\t')
      end
    end

    if on_delete?
      ViTerm.delete(dict: @dname, zstr: @zstr, cpos: @cpos)
    else
      ViTerm.new(
        zstr: @zstr, cpos: @cpos,
        vstr: @vstr, attr: @attr,
        uname: uname, mtime: mtime,
        plock: @plock
      ).upsert!(db: ViTerm.db(@dname))
    end
  end

  def sync_with_dict!
    return unless mt_dict = MtDict.get?(@dname)
    epos = MtEpos.parse(@cpos)

    if self.on_delete?
      mt_dict.del(zstr, epos)
    else
      attr = MtAttr.parse_list(@attr)
      dnum = MtDnum.from(dtype: mt_dict.type, plock: @plock.to_i8)

      mt_term = MtTerm.new(vstr: @vstr, attr: attr, dnum: dnum)
      mt_dict.add(zstr, epos: epos, term: mt_term)
    end
  end
end
