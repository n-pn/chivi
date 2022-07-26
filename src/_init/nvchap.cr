require "sqlite3"
require "./utils/crorm"
require "../_util/text_util"

module CV
  class Chinfo
    include Crorm::Model

    column chidx : Int32
    column schid : String

    column title_zh : String = ""
    column chvol_zh : String = ""

    column title_cv : String = ""
    column chvol_cv : String = ""

    column title_vi : String = ""
    column chvol_vi : String = ""

    column url_slug : String = ""

    column utime : Int64 = 0
    column chars : Int32 = 0
    column parts : Int32 = 0
    column uname : String = ""

    column o_sname : String = ""
    column o_snvid : String = ""
    column o_chidx : Int32 = 0

    column created_at : Int64
    column updated_at : Int64

    def initialize(chidx : Int32, schid : String = chidx.to_s)
      self.chidx = chidx
      self.schid = schid
    end

    def initialize(chidx : Int32, schid : String, title : String, chvol : String = "")
      self.chidx = chidx
      self.schid = schid
      set_title!(title, chvol)
    end

    def set_title!(title : String, chvol : String = "")
      @title_zh, @chvol_zh = TextUtil.format_title(title, chvol)
    end
  end

  class Chrepo < Crorm::Repo(Chinfo)
    DIR = "var/chtexts"

    getter sname : String
    getter snvid : String

    def initialize(@sname, @snvid)
      db_path = File.join(DIR, sname, snvid, "chaps.db")
      existed = File.exists?(db_path)

      super(db_path, "chinfos")
      migrate_db if !existed
    end

    private def migrate_db
      db.exec "drop table if exists chinfos;"

      db.exec <<-SQL
      create table chinfos (
        chidx integer primary key,
        schid text not null,

        title_zh text default "" not null,
        chvol_zh text default "" not null,

        title_cv text default "" not null,
        chvol_cv text default "" not null,

        title_vi text default "" not null,
        chvol_vi text default "" not null,

        url_slug text default "" not null,

        utime bigint default 0 not null,
        chars int default 0 not null,
        parts int default 0 not null,
        uname text default "" not null,

        o_sname text default "" not null,
        o_snvid text default "" not null,
        o_chidx int default 0 not null,

        created_at bigint default 0 not null,
        updated_at bigint default 0 not null
      );
      SQL

      db.exec "create index schid_idx on chinfos(schid)"
    end
  end
end
