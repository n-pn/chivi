require "sqlite3"

module CV::ZhbookInit
  class Entry
    include DB::Serializable

    property id : Int32? = nil

    property snvid : String

    property btitle : String? = nil
    property author : String? = nil

    property genres : String? = nil
    property bintro : String? = nil
    property bcover : String? = nil

    property status_str : String? = nil
    property status_int : Int32? = nil

    property update_str : String? = nil
    property update_int : Int64? = nil

    property chap_count : Int32? = nil
    property chap_total : Int32? = nil

    property last_schid : String? = nil

    property created_at : Int64? = nil
    property updated_at : Int64? = nil

    def initialize(@snvid, @btitle = "", @author = "")
    end

    def upsert!(db : DB::Database)
      cols = [] of String
      vals = [] of DB::Any

      self.created_at = Time.utc.to_unix unless id
      self.updated_at = Time.utc.to_unix

      {% for ivar in @type.instance_vars %}
          if val = @{{ivar.id}}
            cols << {{ivar.id.stringify}}
            vals << val
          end
      {% end %}

      return self if cols.empty?

      values = Array(String).new(size: cols.size, value: "?").join(", ")
      update = cols.map { |x| "#{x} = excluded.#{x}" }.join(", ")

      rs = db.exec <<-SQL, args: vals
        insert into zhbooks (#{cols.join(", ")})
        values (#{values})
        on conflict(snvid) do update set #{update};
      SQL

      self.id = rs.last_insert_id.to_i if rs.last_insert_id > 0

      self.id ||= begin
        value = db.scalar "select id from zhbooks where snvid = ?", self.snvid
        value.to_i if value.is_a?(Int)
      end

      self
    end
  end

  class Table
    DIR = "var/books/infos"

    getter sname : String
    getter db : DB::Database

    def initialize(@sname, reset = false)
      db_path = File.join(DIR, @sname + ".db")
      existed = File.exists?(db_path)
      @db = DB.open("sqlite3:#{db_path}")
      migrate_db if !existed || reset
    end

    def count
      @db.scalar "select count(*) from zhbooks"
    end

    def upsert(entry : Entry)
      entry.upsert!(@db)
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
    end
  end
end
