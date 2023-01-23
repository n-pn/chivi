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
  getter body : Array(String) do
    raise "missing seed data" unless seed = @seed

    case path = self._path
    when "x" # for dead remote with no data
      [""]
    when "v" # text file saved to disk
      TextStore.read_txt_file(seed, self)
    when "z" # zip file relative for this seed # old zip store
      TextStore.read_txt_from_zip(seed, self)
    when "" # for background chap with no metadata
      return [""] unless seed.bg_seed?
      TextStore.read_txt_from_zip(seed, self)
    else # load from linked mirror
      bg_path, ch_no = path.split(':')

      # attempt to load text from temp folder
      txt_path = TextStore.gen_txt_path(bg_path)
      return TextStore.read_txt_file(txt_path) if File.file?(txt_path)

      # load text from background seed zip files
      bg_sname, bg_s_bid, bg_s_cid = bg_path.split('/')
      # FIXIME: fix texts folder, add prefixes for background seeds
      bg_sname = bg_sname[1..] if bg_sname[0].in?('!', '+') # remove bg seed prefix

      zip_path = TextStore.gen_zip_path(bg_sname, bg_s_bid.to_i, ch_no.to_i)
      TextStore.read_txt_from_zip(zip_path, bg_s_cid.to_i, self.p_len)
    end
  end

  def save_body!(input : String, seed : WnSeed = self.seed, @uname = "") : Nil
    parts, @c_len = TextSplit.split_entry(input)
    validate_body!(parts)

    @p_len = parts.size - 1
    @mtime = Time.utc.to_unix
    @title = parts.first if self.title.empty?

    @body = parts
    save_body_copy!(seed)
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

  def save_body_copy!(seed : WnSeed = self.seed) : Nil
    TextStore.save_txt_file(seed, self)
    @_path = "v"
    seed.save_chap!(self)
  end

  def on_temp_dir?
    @_path == "v"
  end
end
