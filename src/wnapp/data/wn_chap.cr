require "json"
require "./wn_seed"
require "./wntext/*"

class WN::WnChap
  include DB::Serializable

  property ch_no : Int32 # chaper index number
  property s_cid : Int32 # chapter fname in disk/remote

  property title : String = "" # chapter title
  property chdiv : String = "" # volume name

  property vtitle : String = "" # translated title
  property vchdiv : String = "" # translated volume name

  property mtime : Int64 = 0   # last modification time
  property uname : String = "" # last modified by username

  property c_len : Int32 = 0 # chars count
  property p_len : Int32 = 0 # parts count

  property _path : String = "" # file locator
  property _flag : Int32 = 0   # marking states

  # flags:
  # -2 : dead remote
  # -1 : error remote
  # 0 : default
  # 1: exists on zip
  # 2: exists as txt
  # 3: exists as txt and edited by users

  @[DB::Field(ignore: true)]
  getter! seed : WnSeed

  def initialize(@ch_no, @s_cid, @title, @chdiv = "", @_path = "")
  end

  def to_json(jb : JSON::Builder)
    # FIXME: rename json fields
    jb.object {
      jb.field "chidx", self.ch_no
      jb.field "schid", self.s_cid

      jb.field "title", self.vtitle
      jb.field "chvol", self.vchdiv

      jb.field "chars", self.c_len
      jb.field "parts", self.p_len

      jb.field "utime", self.mtime
      jb.field "uname", self.uname

      jb.field "uslug", self.uslug

      # jb.field "sname", self.sname
    }
  end

  def uslug(title = self.vtitle)
    input = title.unicode_normalize(:nfd).gsub(/[\x{0300}-\x{036f}]/, "")
    input.downcase.tr("đ", "d").split(/\W+/, remove_empty: true).first(7).join('-')
  end

  def _href(part_no : Int32 = 1)
    String.build do |io|
      io << @ch_no << '/' << self.uslug << '-'
      io << (part_no < 1 ? self.p_len : part_no) if part_no != 1
    end
  end

  INFO_FIELDS = {
    "ch_no", "s_cid",
    "title", "chdiv",
    "_path",
  }

  def info_values
    {
      @ch_no, @s_cid,
      @title, @chdiv,
      @_path,
    }
  end

  FULL_FIELDS = {
    "ch_no", "s_cid",
    "title", "chdiv",
    "mtime", "uname",
    "c_len", "p_len",
    "_path", "_flag",
  }

  def full_values
    {
      @ch_no, @s_cid,
      @title, @chdiv,
      @mtime, @uname,
      @c_len, @p_len,
      @_path, @_flag,
    }
  end

  ###

  def set_seed(@seed)
    self
  end

  @[DB::Field(ignore: true)]
  getter body : Array(String) { TextStore.get_chap(self.seed, self) || [""] }

  def save_body!(input : String, seed : WnSeed = self.seed, uname = "", _flag = 2) : Nil
    input = TextUtil.clean_spaces(input)
    lines = input.split(/\s*\R\s*/, remove_empty: true)
    save_body!(lines, seed, uname: uname, _flag: _flag)
  end

  def save_body!(lines : Array(String), seed : WnSeed = self.seed, @uname = "", _flag = 2) : Nil
    if lines.empty?
      parts = [self.title]
      @c_len = 0
    else
      parts, @c_len = TextSplit.split_entry(lines)
      raise "too many parts: #{parts.size} (max: 30)!" if parts.size > 30
    end

    @p_len = parts.size - 1
    @mtime = Time.utc.to_unix
    @title = lines.first if self.title.empty?

    @body = parts
    save_body_copy!(seed, _flag: _flag)
  end

  def save_body_copy!(seed : WnSeed = self.seed, @_flag = 2) : Nil
    txt_path = TextStore.save_txt_file(seed, self)
    TextStore.zip_one(seed.sname, seed.s_bid, txt_path)
    seed.save_chap!(self)
  end

  def on_txt_dir?
    self._flag > 1
  end
end
