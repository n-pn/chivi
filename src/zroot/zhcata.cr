require "crorm"
require "xxhash"
require "./html_parser/raw_rmcata"

module ZR::Chroot
  extend self

  DIR = "var/zroot"

  def root_dir(sname : String)
    case sname[0]
    when '!' then "#{DIR}/remote/#{sname}"
    when '@' then "#{DIR}/member/#{sname}"
    when '~' then "#{DIR}/system/#{sname}"
    else          raise "unsuported #{sname}"
    end
  end

  def file_path(sname : String, fname : String)
    "#{root_dir(sname)}/#{fname}"
  end
end

class ZR::Chinfo
  class_getter init_sql = <<-SQL
    pragma journal_mode = WAL;

    CREATE TABLE IF NOT EXISTS chinfos(
      ch_no int not null PRIMARY KEY,
      ---
      rpath text NOT NULL DEFAULT '',
      s_cid text NOT NULL DEFAULT '',
      --
      title text NOT NULL DEFAULT '',
      chdiv text NOT NULL DEFAULT ''
    );
    SQL

  def self.db_path(sname : String, sn_id : String)
    "#{Chroot.root_dir(sname)}/#{sn_id}-zinfo.db3"
  end

  ###

  include Crorm::Model
  schema "chinfos", :sqlite

  field ch_no : Int32, pkey: true

  field rpath : String = "" # relative or absolute remote path
  field s_cid : String = "" # remote chapter id extracted from rpath

  field title : String = "" # chapter title name
  field chdiv : String = "" # chapter subdivision (volume) name

  def initialize(@ch_no)
  end
end

class ZR::Chstat
  class_getter init_sql = <<-SQL
    pragma journal_mode = WAL;

    CREATE TABLE IF NOT EXISTS chstats(
      ch_no int not null PRIMARY KEY,
      ---
      fhash text NOT NULL DEFAULT '',
      sizes text NOT NULL DEFAULT '',
      --
      mtime bigint NOT NULL DEFAULT 0,
      uname text not null default ''
    );
    SQL

  def self.db_path(sname : String, sn_id : String)
    "#{Chroot.root_dir(sname)}/#{sn_id}-zstat.db3"
  end

  ###

  include Crorm::Model
  schema "chstats", :sqlite

  field ch_no : Int32, pkey: true

  field fhash : String = "" # raw text file will be stored as "#{ch_no}_#{cpart}-#{fhash}.txt"
  field sizes : String = "" # char_count of for title + each part joined by a single ' '

  field mtime : Int64 = 0_i64 # last modified at, optional
  field uname : String = ""   # last modified by, optional

  def initialize(@ch_no)
  end

  def initialize(@ch_no, ctext : String, @mtime : Int64, @uname = "")
    @fhash = self.class.make_hash(ctext)
    @sizes = ctext.split("\n\n").map(&.size).join(' ')
  end

  def self.make_hash(input : String)
    # NOTE: this is actually not cover the whole range of UInt32, as it can
    # only represent 32 ** 6 = 1073741824 integers
    # but as the chapter count for each novel is as most 10000
    # it does not matter much
    # if we use 7 characters then there will be chance when it overflow the UInt32
    # limit when we convert this back to integer for fast comparision,
    # so it is not worth it to add an extra character

    xxh32 = XXHash.xxh32(input)

    String.build do |io|
      6.times do
        digit = xxh32 % 32
        io << (digit < 10 ? '0' : 'W') + digit
        xxh32 //= 32
      end
    end
  end
end

class ZR::Chrlog
  class_getter init_sql = <<-SQL
    pragma journal_mode = WAL;

    CREATE TABLE IF NOT EXISTS chrlogs(
      chap_count int NOT NULL DEFAULT 0,
      latest_cid text NOT NULL DEFAULT '',
      ---
      status_str text NOT NULL DEFAULT '',
      update_str text NOT NULL DEFAULT '',
      ---
      rtime bigint NOT NULL DEFAULT 0,
      uname text NOT NULL DEFAULT ''
    );
    SQL

  def self.db_path(sname : String, sn_id : String)
    "#{Chroot.root_dir(sname)}/#{sn_id}-rlogs.db3"
  end

  ###

  include Crorm::Model
  schema "chrlogs", :sqlite

  field chap_count : Int32 = 0
  field latest_cid : String = ""

  field status_str : String = ""
  field update_str : String = ""

  field rtime : Int64 = Time.utc.to_unix
  field uname : String = ""
end

class ZR::Zhcata
  ###

  getter conf : Rmconf

  getter idx_path : String
  getter zip_path : String
  getter tmp_path : String

  def initialize(@sname : String, @sn_id : String)
    @conf = Rmconf.load!(@sname)

    @idx_path = self.class.file_path(sname, sn_id, ".dbl")
    @zip_path = self.class.file_path(sname, sn_id, ".zip")
    @tmp_path = self.class.file_path(sname, sn_id, "/")

    return if File.file?(@idx_path)

    # Dir.mkdir_p(@conf.book_save_dir)
    # Dir.mkdir_p(@conf.chap_save_dir(sn_id))
    # Dir.mkdir_p(File.dirname(@tmp_path))

    init_db(@idx_path)
  end

  def init_db(db_path : String)
    DB.open("sqlite3:#{db_path}") do |db|
      script = {{ read_file("#{__DIR__}/bgcata.sql") }}
      script.split(';').each { |sql| db.exec(sql) unless sql.strip.empty? }
    end
  end

  def open_db(&)
    DB.open("sqlite3://#{@idx_path}?synchronous=normal") { |db| yield db }
  end

  def open_tx(&)
    open_db do |db|
      db.exec "begin"
      output = yield db
      db.exec "commit"
      output
    rescue ex
      db.exec "rollback"
      Log.error(exception: ex) { ex.message }
    end
  end

  def import_old_zh_db(src_db_path : String)
    db.exec "attach database '#{src_db_path}' as src"

    db.exec <<-SQL
      replace into chaps (ch_no, s_cid, cpath, ctitle, subdiv, chlen, xhash, mtime)
      select ch_no, s_cid as text, '' as cpath, title, chdiv, c_len, 0 as xhash, mtime
      from src.chaps
      SQL
  end

  def import_new_zh_db(src_db_path : String)
    db.exec "attach database '#{src_db_path}' as src"

    db.exec <<-SQL
      replace into chaps (ch_no, rpath, title, chdiv, xhash, sizes, mtime)
      select ch_no, s_cid, ctitle, subdiv, '' as xhash, '' as sizes, mtime
      from src.chaps
      SQL

    db.exec <<-SQL
      replace into rlogs (chap_count, latest_cid, status_str, update_str, uname, rtime)
      select total_chap, latest_cid, status_str, update_str, uname, rtime
      from src.rlogs
      SQL
  end

  ###

  def make_rpath(chap : RawRmcata::Chap)
    # TODO: detect
    chap.s_cid
  end

  def reload!(stale : Time = Time.utc - 1.days, uname : String = "") : Rlog?
    parser = RawRmcata.new(@conf, @sn_id, stale: stale)

    open_tx do |db|
      chap_list = parser.chap_list

      chap_list.each do |chap|
        upsert_info!(
          db: db, ch_no: chap.ch_no,

          s_cid: chap.s_cid, cpath: chap.cpath,
          ctitle: chap.ctitle, subdiv: chap.subdiv,
        )
      end

      insert_rlog!(
        db: db,
        chap_count: chap_list.size, latest_cid: chap_list.last.s_cid,
        status_str: parser.status_str, update_str: parser.update_str,
        uname: uname, rtime: Time.utc.to_unix
      )
    end
  end

  def insert_rlog!(db : DB::Database,
                   chap_count : Int32, latest_cid : String,
                   status_str : String, update_str : String,
                   uname = "", rtime = Time.utc.to_unix)
    stmt = <<-SQL
      insert into rlogs (chap_count, latest_cid, status_str, update_str, uname, rtime)
      values ($1, $2, $3, $4, $5, $6)
      returning *
      SQL

    db.query_one(stmt, chap_count, latest_cid, status_str, update_str, uname, rtime, as: Rlog)
  end

  def upsert_info!(db : DB::Database, ch_no : Int32,
                   s_cid : String, cpath : String,
                   ctitle : String, subdiv : String)
    stmt = <<-SQL
      insert into chaps (ch_no, s_cid, cpath, ctitle, subdiv)
      values ($1, $2, $3, $4, $5)
      on conflict (ch_no) do update set
        s_cid = excluded.s_cid, cpath = excluded.cpath,
        ctitle = excluded.ctitle, subdiv = excluded.subdiv
      SQL

    db.exec(stmt, ch_no, s_cid, cpath, ctitle, subdiv)
  end

  def upsert_info!(ch_no : Int32,
                   s_cid : String, cpath : String,
                   ctitle : String, sudbiv : String)
    open_tx { |db| upsert_info!(db, ch_no, s_cid, cpath, ctitle, subdiv) }
  end

  def update_stat!(db : DB::Database,
                   ch_no : Int32, chlen : Int32,
                   xhash : Int32, mtime : Int64)
    stmt = <<-SQL
      update chaps set chlen = $2, xhash = $3, mtime = $4
      where ch_no = $1
      SQL
    db.exec(stmt, ch_no, chlen, xxh32, mtime)
  end

  def update_stat!(ch_no : Int32, chlen : Int32, xxh32 : Int32, mtime : Int64)
    open_tx { |db| update_stat!(db, ch_no, chlen, xhash, mtime) }
  end
end
