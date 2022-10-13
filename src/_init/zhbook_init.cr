require "crorm"

module CV::ZhbookInit
  class Entry
    include Crorm::Model

    column id : Int32

    column snvid : String

    column btitle : String = ""
    column author : String = ""

    column genres : String = ""
    column bintro : String = ""
    column bcover : String = ""

    column status_str : String = ""
    column status_int : Int32 = 0

    column update_str : String = ""
    column update_int : Int64 = 0_i64

    column chap_count : Int32 = 0
    column chap_total : Int32 = 0

    column last_schid : String = ""

    column created_at : Int64
    column updated_at : Int64

    def initialize(snvid, btitle = "", author = "")
      self.snvid = snvid
      self.btitle = btitle
      self.author = author
    end

    def on_db?
      @id.defined?
    end
  end

  class Table < Crorm::Repo(Entry)
    DIR = "var/books/infos"

    getter sname : String

    def initialize(@sname, reset = false)
      db_path = File.join(DIR, @sname + ".db")
      existed = File.exists?(db_path)

      super(db_path, "zhbooks")
      migrate_db if !existed || reset
    end

    def upsert(entry : Entry)
      changes = entry.changes(on_create: !entry.on_db?)
      upsert(changes, conflict: "snvid")
    end

    private def migrate_db
      db.exec "drop table if exists zhbooks;"

      db.exec <<-SQL
      create table zhbooks (
        id integer primary key,

        snvid text not null unique,

        btitle text default "" not null,
        author text default "" not null,

        genres text default "" not null,
        bintro text default "" not null,
        bcover text default "" not null,

        status_str text default "" not null,
        status_int int default 0 not null,

        update_str text default "" not null,
        update_int bigint default 0 not null,

        chap_count int default 0 not null,
        chap_total int default 0 not null,

        last_schid text default "" not null,

        created_at bigint default 0 not null,
        updated_at bigint default 0 not null
      );
      SQL

      db.exec "create index author_idx on zhbooks (author)"
      db.exec "create index btitle_idx on zhbooks (btitle)"
      db.exec "create index update_idx on zhbooks (updated_at)"
    end
  end
end
