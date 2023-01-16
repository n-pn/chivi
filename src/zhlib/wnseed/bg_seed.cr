require "crorm"
require "crorm/sqlite3"

class WN::BgSeed
  include Crorm::Model
  @@table = "seeds"

  field sname : String
  field s_bid : Int32

  field stype : Int32 = 0
  field _flag : Int32 = 0

  field chap_total : Int32 = 0
  field chap_avail : Int32 = 0
  field last_s_cid : Int32 = 0

  field mtime : Int64 = 0_i64 # modification time
  field stime : Int64 = 0_i64 # modification time

  def initialize(@sname, @s_bid, @stype = 0)
  end

  def save!(repo = @@repo, @mftime = Time.utc.to_unix)
    fields, values = self.get_changes
    repos.insert(@@table, fields, values, :replace)
  end

  ####

  class_getter repo = Crorm::Sqlite3::Repo.new(db_path, init_sql)

  @[AlwaysInline]
  def self.db_path
    "var/chaps/bg-seeds.db"
  end

  def self.get(sname : String, s_bid : Int32)
    @@repo.open_db do |db|
      query = "select * from #{@@table} where sname = ? and s_bid = ?"
      db.query_one?(query, sname, sbid, as: self)
    end
  end

  def self.get!(sname : String, s_bid : Int32)
    get(sname, s_bid) || raise "bg_seed [#{sname}/#{s_bid}] not found!"
  end

  def self.init(sname : String, s_bid : String, &)
    self.get(sname, s_bid) || yield
  end

  def self.init_sql
    <<-SQL
      create table if not exists #{@@table} (
        sname integer not null,
        s_bid integer not null,

        stype integer not null default 0,
        _flag integer not null default 0,

        chap_total integer not null default 0,
        chap_count integer not null default 0,
        last_s_cid integer not null default 0,

        mtime bigint not null default 0,
        stime bigint not null default 0,

        primary key(sname, s_bid)
      );
    SQL
  end
end
