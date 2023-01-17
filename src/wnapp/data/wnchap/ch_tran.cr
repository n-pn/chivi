require "crorm"
require "crorm/sqlite3"

class WN::ChTran
  include Crorm::Model
  @@table = "trans"

  field ch_no : Int32 # chaper index number

  field title : String = "" # translated
  field chdiv : String = "" # volume name
  field uslug : String = "" # slugified title

  field _flag : Int32 = 0 # marking states

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
    "var/chaps/infos-fg/#{db_name}-trans.db"
  end

  def self.init_sql
    <<-SQL
    pragma journal_mode = WAL;

    create table if not exists #{@@table} (
      ch_no integer primary key,

      title varchar not null default '',
      chdiv varchar not null default '',
      uslug varchar not null default '',

      _flag smallint not null default 0
    );
    SQL
  end
end
