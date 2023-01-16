require "crorm"
require "crorm/sqlite3"

class WN::FgSeed
  include Crorm::Model

  @@table = "seeds"

  field s_bid : Int32       # equivalent to book id
  field sname : String = "" # username or blank

  field stype : Int32 = 0 # usually the user id
  field _flag : Int32 = 0 # user priority

  field chap_total : Int32 = 0
  field chap_avail : Int32 = 0

  field feed_sname : String = ""
  field feed_s_bid : Int32 = 0
  field feed_s_cid : Int32 = 0
  field feed_stime : Int64 = 0_i64

  field atime : Int64 = 0_i64 # last access time
  field mtime : Int64 = 0_i64 # modification time

  def initialize(@s_bid, @sname = "", @stype = 0)
  end

  def save!(repo = @@repo, @mftime = Time.utc.to_unix)
    fields, values = self.get_changes
    repos.insert(@@table, fields, values, :replace)
  end

  ####

  class_getter repo = Crorm::Sqlite3::Repo.new(db_path, init_sql)

  @[AlwaysInline]
  def self.db_path
    "var/chaps/fg-seeds.db"
  end

  def self.all(s_bid : Int32)
    @@repo.open_db do |db|
      query = "select * from #{@@table} where s_bid = ?"
      db.query_all(query, s_bid, as: self)
    end
  end

  def self.get(s_bid : Int32, sname : String = "")
    @@repo.open_db do |db|
      query = "select * from #{@@table} where s_bid = ? && sname = ?"
      db.query_one?(query, sname, sbid, as: self)
    end
  end

  def self.get!(s_bid : Int32, sname : String = "")
    get(sname, s_bid) || raise "fg_seed [#{sname}/#{s_bid}] not found!"
  end

  def self.init(s_bid : Int32, name : String, &)
    self.get(s_bid, sname) || yield
  end

  def self.init_sql
    <<-SQL
      pragma journal_mode = WAL;
      pragma synchronous = normal;

      create table if not exists #{@@table} (
        s_bid integer not null,
        sname varchar not null,

        stype integer  not null default 0,
        _flag integer not null default 0,

        chap_total integer default 0,
        chap_avail integer default 0,

        feed_sname varchar default 0,
        feed_s_bid integer default 0,
        feed_s_cid integer default 0,
        feed_stime bigint default 0,

        atime bigint default 0,
        mtime bigint default 0,

        primary key(s_bid, sname)
      );
    SQL
  end
end
