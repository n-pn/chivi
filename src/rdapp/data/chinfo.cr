require "crorm"
require "../../_util/chap_util"

require "./util/chflag"
require "./util/chpart"

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
  def self.db_path(dname : String)
    "var/stems/#{dname}-cinfo.db3"
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

  def inherit(zdata)
    @ztitle = zdata.title
    @zchdiv = zdata.chdiv

    @uname = zdata.uname
    @mtime = zdata.mtime
    @spath = zdata.zorig

    @cksum = ChapUtil.cksum_to_s(zdata.cksum)
    @sizes = zdata.sizes

    self
  end

  def inspect(io : IO)
    {@ch_no, @ztitle, @rlink, @zchdiv, @spath}.join(io, '\t')
  end

  def ztitle=(ztitle : String)
    vtitle = vchdiv = "" if ztitle != @ztitle
    @ztitle = ztitle
  end

  def add_flag!(flag : Chflag)
    @_flag = (Chflag.new(@_flag) | flag).to_i
  end

  def off_flag!(flag : Chflag)
    @_flag = (Chflag.new(@_flag) - flag).to_i
  end

  def sizes
    @sizes.empty? ? [0] : @sizes.split(' ').map(&.to_i)
  end

  def psize
    @sizes.count(' ')
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "ch_no", @ch_no
      jb.field "psize", self.psize

      jb.field "title", @vtitle.empty? ? @ztitle : @vtitle
      jb.field "chdiv", @vchdiv.empty? ? @zchdiv : @vchdiv

      jb.field "mtime", @mtime
      jb.field "uname", @uname

      # jb.field "flags", Chflag.new(@_flag).to_s
    }
  end

  #####

  alias DBX = Crorm::SQ3 | DB::Database | DB::Connection

  @@get_all_sql : String = @@schema.select_stmt(&.<< " where ch_no >= $1 and ch_no <= $2 order by ch_no asc limit $3")

  def self.get_all(db : DBX, start : Int32 = 1, limit : Int32 = 32, chmax : Int32 = 99999)
    db.query_all(@@get_all_sql, start, chmax, limit, as: self)
  end

  @@get_top_sql : String = @@schema.select_stmt(&.<< " where ch_no <= $1 order by ch_no desc limit $2")

  def self.get_top(db : DBX, start : Int32 = 99999, limit : Int32 = 4)
    db.query_all(@@get_top_sql, start, limit, as: self)
  end

  @@get_one_sql : String = @@schema.select_by_pkey

  def self.find(db : DBX, ch_no : Int32)
    db.query_one?(@@get_one_sql, ch_no, as: self)
  end

  @@get_prev_sql : String = @@schema.select_stmt(&.<< " where ch_no < $1 order by ch_no desc limit 1")

  def self.find_prev(db, ch_no : Int32)
    db.query_one?(@@get_prev_sql, ch_no, as: self)
  end

  @@get_next_sql : String = @@schema.select_stmt(&.<< " where ch_no > $1 order by ch_no asc limit 1")

  def self.find_next(db : DBX, ch_no : Int32)
    db.query_one?(@@get_next_sql, ch_no, as: self)
  end

  @@get_last_sql = "select * from chinfos order by ch_no desc limit 1"

  def self.find_last(db : DBX)
    db.query_one?(@@get_last_sql, as: self)
  end

  @@get_sizes_sql = "select sizes from chinfos where ch_no >= $1 and ch_no <= $2"

  def self.word_count(db : DBX, chmin : Int32, chmax : Int32)
    sizes = db.query_all(@@get_sizes_sql, chmin, chmax, as: String)
    sizes.sum(&.split(' ').sum(&.to_i))
  end

  @@get_chdiv_sql = "select zchdiv from chinfos where ch_no <= $1 order by ch_no desc limit 1"

  def self.get_chdiv(db, ch_no : Int32)
    db.query_one?(@@get_chdiv_sql, ch_no, as: String) || ""
  end

  ###

  @@upsert_zinfo_sql : String = @@schema.upsert_stmt(keep_fields: %w[rlink spath ztitle zchdiv])

  def self.upsert_zinfos!(db, clist : Array(self))
    db.open_tx do |tx|
      clist.each(&.upsert!(@@upsert_zinfo_sql, db: tx))
    end
  end

  @@update_vinfo_sql = "update #{@@schema.table} set vtitle = $1, vchdiv = $2 where ch_no = $3"

  def self.update_vinfos!(db : DBX, infos : Array(self))
    db.open_tx do |tx|
      infos.each do |cinfo|
        tx.exec(@@update_vinfo_sql, cinfo.vtitle, cinfo.vchdiv, cinfo.ch_no)
      end
    end
  end

  def self.update_vinfos!(ch_db : String, wn_id : Int32 = 0, start = 0, limit = 99999)
    res = "#{CV_ENV.m1_host}/_m1/qtran/tl_mulu?ch_db=#{ch_db}&wn_id=#{wn_id}&start=#{start}&limit=#{limit}"
    HTTP::Client.put(res, &.success?)
  end
end
