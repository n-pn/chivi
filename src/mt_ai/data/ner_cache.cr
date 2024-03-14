require "../_raw/raw_ent"
require "../../_util/time_util"

require "crorm"

class MT::NerCache
  include Crorm::Model

  DB_DIR = "var/mtdic"
  class_getter db_path = "#{DB_DIR}/cache/entities.db3"

  class_getter init_sql : String = <<-SQL
  CREATE TABLE IF NOT EXISTS entities (
    rid int NOT NULL,
    ver int NOT NULL,
    ent text NOT NULL,
    primary key(rid, ver)
  ) strict, without rowid;
  SQL

  schema "entities", :sqlite

  field rid : Int64, pkey: true
  field ver : Int32, pkey: true
  field ent : String = "" # msra + ontonotes

  def self.new(rid : Int32, ver : Int32 | Int16, ent : Array(RawEnt))
    new(rid, ver.to_i, ent.map { |x| "#{x.kind}/#{x.zstr}" }.uniq!.join('\t'))
  end

  def initialize(@rid, @ver, @ent)
  end
end

# require "../../_data/zr_db"

# mtime = TimeUtil.cv_mtime(Time.local(2024, 3, 14, 20, 0, 0))
# query = "select rid, ver::int, ner as ent from mcache where mcache.ner <> '' and mtime >= $1"
# inputs = ZR_DB.query_all query, mtime, as: MT::NerCache

# MT::NerCache.db.open_tx do |db|
#   inputs.each(&.upsert!(db: db))
# end
