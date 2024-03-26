require "crorm"

# require "../base/*"

class MT::SpWseg
  class_getter init_sql = <<-SQL
    create table zh_wseg(
      d_id int not null,
      zstr text not null,

      rank int not null default 0,
      seps text,

      primary key (d_id, zstr)
    ) strict, without rowid;
    SQL

  class_getter db_path = "/srv/chivi/mt_db/zh_wseg.db3"

  ###

  include Crorm::Model
  schema "zh_wseg", :sqlite

  field d_id : Int32, pkey: true
  field zstr : String, pkey: true

  field rank : Int32 = 0
  field seps : String? = nil

  def initialize(@d_id, @zstr, @rank = 0, @seps = nil)
  end

  ###

  DELETE_SQL = <<-SQL
    delete from #{@@schema.table}
    where d_id = $1 and zstr = $2
    SQL

  def delete!
    @@db.exec DELETE_SQL, @d_id, @zstr
  end
end
