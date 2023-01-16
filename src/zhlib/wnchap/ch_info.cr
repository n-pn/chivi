require "crorm"
require "crorm/sqlite3"

class WN::ChInfo
  include Crorm::Model
  @@table = "chaps"

  field ch_no : Int32 # chaper index number
  field s_cid : Int32 # usually ch_no * 10

  field title : String = "" # translated
  field chdiv : String = "" # volume name

  field mtime : Int64 = 0   # last modification time
  field uname : String = "" # last modified by username

  field c_len : Int32 = 0 # chars count
  field p_len : Int32 = 0 # parts count

  field _path : String = "" # file locator
  field _flag : Int32 = 0   # marking states

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
    "var/chaps/infos-fg/#{db_name}-infos.db"
  end

  def self.init_sql
    <<-SQL
    pragma journal_mode = WAL;

    create table if not exists #{@@table} (
      ch_no integer primary key,
      s_cid integer not null,

      title varchar not null default '',
      chdiv varchar not null default '',

      c_len integer not null default 0,
      p_len integer not null default 0,

      mtime integer not null default 0,
      uname varchar not null default '',

      _path varchar not null default '',
      _flag smallint not null default 0
    );
    SQL
  end

  def self.upsert!(repo, data : Enumerable(self))
  end
end
