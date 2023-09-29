require "../../src/zroot/rmstem"

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

def import_db(db_file : String)
  puts db_file

  inputs = DB.open("sqlite3:#{db_file}?immutable=1") do |db|
    query = "select * from rmbooks where btitle <> '' and author <> ''"
    db.query_all query, as: Rmstem
  end

  sname = File.basename(db_file, ".db3")

  outputs = inputs.map do |input|
    output = ZR::Rmstem.new(sname, input.id, input.rlink)
    output.rtime = input.rtime

    output.btitle_zh = input.btitle
    output.author_zh = input.author

    output.cover_rm = input.cover
    output.intro_zh = input.intro
    output.genre_zh = "#{input.genre}\t#{input.xtags.gsub("s", "\t")}".strip

    output.status_str = input.status_str
    output.update_str = input.update_str
    output.latest_cid = input.latest_cid

    output.chap_count = input.chap_count
    output.chap_avail = input.chap_avail

    output.wn_id = input.wn_id
    output._flag = input._flag.to_i16

    output
  end

  PGDB.transaction do |tx|
    outputs.each(&.upsert!(db: tx.connection))
  end

  puts "#{outputs.size} synced!"
end

db_files = Dir.glob("var/zroot/rmseed/!*.db3")

db_files.each do |db_file|
  import_db(db_file)
rescue ex
  puts ex
end
