require "sqlite3"
require "./rmcata"

class Zhcata
  OUT = "/2tb/var.chivi/zchap"

  def self.file_path(sname : String, s_bid : String, type = "db3")
    case sname[0]
    when '!' then "#{OUT}/globs/#{sname}/#{s_bid}.#{ext}"
    when '+' then "#{OUT}/users/#{sname}/#{s_bid}.#{ext}"
    else          raise "to be unsupported sname: #{sname}"
    end
  end

  @idx_path : String
  @zip_path : String
  @tmp_path : String

  def initialize(@sname : String, @s_bid : String)
    @conf = Rmconf.load_known!(@sname)

    @idx_path = self.class.file_path(sname, s_bid, "db3")
    @zip_path = self.class.file_path(sname, s_bid, "zip")
    @tmp_path = self.class.file_path(sname, s_bid, "/")

    init_db(@idx_path) unless File.file?(@idx_path)
  end

  def init_db(db_path : String)
    DB.open("sqlite3:#{db_path}") do |db|
      db.exec "pragma journal_mode=WAL"

      db.exec <<-SQL
        create table if not exists chaps(
          ch_no int primary key,
          s_cid varchar not null,

          ctitle varchar not null default '',
          subdiv varchar not null default '',

          chlen int not null default 0,
          xxh32 int not null default 0,
          mtime bigint not null default 0
        )
        SQL

      db.exec <<-SQL
        create table if not exists bumps(
          id int primary key,

          total_chap int not null default 0,
          latest_cid varchar not null default '',

          status_str varchar not null default '',
          update_str varchar not null default '',

          uname varchar not null default '',
          rtime bigint not null default 0
        );
        SQL
    end
  end

  def open_db(&)
    DB.open("sqlite3://#{@idx_path}?synchronous=normal") { |db| yield db }
  end

  def open_tx(&)
    open_db do |db|
      db.exec "begin"
      yield db
      db.exec "commit"
    rescue ex
      db.exec "rollback"
      Log.error(exception: ex) { ex.message }
    end
  end

  def remote_update!(stale : Time = Time.utc - 1.days, uname : String = "")
    href = @conf.make_cata_path(@s_bid)
    path = @conf.cata_file_path(@s_bid)

    case conf.seedtype
    when 0, 1, 2
      html = Rmseed.new(conf).read_page(cata_href, save_path, stale: stale)
    end

    # parser = Rmcata.init(@sname, @s_bid, stale: stale)
  end

  def import_from(src_db_path : String)
    db.exec "attach database '#{src_db_path}' as src"
    db.exec <<-SQL
      replace into chaps (ch_no, s_cid, ctitle, subdiv, chlen, xxh32, mtime)
      select ch_no, s_cid as varchar, title, chdiv, c_len, 0 as xxh32, mtime
      from src.chaps
      SQL
  end

  def upsert_info(ch_no : Int32, s_cid : String, ctitle : String, subdiv : String,
                  db : DB::Database)
    db.exec <<-SQL, ch_no, s_cid, ctitle, subdiv
      insert into chaps (ch_no, s_cid, ctitle, subdiv)
      values ($1, $2, $3, $4)
      on conflict (ch_no) do update set
        s_cid = excluded.s_cid, ctitle = excluded.ctitle, subdiv = excluded.subdiv
      SQL
  end

  def upsert_info(ch_no : Int32, s_cid : String, ctitle : String, sudbiv : String)
    open_tx { |db| upsert_info(ch_no, s_cid, ctitle, subdiv, db: db) }
  end

  def update_stat(ch_no : Int32, chlen : Int32, xxh32 : Int32, mtime : Int64,
                  db : DB::Database)
    db.exec <<-SQL, ch_no, chlen, xxh32, mtime
      update chaps set chlen = $2, xxh32 = $3, mtime = $4
      where ch_no = $1
      SQL
  end

  def update_stat(ch_no : Int32, chlen : Int32, xxh32 : Int32, mtime : Int64)
    open_tx { |db| update_stat(ch_no, chlen, xhash, mtime) }
  end
end
