require "crorm"
require "crorm/sqlite3"

class CV::Lixi2023
  include Crorm::Model
  @@table = "rolls"

  field id : Int32, primary: true

  field uname : String
  field vcoin : Int32
  field mtime : Int64 = Time.utc.to_unix

  class_getter repo = Crorm::Sqlite3::Repo.new(db_path, init_sql)

  def initialize(@uname, @vcoin)
  end

  def self.roll_count(uname : String)
    @@repo.open_db do |db|
      db.query_one("select count(*) from rolls where uname = ?", uname, as: Int32)
    end
  end

  @[AlwaysInline]
  def self.db_path
    "var/users/2023-lixi.db"
  end

  def self.init_sql
    <<-SQL
    create table rolls(
      id integer primary key,
      uname varchar not null,
      vcoin integer not null,
      mtime integer not null
    );

    create index user_idx on rolls (uname);
    create index best_idx on rolls (vcoin);

    pragma journal_mode = WAL
    SQL
  end
end
