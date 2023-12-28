require "compress/zip"
require "../../src/_data/zr_db"
require "../../src/rdapp/data/czdata"

ZIP_DIR = "/2tb/zroot/ztext"
DB3_DIR = "/2tb/var.chivi/stems"

snames = ARGV.reject(&.starts_with?('-'))

if ARGV.includes?("--up")
  snames.concat Dir.children(DB3_DIR).select(&.starts_with?("up"))
end

if ARGV.includes?("--rm")
  snames.concat Dir.children(DB3_DIR).select(&.starts_with?("rm"))
end

snames = ["wn~avail"] if snames.empty?
puts snames

snames.each do |sname|
  db_paths = Dir.glob("#{DB3_DIR}/#{sname}/*-cinfo.db3")
  db_paths.each do |db_path|
    sname = sname.sub(/^rm|wn|up/, "")
    update_stats(sname, db_path)
  rescue ex
    puts "#{db_path}: #{ex}"
  end
end

record Zdata, ch_no : Int32, title : String, chdiv : String, rlink : String, spath : String do
  include DB::Serializable

  def s_cid(same_as_ch_no : Bool = false) : Int32
    return @ch_no if same_as_ch_no
    return @spath.split('/').last.to_i unless @spath.empty?
    return @rlink.split(/\D+/, remove_empty: true).last.to_i unless @rlink.empty?

    0
  end
end

FETCH_SQL = <<-SQL
  select ch_no, ztitle as title, zchdiv as chdiv, rlink, spath
  from chinfos
SQL

UPDATE_SQL = <<-SQL
  insert into czdata(ch_no, s_cid, title, chdiv)
  values ($1, $2, $3, $4)
  on conflict(ch_no) do update set
    title = excluded.title,
    chdiv = excluded.chdiv,
    s_cid = IIF(czdata.s_cid <> 0, czdata.s_cid, excluded.s_cid)
SQL

def update_stats(sname : String, db_path)
  zdatas = DB.open("sqlite3:#{db_path}?immutable=1") do |db|
    db.query_all FETCH_SQL, as: Zdata
  end

  return if zdatas.empty?

  sn_id = File.basename(db_path, "-cinfo.db3")

  case sname
  when .starts_with?("~"), .starts_with?("@"), "!zxcs.me"
    same_as_ch_no = true
  else
    same_as_ch_no = false
  end

  RD::Czdata.db(sname, sn_id).open_tx do |db|
    zdatas.each do |zdata|
      s_cid = zdata.s_cid(same_as_ch_no)
      db.exec UPDATE_SQL, zdata.ch_no, s_cid, zdata.title, zdata.chdiv
    rescue ex
      puts ex
    end
  end

  puts "#{sname}/#{sn_id} #{zdatas.size} entries updated!"
end
