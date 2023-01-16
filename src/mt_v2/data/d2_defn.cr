require "crorm"
require "crorm/sqlite3"

class M2::DbDefn
  include Crorm::Model
  @@table = "defns"

  @@repo = Crorm::Sqlite3::Repo.new(db_path, init_sql)

  @[AlwaysInline]
  def self.db_path
    "var/dicts/v2raw/defns.dic"
  end

  def self.init_sql
    {{ read_file("#{__DIR__}/sql/defns_v2.sql") }}
  end

  ###

  field id : Int32, primary: true

  field dic : Int32 = 0
  field tag : Int32 = 0

  field key : String = ""
  field val : String = ""

  field ptag : Int32 = 0
  field rank : Int32 = 3

  field uname : String = ""
  field mtime : Int64 = 0

  field _ctx : String = ""
  field _idx : Int32 = 0

  field _prev : Int32 = 0
  field _flag : Int32 = 1

  EPOCH = Time.utc(2020, 1, 1, 0, 0, 0).to_unix // 60

  def save!(repo = @@repo, @mtime = Time.utc.to_unix // 60 - EPOCH) : Array(Int32)
    prevs = find_prevs(repo, self.tab)

    if @_prev = prevs[0]?
      query = "update table #{@@table} set _flag = -_flag where id in ?"
      repo.open_db(&.exec(query, prevs))
    end

    fields, values = self.get_changes
    repo.insert(@@table, fields, values)

    prevs
  end

  def find_prevs(repo = @@repo, tab = self.tab)
    query = <<-SQL
      select id from #{@@table}
      where dic = ? and key = ? and ptag = ? and _flag > 0
    SQL

    case tab
    when 3 then query += " and uname = '#{@uname}'" # only search for terms from same user
    when 1 then query += " and tab = 2"             # remove temp defns if add dicts from
    end

    repo.open_db(&.query_all(query, dic, key, ptag, as: Int32))
  end
end
