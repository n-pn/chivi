require "json"
require "sqlite3"
require "../remote/rmcata"

class Bgcata
  class Chap
    include DB::Serializable

    property ch_no : Int32
    property s_cid = ""
    property cpath = ""

    property ctitle = ""
    property subdiv = ""

    property chlen = 0
    property xxh32 = 0
    property mtime = 0_i64

    def initialize(@ch_no)
    end
  end

  class Rlog
    include JSON::Serializable

    include DB::Serializable
    # include DB::Serializable::NonStrict

    property total_chap = 0
    property latest_cid = ""

    property status_str = ""
    property update_str = ""

    property uname = ""
    property rtime = Time.utc.to_unix
  end

  ###

  OUT = "/2tb/var.chivi/zchap"

  def self.file_path(sname : String, s_bid : String, type = ".db3")
    case sname[0]
    when '!' then "#{OUT}/globs/#{sname}/#{s_bid}#{type}"
    when '+' then "#{OUT}/users/#{sname}/#{s_bid}#{type}"
    else          raise "to be unsupported sname: #{sname}"
    end
  end

  ###

  getter conf : Rmconf

  getter idx_path : String
  getter zip_path : String
  getter tmp_path : String

  def initialize(@sname : String, @s_bid : String)
    @conf = Rmconf.load!(@sname)

    @idx_path = self.class.file_path(sname, s_bid, ".db3")
    @zip_path = self.class.file_path(sname, s_bid, ".zip")
    @tmp_path = self.class.file_path(sname, s_bid, "/")

    return if File.file?(@idx_path)

    # Dir.mkdir_p(@conf.book_save_dir)
    # Dir.mkdir_p(@conf.chap_save_dir(s_bid))
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
      replace into chaps (ch_no, s_cid, cpath, ctitle, subdiv, chlen, xxh32, mtime)
      select ch_no, s_cid as varchar, '' as cpath, title, chdiv, c_len, 0 as xxh32, mtime
      from src.chaps
      SQL
  end

  ###

  def reload!(stale : Time = Time.utc - 1.days, uname : String = "") : Rlog?
    parser = Rmcata.new(@conf, @s_bid, stale: stale)

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
        total_chap: chap_list.size, latest_cid: chap_list.last.s_cid,
        status_str: parser.status_str, update_str: parser.update_str,
        uname: uname, rtime: Time.utc.to_unix
      )
    end
  end

  def insert_rlog!(db : DB::Database,
                   total_chap : Int32, latest_cid : String,
                   status_str : String, update_str : String,
                   uname = "", rtime = Time.utc.to_unix)
    stmt = <<-SQL
      insert into rlogs (total_chap, latest_cid, status_str, update_str, uname, rtime)
      values ($1, $2, $3, $4, $5, $6)
      returning *
      SQL

    db.query_one(stmt, total_chap, latest_cid, status_str, update_str, uname, rtime, as: Rlog)
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
                   xxh32 : Int32, mtime : Int64)
    stmt = <<-SQL
      update chaps set chlen = $2, xxh32 = $3, mtime = $4
      where ch_no = $1
      SQL
    db.exec(stmt, ch_no, chlen, xxh32, mtime)
  end

  def update_stat!(ch_no : Int32, chlen : Int32, xxh32 : Int32, mtime : Int64)
    open_tx { |db| update_stat!(db, ch_no, chlen, xhash, mtime) }
  end
end
