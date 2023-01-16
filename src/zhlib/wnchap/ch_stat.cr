require "crorm"
require "crorm/sqlite3"

class WN::ChStat
  include Crorm::Model
  @@table = "stats"

  field ch_no : Int32 # chaper index number
  field s_cid : Int32 # chapter file name

  field c_len : Int32 = 0 # char count
  field p_len : Int32 = 0 # part count

  field mtime : Int64 = 0   # last modification time
  field _path : String = "" # file location

  def save!(repo : Crorm::Adapter)
    fields, values = self.get_changes
    repo.insert(self.class.table, fields, values, false)
  end

  REPOS = {} of String => Crorm::Sqlite3::Repo

  def self.repo(sname : String, s_bid : Int32, scope = "bg")
    db_name = "#{scope}/#{sname}/#{s_bid}"
    REPOS[db_name] ||= Crorm::Sqlite3::Repo.new(db_path(db_name), init_sql)
  end

  @[AlwaysInline]
  def self.db_path(db_name)
    "var/chaps/infos-#{db_name}-stats.db"
  end

  def self.init_sql
    <<-SQL
      create table if not exists #{@@table} (
        ch_no integer primary key,
        s_cid integer not null,

        c_len integer not null default 0,
        p_len integer not null default 0,

        mtime integer not null default 0,
        _path varchar not null default ''
      );
    SQL
  end
end
