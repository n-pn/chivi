require "compress/zip"
require "../../src/_data/zr_db"
require "../../src/rdapp/data/czdata"

SRC_DIR = "/www/var.chivi/zroot/rawtxt"
DB3_DIR = "/2tb/var.chivi/stems"

snames = ARGV.reject(&.starts_with?('-'))

if ARGV.includes?("--up")
  snames.concat Dir.children(SRC_DIR).select(&.starts_with?("@"))
end

puts snames

snames.each do |sname|
  # next if sname.in? "!chivi", "!5200.tv"

  db_paths = Dir.glob("#{SRC_DIR}/#{sname}/*.db3")
  db_paths.each do |db_path|
    update_stats(sname, db_path)
  rescue ex
    puts "#{db_path}: #{ex}"
  end
end

record Zdata, ch_no : Int32, s_cid : String, title : String, chdiv : String do
  include DB::Serializable
end

FETCH_SQL = <<-SQL
  select ch_no, s_cid, ctitle as title, subdiv as chdiv
  from chaps
SQL

UPDATE_SQL = <<-SQL
  insert into czdata(ch_no, s_cid, title, chdiv)
  values ($1, $2, $3, $4)
  on conflict(ch_no) do update set
    title = IIF(czdata.title = '', excluded.title, czdata.title),
    chdiv = IIF(czdata.chdiv = '', excluded.chdiv, czdata.chdiv),
    s_cid = IIF(czdata.s_cid = 0, excluded.s_cid, czdata.s_cid)
  SQL

def update_stats(sname : String, db_path)
  zdatas = DB.open("sqlite3:#{db_path}?immutable=1") do |db|
    db.query_all FETCH_SQL, as: Zdata
  end

  return if zdatas.empty?

  sn_id = File.basename(db_path, ".db3")

  RD::Czdata.db(sname, sn_id).open_tx do |db|
    zdatas.each do |zdata|
      db.exec UPDATE_SQL, zdata.ch_no, zdata.s_cid.to_i, zdata.title, zdata.chdiv
    end
  end

  puts "#{sname}/#{sn_id} #{zdatas.size} entries updated!"
end
