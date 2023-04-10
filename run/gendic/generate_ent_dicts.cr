# require "json"
# require "../vp_init"
require "sqlite3"
require "../../src/mtapp/data/ent_defn"

DIR = "var/anlzs/texsmart/out"

inputs = Dir.glob("#{DIR}/*.db")
inputs.sort_by! { |file| File.basename(file, ".db").to_i }

def generate(db_path : String, wn_id = File.basename(db_path, ".db"))
  counts = {} of String => Array({String, Int32})

  DB.open("sqlite3:#{db_path}") do |db|
    db.query_each "select zstr, ztag, count from terms where type >= 300 order by count desc" do |rs|
      count = counts[rs.read(String)] ||= [] of {String, Int32}
      count << rs.read(String, Int32)
    end
  end

  out_db_path = MT::EntDefn.db_path(wn_id)

  DB.open("sqlite3:#{out_db_path}?journal_mode=WAL&synchronous=normal") do |db|
    db.exec MT::EntDefn.init_sql

    db.exec "begin"

    counts.each do |zstr, count|
      db.exec "replace into defns (zstr, ts_sdk) values ($1, $2)", zstr, count.to_json
    end

    db.exec "commit"
  end
end

inputs.each_with_index(1) do |db_path, idx|
  puts "#{idx} / #{db_path}"
  generate(db_path)
end
