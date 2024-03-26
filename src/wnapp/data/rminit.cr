require "crorm"

class ZR::Rminit
  class_getter init_sql = <<-SQL
    pragma journal_mode = WAL;

    CREATE TABLE IF NOT EXISTS rminits(
      rtime bigint NOT NULL primary key,
      uname text NOT NULL DEFAULT '',
      ---
      chap_count int NOT NULL DEFAULT 0,
      latest_cid text NOT NULL DEFAULT '',
      ---
      update_str text NOT NULL DEFAULT '',
      status_str text NOT NULL DEFAULT ''
    );
    SQL

  def self.db_path(sname : String, sn_id : String)
    "/srv/chivi/zroot/wnovel/#{sname}/#{sn_id}-rinit.db3"
  end

  ###

  include Crorm::Model
  schema "rminits", :sqlite, multi: true

  field rtime : Int64 = Time.utc.to_unix, pkey: true
  field uname : String = ""

  field chap_count : Int32 = 0
  field latest_cid : String = ""

  field status_str : String = ""
  field update_str : String = ""
end
