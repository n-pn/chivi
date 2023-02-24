require "uuid"
require "crorm/model"
require "crorm/sqlite3"

require "../../mt_sp/sp_core"
require "../../_util/text_util"

class YS::YsCrit
  include Crorm::Model

  @@table = "crits"

  field id : Int32
  field uuid : UUID # original id

  field wn_id : Int32 = 0 # chivi book id
  field bl_id : Int32 = 0 # yousuu booklist id (as chivi id)

  field book_id : Int32 = 0   # yousuu book id
  field user_id : Int32 = 0   # yousuu user id
  field list_id : UUID? = nil # yousuu booklist id

  field stars : Int32 = 3
  field bsize : Int32 = 0 # body text word count

  field ztags : String = ""
  field vtags : String = ""

  field like_count : Int32 = 0
  field repl_count : Int32 = 0
  field repl_total : Int32 = 0

  field mtime : Int64 = 0 # last updated at
  field rtime : Int64 = 0 # last crawled at

  field _sort : Int32 = 0
  ###

  class_getter repo : SQ3::Repo do
    init_sql = {{ read_file("#{__DIR__}/sql/init_ys_crit.sql") }}
    SQ3::Repo.new("var/ysapp/users.db", init_sql, ttl: 3.minutes)
  end

  RAW_UPSERT_FIELDS = {
    "uuid", "book_id", "user_id",
    "stars", "body_len", "ztags",
    "like_count", "repl_total",
    "mtime", "rtime",
  }

  def self.raw_upsert_sql : String
    SQ3::SQL.upsert_smt(@@table, RAW_UPSERT_FIELDS, on_conflict: "(id)", skip_fields: {"id"})
  end

  ###############
  # def self.upsert!(id : Int32, zname : String)
  #   find({zname: zname}) || begin
  #     entry = new({origin_id: origin_id, zname: zname}).tap(&.fix_name)
  #     entry.tap(&.save!)
  #   end
  # end
end
