require "crorm"

class ZH::NvSeed
  include Crorm::Model
  self.table = "books"

  column s_bid : Int32
  column bhash : String = ""

  column btitle : String = ""
  column author : String = ""

  column genres : String = ""
  column bcover : String = ""

  column status : Int32 = 0
  column update : Int64 = 0_i64

  column last_s_cid : Int32 = 0 # last chap origin id
  column chap_total : Int32 = 0 # total chapter/max chapter ch_no
  column chap_avail : Int32 = 0 # total chapters cached in disks

  column btime : Int64 = 0_i64 # birth time
  column mtime : Int64 = 0_i64 # modification time
  column ctime : Int64 = 0_i64 # crawl time

  def initialize(@s_bid, @btitle = "", @author = "")
  end

  #####

  DB_PATH = "var/books/seeds/%{sname}.db"

  def self.open_db(db_path : String)
    db = DB.open("sqlite3://./#{db_path}")
    yield db
    db.close
  end

  def self.init_db(db_path : String)
    open_db do |db|
      db.exec <<-SQL
        create table if not exists books (
          s_bid integer primary key,
          bhash varchar not null default "",

          author varchar not null default "",
          btitle varchar not null default "",

          genres varchar not null default "",
          bcover varchar not null default "",

          "status" integer not null default 0,
          "update" integer not null default 0,

          chap_count integer not null default 0,
          chap_total integer not null default 0,

          last_schid integer not null default 0,

          created_at integer not null default 0,
          updated_at integer not null default 0
        );

        create index identify_idx on books (bhash);
        create index author_idx on books (author);
        create index btitle_idx on books (btitle);
        create index update_idx on books (update, status);
      SQL
    end
  end
end
