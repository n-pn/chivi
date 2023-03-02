require "crorm/model"
require "crorm/sqlite3"

class CV::VcoinXlog
  include Crorm::Model
  class_getter table = "xlogs"

  field id : Int32, primary: true

  field sender : Int32
  field sendee : Int32

  field amount : Float64 = 0_f64
  field reason : String = ""

  field ctime : Int64

  def initialize(@sender, @sendee, @amount, @reason, @ctime = Time.utc.to_unix)
  end

  def create!(repo = self.class.repo)
    fields, values = db_changes
    repo.insert(@@table, fields, values)
  end

  ####

  def self.count(vu_id : Nil)
    stmt = "select count (*) from #{@@table}"
    self.repo.db.query_one(stmt, as: Int32)
  end

  def self.count(vu_id : Int32)
    stmt = "select count (*) from #{@@table} where sender = $1 or sendee = $1"
    self.repo.db.query_one(stmt, vu_id, as: Int32)
  end

  def self.select(stmt : String, *args : DB::Any)
    self.repo.db.query_all(stmt, *args, as: self)
  end

  def self.db_path
    "var/users/vcoin_xlog.db"
  end

  def self.init_sql
    <<-SQL
    create table if not exists #{@@table} (
      id integer primary key,

      sender integer default 0,
      sendee integer default 0,

      amount real default 0,
      reason text default '',

      ctime integer default 0,
      _flag integer default 0
    );

    create index if not exits sender_idx on #{@@table}(sender);
    create index if not exits sendee_idx on #{@@table}(sendee);
    SQL
  end

  class_getter repo : SQ3::Repo { SQ3::Repo.new(db_path, init_sql) }
end
