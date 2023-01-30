require "crorm"

require "./wn_seed"
require "./wntext/*"

class WN::WnChap
  include Crorm::Model
  @@table = "chaps"

  field ch_no : Int32 # chaper index number
  field s_cid : Int32 # chapter fname in disk/remote

  field title : String = "" # chapter title
  field chdiv : String = "" # volume name

  field mtime : Int64 = 0   # last modification time
  field uname : String = "" # last modified by username

  field c_len : Int32 = 0 # chars count
  field p_len : Int32 = 0 # parts count

  field _path : String = "" # file locator
  field _flag : Int32 = 0   # marking states

  # flags:
  # -2 : dead remote
  # -1 : error remote
  # 0 : default
  # 1: exists on zip
  # 2: exists as txt
  # 3: exists as txt and edited by users

  @[DB::Field(ignore: true)]
  getter! seed : WnSeed

  def initialize(@ch_no, @s_cid, @title, @chdiv = "")
  end

  def to_json(jb : JSON::Builder)
    # FIXME: rename json fields
    jb.object {
      jb.field "chidx", self.ch_no
      jb.field "schid", self.s_cid

      jb.field "title", self.title
      jb.field "chvol", self.chdiv

      jb.field "chars", self.c_len
      jb.field "parts", self.p_len

      jb.field "utime", self.mtime
      jb.field "uname", self.uname

      jb.field "uslug", uslug

      # jb.field "sname", self.sname
    }
  end

  def uslug(title = self.title)
    input = title.unicode_normalize(:nfd).gsub(/[\x{0300}-\x{036f}]/, "")
    input.downcase.split(/\W+/, remove_empty: true).first(7).join('-')
  end

  def _href(part_no : Int32 = 0)
    String.build do |io|
      io << @ch_no << '/' << self.uslug
      p_len = self.p_len
      io << '/' << (part_no % p_len + 1) if part_no != 0 && p_len > 1
    end
  end

  ###

  def set_seed(@seed)
    self
  end

  @[DB::Field(ignore: true)]
  getter body : Array(String) { TextStore.get_chap(self.seed, self) || [""] }

  def save_body!(input : String, seed : WnSeed = self.seed, @uname = "", _flag = 2) : Nil
    parts, @c_len = TextSplit.split_entry(input)
    validate_body!(parts)

    @p_len = parts.size - 1
    @mtime = Time.utc.to_unix
    @title = parts.first if self.title.empty?

    @body = parts
    save_body_copy!(seed, _flag: _flag)
  end

  private def validate_body!(parts : Array(String))
    if parts.size > 31
      raise "too many parts: #{parts.size} (max: 30)!"
    end

    parts.each do |part|
      c_len = part.size
      next if c_len <= 4500
      raise "part char count exceed limit: #{c_len} (max: 4500)!"
    end
  end

  def save_body_copy!(seed : WnSeed = self.seed, @_flag = 2) : Nil
    TextStore.save_txt_file(seed, self)
    seed.save_chap!(self)
  end

  def on_txt_dir?
    self._flag > 1
  end
end
