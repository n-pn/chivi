require "crorm"
require "crorm/sqlite3"

class WN::ChName
  include Crorm::Model
  @@table = "names"

  field ch_no : Int32 # chaper index number
  field s_cid : Int32 # chapter file name

  field title : String = "" # rest of chapter title
  field chdiv : String = "" # volume name

  def save!(repo : Crorm::Sqlite3::Repo)
    fields, values = self.get_changes
    repo.insert(@@table, fields, values, :replace)
  end

  ###

  REPOS = {} of String => Crorm::Sqlite3::Repo

  def self.repo(sname : String, s_bid : Int32, scope = "bg")
    db_name = "#{scope}/#{sname}/#{s_bid}"
    REPOS[db_name] ||= Crorm::Sqlite3::Repo.new(db_path(db_name), init_sql)
  end

  @[AlwaysInline]
  def self.db_path(db_name)
    "var/chaps/infos-#{db_name}-names.db"
  end

  def self.init_sql
    <<-SQL
    create table if not exists #{@@table} (
      ch_no integer primary key,
      s_cid integer not null,

      title varchar not null default '',
      chdiv varchar not null default ''
    );
    SQL
  end

  def self.upsert!(repo, data : Enumerable(self))
  end
end
