require "compress/zip"
require "../../src/_data/zr_db"
require "../../src/rdapp/data/czdata"

ZIP_DIR = "/2tb/zroot/ztext"

snames = ARGV.reject(&.starts_with?('-'))
snames = Dir.children(ZIP_DIR) if snames.empty?

if ARGV.includes?("--up")
  snames.concat Dir.children(ZIP_DIR).select(&.starts_with?('@'))
end

if ARGV.includes?("--rm")
  snames.concat Dir.children(ZIP_DIR).select(&.starts_with?('!'))
end

snames.each do |sname|
  sn_ids = Dir.children("#{ZIP_DIR}/#{sname}")
    .select!(&.ends_with?(".zip"))
    .map! { |x| File.basename(x, ".zip") }

  sn_ids.each do |sn_id|
    update_stats(sname, sn_id.to_i)
  end
end

record Zdata, ch_no : Int32, title : String, chdiv : String do
  include DB::Serializable
end

FETCH_SQL = <<-SQL
  select c_idx / 10 as ch_no, ztitle as title, zchdiv as chdiv
  from wnchap where sname = $1 and sn_id = $2
SQL

UPDATE_SQL = <<-SQL
  insert into czdata(ch_no, s_cid, title, chdiv)
  values ($1, 0, $2, $3)
  on conflict(ch_no) do update set
    title = excluded.title,
    chdiv = excluded.chdiv
SQL

def update_stats(sname : String, sn_id : Int32)
  zdatas = ZR_DB.query_all FETCH_SQL, sname, sn_id, as: Zdata

  RD::Czdata.db(sname, sn_id).open_tx do |db|
    zdatas.each do |zdata|
      db.exec UPDATE_SQL, zdata.ch_no, zdata.title, zdata.chdiv
    end
  end

  puts "#{sname}/#{sn_id} #{zdatas.size} entries updated!"
end
