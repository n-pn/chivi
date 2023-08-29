require "sqlite3"
require "crorm/model"

class ZR::Btitle
  class_getter db_path = "var/zroot/global/btitles.db3"

  class_getter init_sql = <<-SQL
    CREATE TABLE btitles(
      name_zh text NOT NULL PRIMARY KEY,
      name_hv text NOT NULL default '',
      --
      name_vi text NOT NULL DEFAULT '',
      name_mt text NOT NULL DEFAULT '',
      name_bv text NOT NULL DEFAULT '',
      name_gv text NOT NULL DEFAULT '',
      --
      name_en text NOT NULL DEFAULT '',
      name_de text NOT NULL DEFAULT '',
      name_be text NOT NULL DEFAULT '',
      name_ge text NOT NULL DEFAULT '',
      --
      wb_id int NOT NULL DEFAULT 0,
      rtime bigint NOT NULL DEFAULT 0,
      _flag int NOT NULL DEFAULT 0
    );
    SQL

  ###

  include Crorm::Model
  schema "btitles"

  field name_zh : String, pkey: true
  field name_hv : String = "" # name converted to hanviet

  field name_vi : String = "" # name provided by users
  field name_mt : String = "" # name converted by machine
  field name_bv : String = "" # name translated by bing (zh to vi)
  field name_gv : String = "" # name translated by google (zh to vi)

  field name_en : String = "" # official english name (if available)
  field name_de : String = "" # name translated by deepl (zh to en)
  field name_be : String = "" # name translated by bing (zh to en)
  field name_ge : String = "" # name translated by google (zh to en)

  field wb_id : Int32 = 0     # official chivi id
  field rtime : Int64 = 0_i64 # last updated
  field _flag : Int32 = 0     # tracking flags

  def initialize(@name_zh)
  end

  ###

  CACHE = {} of String => {String, String}

  def self.get_names(name_zh : String) : {String, String}
    CACHE[name_zh] ||= begin
      stmt = <<-SQL
        select coalesce(nullif(name_vi, ''), name_mt), name_hv from btitles
        where name_zh = $1 limit 1
        SQL
      open_db(&.query_one?(stmt, name_zh, as: {String, String})) || {name_zh, name_zh}
    end
  end
end
