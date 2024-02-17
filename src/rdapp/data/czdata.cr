require "crorm"
require "../../_util/chap_util"
require "../_raw/raw_rmchap"

class RD::Czdata
  class_getter init_sql = <<-SQL
    CREATE TABLE IF NOT EXISTS czdata(
      ch_no integer NOT NULL primary key,
      s_cid integer NOT NULL default 0,
      --
      title text NOT NULL DEFAULT '',
      chdiv text NOT NULL DEFAULT '',
      --
      ztext text NOT NULL default '',
      mtime integer NOT NULL DEFAULT 0,
      zsize integer not null default 0,
      --
      zorig text not null default '',
      zlink text not null default ''
    ) strict;
    SQL

  CZ_DIR = "/2tb/zroot/wn_db"

  @[AlwaysInline]
  def self.db_path(sname : String, sn_id : String | Int32)
    "#{CZ_DIR}/#{sname}/#{sn_id}-zdata.v1.db3"
  end

  @[AlwaysInline]
  def self.db(db_path : String)
    Crorm::SQ3.new(db_path, self.init_sql)
  end

  ###

  include Crorm::Model
  schema "czdata", :sqlite, multi: true

  field ch_no : Int32 = 0, pkey: true
  field s_cid : Int32 = 0

  field title : String = ""
  field chdiv : String = ""

  field ztext : String = ""
  field zsize : Int32 = 0
  field mtime : Int64 = 0_i64

  field zorig : String = ""
  field zlink : String = ""

  def initialize(@ch_no, @s_cid = 0, @title = "", @chdiv = "", @zlink = "", @zorig = "")
  end

  def init_by_zlink(force : Bool = false) : Bool
    return false unless (force || @zsize == 0) && !@zlink.empty?

    Log.info { @zlink.colorize.magenta }

    stale = Time.utc - (force ? 2.minutes : 20.years)
    rchap = RawRmchap.from_link(@zlink, stale: stale)

    Log.info { "loading done!" }

    @zorig = rchap.zorig
    @mtime = Time.utc.to_unix

    @title, lines = rchap.parse_page!

    strio = String::Builder.new(@title)
    zsize = @title.size

    lines.each do |line|
      strio << '\n' << line
      zsize &+= line.size &+ 1
    end

    @zsize = zsize
    @ztext = strio.to_s

    Log.info { @zsize.colorize.magenta }

    true
  rescue ex
    Log.error(exception: ex) { "Error loading #{@zlink}: #{ex}" }
    false
  end

  def set_ztext(input : String, @mtime = Time.utc.to_unix, @zorig = self.zorig)
    strio = String::Builder.new
    zsize = state = 0

    input.each_line do |line|
      line = CharUtil.normalize(line).strip
      next if line.empty?

      if state > 1
        strio << '\n' << line
        zsize &+= line.size &+ 1
      elsif state == 1 || !line.starts_with?('/')
        state = 2
        @title = line
        strio << line
        zsize &+= line.size
      else
        state = 1
        line = line.lstrip('/').lstrip(' ') if line.size > 3
        @chdiv = line unless line.empty?
      end
    end

    @zsize = zsize
    @ztext = strio.to_s

    self
  end

  UPSERT_ZTEXT_SQL = <<-SQL
    insert into czdata(ch_no, s_cid, title, chdiv, ztext, zsize, mtime, zorig)
    values ($1, $2, $3, $4, $5, $6, $7, $8)
    on conflict(ch_no) do update set
      title = IIF(excluded.title = '', czdata.title, excluded.title),
      chdiv = IIF(excluded.chdiv = '', czdata.chdiv, excluded.chdiv),
      ztext = excluded.ztext,
      zsize = excluded.zsize,
      mtime = excluded.mtime,
      zorig = excluded.zorig
    SQL

  @[AlwaysInline]
  def save_ztext!(db)
    db.exec UPSERT_ZTEXT_SQL, @ch_no, @s_cid, @title, @chdiv, @ztext, @zsize, @mtime, @zorig
  end

  UPSERT_ZINFO_SQL = <<-SQL
    insert into czdata(ch_no, s_cid, title, chdiv, zlink, zorig)
    values ($1, $2, $3, $4, $5, $6)
    on conflict(ch_no) do update set
      s_cid = excluded.s_cid,
      zlink = excluded.zlink,
      title = excluded.title,
      chdiv = IIF(excluded.chdiv = '', czdata.chdiv, excluded.chdiv),
      zorig = IIF(czdata.zorig = '', excluded.zorig, czdata.zorig)
    SQL

  @[AlwaysInline]
  def save_zinfo!(db)
    db.exec UPSERT_ZINFO_SQL, @ch_no, @s_cid, @title, @chdiv, @zlink, @zorig
  end

  FETCH_ZTEXT_SQL = "select ztext from czdata where ch_no = $1 limit 1"

  @[AlwaysInline]
  def self.get_ztext(db, ch_no : Int32)
    db.query_one?(FETCH_ZTEXT_SQL, ch_no, as: String)
  end

  @[AlwaysInline]
  def self.find_or_init(db, ch_no : Int32)
    self.find_by_id(ch_no, pkey: "ch_no", db: db) || self.new(ch_no)
  end
end
