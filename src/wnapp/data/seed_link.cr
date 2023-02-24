require "crorm"
require "crorm/sqlite3"

class WN::SeedLink
  include Crorm::Model
  @@table = "links"

  field fg_sname : String = ""
  field fg_s_bid : Int32 = 0

  field bg_sname : String = ""
  field bg_s_bid : Int32 = 0

  field last_ch_no : Int32 = 0
  field last_s_cid : Int32 = 0

  field stime : Int64
  field _flag : Int32 = 0

  # def save!(repo : Crorm::Sqlite3::Repo)
  #   fields, values = self.get_changes
  #   repo.insert(@@table, fields, values, :replace)
  # end

  # ###

  class_getter repo : SQ3::Repo { SQ3::Repo.new(db_path, init_sql) }

  @[AlwaysInline]
  def self.db_path
    "var/chaps/seeds-links.db"
  end

  def self.init_sql
    <<-SQL
    pragma journal_mode = WAL;

    create table if not exists #{@@table} (
      fg_sname varchar not null,
      fg_s_bid integer not null,
      --
      bg_sname varchar not null,
      bg_s_bid integer not null,
      --
      last_ch_no integer not null,
      last_s_cid integer not null,
      --
      stime integer not null default 0,
      _flag integer not null default 0,
      primary key (fg_sname, fg_s_bid, bg_sname)
    );
    SQL
  end

  def self.all(fg_sname : String, fg_s_bid : Int32)
    @@repo.open_db do |db|
      query = <<-SQL
        select * from links
        where fg_sname = ?, fg_s_bid = ?
        order by _flag desc
      SQL

      db.query_all(query, fg_sname, fg_s_bid, as: self)
    end
  end

  def self.one(fg_sname : String, fg_s_bid : Int32)
    all(fg_sname, fg_s_bid).first?
  end
end
