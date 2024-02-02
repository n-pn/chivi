require "crorm"

class CV::LixiTet24
  class_getter db_path = "var/users/lixi-tet-24.db3"

  class_getter init_sql = <<-SQL
    create table rolls(
      id integer primary key,
      vu_id integer not null,
      uname varchar not null,
      vcoin integer not null,
      mtime integer not null
    );

    create index user_idx on rolls (uname);
    create index best_idx on rolls (vcoin);
    SQL

  ###

  include Crorm::Model
  schema "rolls", :sqlite

  field id : Int32, pkey: true, auto: true

  field vu_id : Int32 = 0
  field uname : String = ""
  field vcoin : Int32 = 0
  field mtime : Int64 = Time.utc.to_unix

  def initialize(@vu_id, @uname, @vcoin)
  end

  def self.roll_count(uname : String)
    stmt = "select count(*) from rolls where uname = $1"
    open_db(&.query_one(stmt, uname, as: Int32))
  end
end
