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

  getter old_cpos : String = ""

  struct Context
    getter wn_id : Int32
    getter vtree : String
    getter zfrom : Int32
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
    @plock = 1 unless 0 <= @plock <= 2

    @old_cpos = @cpos if @old_cpos.blank?
  end

  getter? on_delete : Bool { @vstr.empty? && !@attr.includes?("Hide") }

  def prev_term
    ViTerm.find(dict: @dname, zstr: @zstr, cpos: @old_cpos)
  end

  def save_to_disk!(uname : String, mtime = ViTerm.mtime, on_create : Bool = true) : Nil
    on_delete = @vstr.empty? && !@attr.includes?("Hide")

    spawn do
      if self.on_delete?
        ViDict.bump_stats!(@dname, mtime, -1) unless on_create
      elsif on_create
        ViDict.bump_stats!(@dname, mtime, 1)
      end
    end

    spawn do
      db_path = ViTerm.db_path(@dname, "tsv")

      File.open(db_path, "a") do |file|
        file << '\n'
        {@zstr, @cpos, @vstr, @attr, uname, mtime, @plock}.join(file, '\t')
      end
    end

    if on_delete
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
