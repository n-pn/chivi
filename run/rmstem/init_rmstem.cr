ENV["CV_ENV"] ||= "production"
require "../../src/rdapp/data/rmstem"

struct Rmstem
  include DB::Serializable
  include DB::Serializable::NonStrict

  getter id : String

  getter rlink : String = ""   # remote catalog link
  getter rtime : Int64 = 0_i64 # last remote update

  getter btitle : String
  getter author : String

  getter cover : String
  getter intro : String
  getter genre : String
  getter xtags : String

  getter status_str : String
  getter update_str : String
  getter latest_cid : String

  getter chap_count : Int32
  getter chap_avail : Int32

  getter wn_id : Int32
  getter _flag : Int32
end

def import_db(db_file : String, sname : String)
  puts db_file

  inputs = DB.open("sqlite3:#{db_file}?immutable=1") do |db|
    query = "select * from rmbooks where btitle <> '' and author <> ''"
    db.query_all query, as: Rmstem
  end

  rstems = inputs.map do |input|
    rstem = RD::Rmstem.new(sname, input.id, input.rlink)
    rstem.rtime = input.rtime

    rstem.btitle_zh = input.btitle
    rstem.author_zh = input.author

    rstem.cover_rm = input.cover
    rstem.intro_zh = input.intro
    rstem.genre_zh = "#{input.genre}\t#{input.xtags.gsub(" ", "\t")}".strip

    rstem.status_str = input.status_str
    rstem.update_str = input.update_str
    rstem.latest_cid = input.latest_cid

    rstem.chap_count = input.chap_count
    rstem.chap_avail = input.chap_avail

    rstem.wn_id = input.wn_id
    rstem._flag = input._flag.to_i16

    rstem
  end

  PGDB.transaction do |tx|
    rstems.each(&.upsert!(db: tx.connection))
  end

  puts "#{rstems.size} synced!"
end

import_db("var/zroot/rmseed/_zxcs.me.db3", "!zxcs.me")
