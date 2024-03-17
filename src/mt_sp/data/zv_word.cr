require "crorm"

class SP::ZvWord
  class_getter db_path = "var/mtdic/zv_words.db3"

  class_getter init_sql = <<-SQL
    CREATE TABLE IF NOT EXISTS zv_words (
      zstr text not null,
      vstr text not null,
      _src text not null default '',
      primary key(zstr, vstr)
    ) strict, without rowid;
    SQL

  include Crorm::Model
  schema "zv_words", :sqlite, strict: false

  field zstr : String, pkey: true
  field vstr : String, pkey: true
  field _src : String = ""

  def initialize(@zstr, @vstr = "", @_src = "")
  end

  def save!(db = self.class.db)
    db.exec <<-SQL, zstr, vstr, _src
    insert into zv_words(zstr, vstr, _src) values ($1, $2, $3)
    on conflict(zstr, vstr) do update set
      _src = IIF(zv_words._src = '', excluded._src, zv_words._src || ',' || excluded._src)
    SQL
  end

  def self.get_trans(zstr : String)
    self.db.open_ro(&.query_all("select vstr from zv_words where zstr = $1", zstr, as: String))
  end
end
