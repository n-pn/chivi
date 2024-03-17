require "crorm"

class SP::ZvName
  class_getter db_path = "var/mtdic/zv_names.db3"

  class_getter init_sql = <<-SQL
    CREATE TABLE IF NOT EXISTS zvnames (
      zstr text not null,
      vstr text not null,
      _src text not null default '',
      primary key(zstr, vstr)
    ) strict, without rowid;
    SQL

  include Crorm::Model
  schema "zvnames", :sqlite, strict: false

  field zstr : String, pkey: true
  field vstr : String, pkey: true
  field _src : String = ""

  def initialize(@zstr, @vstr = "", @_src = "")
  end

  def save!(db = self.class.db)
    db.exec <<-SQL, zstr, vstr, _src
    insert into zvnames(zstr, vstr, _src) values ($1, $2, $3)
    on conflict(zstr, vstr) do update set
      _src = IIF(zvnames._src = '', excluded._src, zvnames._src || ',' || excluded._src)
    SQL
  end

  def self.get_names(zstr : String)
    self.db.open_ro(&.query_all("select vstr from zvnames where zstr = $1", zstr, as: String))
  end
end
