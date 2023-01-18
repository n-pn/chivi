require "crorm"
require "crorm/sqlite3"

class WN::ChInfo
  include Crorm::Model
  @@table = "chaps"

  field ch_no : Int32 # chaper index number
  field s_cid : Int32 # chapter fname in disk/remote

  field title : String = "" # chapter title
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

  def self.repo(sname : String, s_bid : Int32, type = "fg", name = "infos")
    db_name = "#{type}/#{sname}/#{s_bid}-#{name}"
    REPOS[db_name] ||= Crorm::Sqlite3::Repo.new(db_path(db_name), init_sql)
  end

  DIR = "var/chaps/infos"

  @[AlwaysInline]
  def self.db_path(sname : String, s_bid : String, type : String = "fg", name : String = "infos")
    "#{DIR}-#{type}/#{sname}/#{s_bid}-#{name}.db"
  end

  @[AlwaysInline]
  def self.db_path(db_name : String)
    "#{DIR}-#{db_name}.db"
  end

  def self.init_sql
    {{ read_file("#{__DIR__}/sql/init_ch_info.sql") }}
  end
end
