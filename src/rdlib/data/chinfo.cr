require "crorm"
require "../../_util/chap_util"
require "./chdata"

class RD::Chinfo
  class_getter init_sql = <<-SQL
    CREATE TABLE IF NOT EXISTS chinfos(
      ch_no int not null PRIMARY KEY,
      --
      ztitle text NOT NULL DEFAULT '',
      vtitle text NOT NULL DEFAULT '',
      --
      zchdiv text NOT NULL DEFAULT '',
      vchdiv text NOT NULL DEFAULT '',
      --
      spath text NOT NULL DEFAULT '',
      rlink text NOT NULL DEFAULT '',
      --
      cksum text NOT NULL DEFAULT '',
      sizes text NOT NULL DEFAULT '',
      --
      mtime bigint NOT NULL DEFAULT 0,
      uname text NOT NULL default '',
      --
      _flag int NOT NULL default 0
    );
    SQL

  @[AlwaysInline]
  def self.db_path(sname : String, sn_id : String | Int32, type : Rdtype)
    type.db3_path("#{sname}/#{sn_id}")
  end

  ###

  include Crorm::Model
  schema "chinfos", :sqlite, multi: true

  field ch_no : Int32, pkey: true

  field rlink : String = "" # relative or absolute remote link
  field spath : String = "" # sname/sn_id/sc_id format for tracking

  field ztitle : String = "" # chapter zh title name
  field zchdiv : String = "" # chapter zh division (volume) name

  field vtitle : String = "" # chapter vi title name
  field vchdiv : String = "" # chapter vi division (volume) name

  field cksum : String = "" # check sum of raw chapter text
  field sizes : String = "" # char_count of for title + each part joined by a single ' '

  field mtime : Int64 = 0_i64 # last modified at, optional
  field uname : String = ""   # last modified by, optional

  field _flag : Int32 = 0

  def initialize(@ch_no)
  end

  def initialize(@ch_no, @rlink, @spath, @ztitle, @zchdiv)
  end

  def ztitle=(ztitle : String)
    vtitle = vchdiv = "" if ztitle != @ztitle
    @ztitle = ztitle
  end

  def save_raw_text!(lines : Array(String), @spath = self.spath,
                     @uname = "", @mtime = Time.utc.to_unix,
                     ftype : Rdtype = :nc)
    title = lines.shift
    self.ztitle = title # TODO: update zchdiv

    parts, sizes, cksum = ChapUtil.split_rawtxt(lines: lines, title: title)
    @cksum = ChapUtil.cksum_to_s(cksum)
    @sizes = sizes.join(' ')

    parts.each_with_index do |ptext, p_idx|
      cdata = Chdata.new("#{@spath}-#{@cksum}-#{p_idx}", ftype)
      cdata.save_raw!(ptext, p_idx > 0 ? title : nil)
    end

    @cksum
  end

  def load_all_raw!(spath : String = @spath, ftype : Rdtype = :nc)
    return "" if @cksum.empty?

    String.build do |io|
      1.upto(self.psize) do |p_idx|
        lines = Chdata.read_raw(self.part_path(p_idx), ftype)
        lines.shift
        lines.each { |line| io << line << '\n' }
      end
    end
  end

  def part_name(ftype : Rdtype, p_idx : Int32 = 1)
    @cksum.empty? ? "" : "#{ftype.to_s.lowercase}:#{part_path(p_idx)}"
  end

  def part_path(p_idx : Int32 = 1)
    "#{@spath}-#{@cksum}-#{p_idx}"
  end

  ####

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "ch_no", @ch_no

      jb.field "title", @vtitle.empty? ? @ztitle : @vtitle
      jb.field "chdiv", @vchdiv.empty? ? @zchdiv : @vchdiv

      jb.field "psize", self.psize
      jb.field "mtime", @mtime
      # jb.field "flags", Chflag.new(@_flag).to_s
    }
  end

  def sizes
    @sizes.empty? ? [0] : @sizes.split(' ').map(&.to_i)
  end

  def psize
    @sizes.count(' ')
  end

  def add_flag!(flag : Chflag)
    @_flag = (Chflag.new(@_flag) | flag).to_i
  end

  def off_flag!(flag : Chflag)
    @_flag = (Chflag.new(@_flag) - flag).to_i
  end
end
