require "crorm/model"

class CV::Lixi2023
  class_getter db_path = "var/users/2023-lixi.db"

  class_getter init_sql = <<-SQL
    create table rolls(
      id integer primary key,
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

  field uname : String = ""
  field vcoin : Int32 = 0
  field mtime : Int64 = Time.utc.to_unix

  def initialize(@uname, @vcoin)
  end

  def self.roll_count(uname : String)
    stmt = "select count(*) from rolls where uname = $1"
    open_db(&.query_one(stmt, uname, as: Int32))
  end
end
