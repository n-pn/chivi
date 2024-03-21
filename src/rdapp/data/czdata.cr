require "crorm"

require "../../_util/chap_util"
require "../../_util/char_util"
require "../../_util/zstd_util"
require "../../_util/hash_util"

class RD::Czdata
  class_getter init_sql = <<-SQL
    CREATE TABLE IF NOT EXISTS czdata(
      ch_no integer NOT NULL primary key,
      title text NOT NULL DEFAULT '',
      chdiv text NOT NULL DEFAULT '',
      --
      ztext blob,
      zsize int not null default 0,
      cksum int not null default 0,
      --
      mtime int NOT NULL DEFAULT 0,
      atime int NOT NULL DEFAULT 0,
      --
      zorig text not null default '',
      zlink text not null default ''
    ) strict;
    SQL

  CZ_DIR = "/2tb/zroot/wn_db"

  @[AlwaysInline]
  def self.db_path(sname : String, sn_id : String | Int32)
    "#{CZ_DIR}/#{sname}/#{sn_id}-zdata.db3"
  end

  @[AlwaysInline]
  def self.db(sname : String, sn_id : String | Int32)
    self.db(db_path(sname, sn_id))
  end

  @[AlwaysInline]
  def self.db(db_path : String)
    Crorm::SQ3.new(db_path, &.init_db(self.init_sql))
  end

  # def self.init_db(sname : String, sn_id : String | Int32)
  #   new_db_path = self.db_path(sname, sn_id)
  #   czdata_db = self.db(new_db_path)

  #   old_db_path = new_db_path.sub(".db3", ".v1.db3")

  #   if File.file?(old_db_path)
  #     czdata_db.open_tx { |db| load_old_db(old_db_path).each(&.upsert!(db: db)) }
  #   end

  #   czdata_db
  # end

  # def self.load_old_db(old_db_path : String)
  #   items = [] of self

  #   DB.open("sqlite3:#{old_db_path}?immutable=1") do |db|
  #     query = "select ch_no, title, chdiv, mtime, zorig, s_cid, zlink, ztext from czdata"

  #     db.query_each query do |rs|
  #       items << self.new(
  #         ch_no: rs.read(Int32), title: rs.read(String), chdiv: rs.read(String),
  #         mtime: rs.read(Int64), zorig: "#{rs.read(String)}/#{rs.read(Int32)}",
  #         zlink: rs.read(String), ztext: rs.read(String)
  #       )
  #     end
  #   end

  #   items
  # end

  ###

  include Crorm::Model
  schema "czdata", :sqlite, multi: true

  field ch_no : Int32 = 0, pkey: true
  field title : String = ""
  field chdiv : String = ""

  field ztext : Bytes? = nil, json_ignore: true

  field zsize : Int32 = 0
  field cksum : Int32 = 0

  field mtime : Int64 = 0_i64
  field atime : Int64 = 0_i64

  field zorig : String = ""
  field zlink : String = ""

  def initialize(@ch_no, @title = "", @chdiv = "", @zorig = "", @zlink = "", @mtime = 0, ztext : String = "")
    self.ztext = ztext unless ztext.empty?
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "ch_no", @ch_no
      jb.field "title", @title
      jb.field "chdiv", @chdiv

      jb.field "zsize", @zsize
      jb.field "mtime", @mtime
      jb.field "uname", self.uname
      jb.field "rlink", @zlink

      # jb.field "flags", Chflag.new(@_flag).to_s
    }
  end

  def uname
    @zorig.tr("?+*", "").split('/').first
  end

  def cbody
    case input = @ztext
    in Nil then nil
    in Bytes
      dctx = Zstd::Decompress::Context.new
      String.new dctx.decompress(input)
    end
  end

  def ztext=(input : String)
    @zsize = input.size
    @cksum = HashUtil.fnv_1a(input).unsafe_as(Int32)

    cctx = Zstd::Compress::Context.new(level: 3)
    @ztext = cctx.compress(input.to_slice)
  end

  def init_by_hand(input : String)
    strio = String::Builder.new
    state = 0

    input.each_line do |line|
      line = CharUtil.trim_sanitize(line)
      next if line.empty?

      if state > 0
        strio << '\n' << line
      else
        state = 1
        @title = line
        strio << line
      end
    end

    @atime = Time.utc.to_unix
    self.ztext = strio.to_s

    self
  end

  def init_by_zlink(force : Bool = false) : Bool
    return false if !force && @zsize > 0 || @zlink.empty?

    stale = Time.utc - (force ? 2.minutes : 20.years)
    rchap = RawRmchap.from_link(@zlink, stale: stale)

    @title, lines = rchap.parse_page!

    strio = String::Builder.new(@title)
    lines.each { |line| strio << '\n' << line }

    @zorig = rchap.zorig
    @atime = @mtime = Time.utc.to_unix
    self.ztext = strio.to_s

    true
  rescue ex
    Log.error(exception: ex) { "Error loading #{@zlink}: #{ex}" }
    false
  end

  UPSERT_ZTEXT_SQL = <<-SQL
      insert into czdata(ch_no, title, chdiv, ztext, zsize, cksum, mtime, atime, zorig)
      values ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      on conflict(ch_no) do update set
        title = IIF(excluded.title = '', czdata.title, excluded.title),
        chdiv = IIF(excluded.chdiv = '', czdata.chdiv, excluded.chdiv),
        ztext = excluded.ztext,
        zsize = excluded.zsize,
        cksum = excluded.cksum,
        mtime = excluded.mtime,
        atime = excluded.atime,
        zorig = excluded.zorig
      SQL

  @[AlwaysInline]
  def save_ztext!(db)
    db.exec UPSERT_ZTEXT_SQL, @ch_no, @title, @chdiv, @ztext, @zsize, @cksum, @mtime, @atime, @zorig
  end

  UPSERT_ZINFO_SQL = <<-SQL
    insert into czdata(ch_no, title, chdiv, zorig, zlink)
    values ($1, $2, $3, $4, $5)
    on conflict(ch_no) do update set
      title = excluded.title,
      chdiv = IIF(excluded.chdiv = '', czdata.chdiv, excluded.chdiv),
      zorig = IIF(czdata.zorig = '', excluded.zorig, czdata.zorig),
      zlink = excluded.zlink
    SQL

  @[AlwaysInline]
  def save_zinfo!(db)
    db.exec UPSERT_ZINFO_SQL, @ch_no, @title, @chdiv, @zorig, @zlink
  end

  ####

  @[AlwaysInline]
  def self.load(db, ch_no : Int32)
    self.load(db, ch_no) { self.new(ch_no) }
  end

  @[AlwaysInline]
  def self.load(db, ch_no : Int32, &)
    self.find_by_id(ch_no, pkey: "ch_no", db: db) || yield
  end

  alias DBX = Crorm::SQ3 | DB::Database | DB::Connection

  GET_ALL_SQL = <<-SQL
    select ch_no, title, chdiv, zsize, mtime, zorig from czdata
    where ch_no >= $1 and ch_no <= $2
    order by ch_no asc limit $3
  SQL

  def self.get_all(db : DBX, start : Int32 = 1, limit : Int32 = 32, chmax : Int32 = 99999)
    db.query_all(GET_ALL_SQL, start, chmax, limit, as: self)
  end

  GET_TOP_SQL = <<-SQL
    select ch_no, title, chdiv, zsize, mtime, zorig from czdata
    where ch_no <= $1 order by ch_no asc limit $2
  SQL

  def self.get_top(db : DBX, start : Int32 = 99999, limit : Int32 = 4)
    db.query_all(GET_TOP_SQL, start, limit, as: self)
  end

  GET_PREV_SQL = <<-SQL
    select ch_no, title, chdiv, zsize, mtime, zorig from czdata
    where ch_no < $1 order by ch_no desc limit 1
  SQL

  def self.find_prev(db, ch_no : Int32)
    db.query_one?(GET_PREV_SQL, ch_no, as: self)
  end

  GET_NEXT_SQL = <<-SQL
    select ch_no, title, chdiv, zsize, mtime, zorig from czdata
    where ch_no > $1 order by ch_no asc limit 1
  SQL

  def self.find_next(db : DBX, ch_no : Int32)
    db.query_one?(GET_NEXT_SQL, ch_no, as: self)
  end

  @@get_last_sql = "select * from chinfos order by ch_no desc limit 1"

  def self.find_last(db : DBX)
    db.query_one?(@@get_last_sql, as: self)
  end

  WORD_COUNT_SQL = "select sum(zsize) from czdata where ch_no >= $1 and ch_no <= $2"

  def self.word_count(db : DBX, chmin : Int32, chmax : Int32)
    db.query_one(WORD_COUNT_SQL, chmin, chmax, as: Int32)
  end
end
