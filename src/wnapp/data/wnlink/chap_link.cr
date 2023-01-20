require "crorm"
require "crorm/sqlite3"

class WN::ChapLink
  include Crorm::Model
  @@table = "links"

  field fg_ch_no : Int32

  field bg_sname : String
  field bg_s_bid : Int32

  field bg_ch_no : Int32
  field bg_s_cid : Int32

  field _flag : Int32 = 0

  def save!(repo : Crorm::Sqlite3::Repo)
    fields, values = self.get_changes
    repo.insert(@@table, fields, values, :replace)
  end

  ###

  REPOS = {} of String => Crorm::Sqlite3::Repo

  def self.repo(sname : String, s_bid : Int32)
    db_name = "#{sname}/#{s_bid}"
    REPOS[db_name] ||= Crorm::Sqlite3::Repo.new(db_path(db_name), init_sql)
  end

  @[AlwaysInline]
  def self.db_path(db_name : String)
    "var/chaps/infos/#{db_name}-links.db"
  end

  def self.init_sql
    <<-SQL
    pragma journal_mode = WAL;

    create table if not exists #{@@table} (
      fg_ch_no integer not null,
      --
      bg_sname varchar not null,
      bg_s_bid integer not null,
      --
      bg_ch_no integer not null,
      bg_s_cid integer not null,
      --
      _flag integer not null default 0,
      primary key (fg_ch_no, bg_sname)
    );
    SQL
  end
end
