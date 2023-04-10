require "crorm"
require "crorm/sqlite3"

class MT::QtInit
  include Crorm::Model
  @@table = "defns"

  field zstr : String = ""

  field zpos : String = ""
  field zent : String = ""

  field upos : String = ""
  field xpos : String = ""
  field xtag : String = ""

  field _tls : String = ""

  ###

  def self.repo(dname : String | Int32)
    SQ3::Repo.new(db_path(dname), init_sql, ttl: 3.minutes)
  end

  @[AlwaysInline]
  def self.db_path(dname : String | Int32)
    "var/dicts/autos/#{dname}.dic"
  end

  def self.init_sql(table = @@table)
    <<-SQL
      CREATE TABLE IF NOT EXISTS #{table} (
        "zstr" varchar NOT NULL primary key,
        -- from texsmart
        "zpos" varchar not null default '',
        "zent" varchar not null default '',
        -- delivered from `zstr` and `zpos`
        "upos" varchar NOT NULL DEFAULT '',
        "xpos" varchar NOT NULL DEFAULT '',
        "xtag" varchar NOT NULL DEFAULT '',
        -- translation
        "_tls" varchar not null default ''
      );

      pragma journal_mode = WAL;
    SQL
  end
end
