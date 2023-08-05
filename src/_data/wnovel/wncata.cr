require "sqlite3"

class Wncata
  DIR = "/2tb/var.chivi/wnapp/books"

  def self.db_path(wn_id : Int32, sname : String)
    "#{DIR}/#{wn_id}/#{sname}.db3"
  end

  MAP_SNAME = {
    "!biqugee.com":  "!biqugee",
    "!bxwxorg.com":  "!bxwxorg",
    "!rengshu.com":  "!rengshu",
    "!shubaow.net":  "!shubaow",
    "!duokan8.com":  "!duokan8",
    "!paoshu8.com":  "!paoshu8",
    "!chivi.app":    "!chivi",
    "!xbiquge.bz":   "!xbiquge",
    "!xbiquge.so":   "!xbiquge",
    "!hetushu.com":  "!hetushu",
    "!69shu.com":    "!69shu",
    "!nofff.com":    "!nofff",
    "!5200.tv":      "!5200_tv",
    "!zxcs.me":      "!zxcs_me",
    "!jx.la":        "!jx_la",
    "!ptwxz.com":    "!ptwxz",
    "!uukanshu.com": "!uukanshu",
    "!uuks.org":     "!uuks_org",
    "!bxwx.io":      "!bxwx_io",
    "!133txt.com":   "!133txt",
    "!biqugse.com":  "!biqugse",
    "!bqxs520.com":  "!bqxs520",
    "!yannuozw.com": "!yannuozw",
    "!kanshu8.net":  "!kanshu8",
    "!biqu5200.net": "!biqu5200",
    "!b5200.org":    "!b5200_org",
  }

  def self.new_sname(old_name : String)
    MAP_SNAME.fetch(old_name, old_sname)
  end

  def self.load(wn_id : Int32, sname : String, s_bid : Int32 | String)
    db_path = self.db_path(wn_id, sname)
    existed = File.file?(db_path)
    current = new(db_path)

    unless existed?
      old_vi_path = "var/zchap/infos/#{sname}/#{s_bid}.db"
      new_zh_path = "var/zroot/remote/#{new_sname(sname)}/#{s_bid}.db3"
      if File.file?(old_vi_path)
        current.import_old_vi_db(old_vi_path)
      elsif File.file?(new_zh_path)
        current.import_new_zh_db(new_zh_path)
      end
    end

    current
  end

  def self.load(wn_id : Int32, sname : String)
    db_path = self.db_path(wn_id, sname)
    new(db_path)
  end

  getter db_path : String

  def initialize(@db_path)
    init_db(db_path) unless File.file?(db_path)
  end

  def init_db(db_path : String)
    DB.open("sqlite3:#{db_path}") do |db|
      db.exec "pragma journal_mode=WAL"
      db.exec <<-SQL
      create table chaps(
        ch_no int primary key,

        ctitle varchar not null default '',
        subdiv varchar not null default '',

        vctitle varchar not null default '',
        vsubdiv varchar not null default '',

        chlen int not null default 0,
        xxh32 int not null default 0,
        mtime bigint not null default 0,

        _orig varchar not null
      )
      SQL
    end
  end

  def open_db(&)
    DB.open("sqlite3://#{@db_path}?synchronous=normal") { |db| yield db }
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

  def import_old_vi_db(src_db_path : String)
    open_tx do |db|
      db.exec "attach database '#{src_db_path}' as src"
      db.exec <<-SQL
        replace into chaps (ch_no, ctitle, subdiv, vctitle, vsubdiv, chlen, xxh32, mtime, _orig)
        select ch_no, title, chdiv, vtitle, vchdiv, c_len, 0 as xxh32, mtime, _path as _orig
        from src.chaps
        SQL

    rescue ex
      puts [ex.message, src_db_path]
    end
  end

  def import_old_zh_db(src_db_path : String)
    open_tx do |db|
      db.exec "attach database '#{src_db_path}' as src"

      db.exec <<-SQL
        replace into chaps (ch_no, ctitle, subdiv, vctitle, vsubdiv, chlen, xxh32, mtime, _orig)
        select ch_no, title, chdiv, "" as vtitle, "" as vchdiv, c_len, 0 as xxh32, mtime, _path as _orig
        from src.chaps
        SQL

    rescue ex
      puts [ex.message, src_db_path]
    end
  end

  def import_new_zh_db(src_db_path : String)
    open_tx do |db|
      db.exec "attach database '#{src_db_path}' as src"

      db.exec <<-SQL
        replace into chaps (ch_no, ctitle, subdiv, vctitle, vsubdiv, chlen, xxh32, mtime, _orig)
        select ch_no, ctitle, subdiv, "" as vtitle, "" as vchdiv, chlen, xxh32, mtime, '?' <> s_cid as _orig
        from src.chaps
        SQL

    rescue ex
      puts [ex.message, src_db_path]
    end
  end

  def upsert_info(ch_no : Int32, _orig : String,
                  ctitle : String, subdiv : String,
                  vctitle : String, vsubdiv : String,
                  db : DB::Database)
    db.exec <<-SQL, ch_no, _orig, ctitle, subdiv, vctitle, vsubdiv
      insert into chaps (ch_no, _orig, ctitle, subdiv, vctitle, vsubdiv)
      values ($1, $2, $3, $4, $5, $6)
      on conflict (ch_no) do update set
        _orig = excluded._orig,
        ctitle = excluded.ctitle,
        subdiv = excluded.subdiv,
        vctitle = excluded.vctitle,
        vsubdiv = excluded.vsubdiv
      SQL
  end

  def upsert_info(ch_no : Int32, s_cid : String, ctitle : String, sudbiv : String)
    open_tx { |db| upsert_info(ch_no, s_cid, ctitle, subdiv, db) }
  end

  def update_tran(ch_no : Int32, vctitle : String, vsubdiv : String,
                  db : DB::Database)
    db.exec <<-SQL, ch_no, vctitle, vsubdiv
      update chaps (vctitle, vsubdiv) values ($2, $3) where ch_no = $1
      SQL
  end

  def update_tran(ch_no : Int32, vctitle : String, vsubdiv : String)
    open_tx { |db| update_tran(ch_no, vctitle, vsubdiv, db) }
  end

  def update_stat(ch_no : Int32, chlen : Int32, xxh32 : Int32, mtime : Int64,
                  db : DB::Database)
    db.exec <<-SQL, ch_no, chlen, xxh32, mtime
      update chaps set chlen = $2, xxh32 = $3, mtime = $4 where ch_no = $1
      SQL
  end

  def update_stat(ch_no : Int32, chlen : Int32, xxh32 : Int32, mtime : Int64)
    open_tx { |db| update_stat(ch_no, chlen, xhash, mtime) }
  end
end
