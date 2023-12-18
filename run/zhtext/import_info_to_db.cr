require "sqlite3"
require "colorize"
require "../../src/rdapp/data/wnchap"

record Czinfo, ch_no : Int32, title : String, chdiv : String, mtime : Int64 do
  include DB::Serializable
end

def import(db_path)
  inputs = DB.open("sqlite3:#{db_path}?immutable=1") do |db|
    query = "select ch_no, title, chdiv, mtime from czinfos order by ch_no asc, mtime desc"
    db.query_all(query, as: Czinfo).uniq!(&.ch_no)
  end

  puts "#{db_path}: #{inputs.size} files"
  return if inputs.empty?

  sname = File.basename(File.dirname(db_path)).sub(/^wn|rm|up/, "")
  sn_id = File.basename(db_path, "-zdata.db3").to_i

  zchaps = inputs.map do |zinfo|
    RD::Wnchap.new(
      sname: sname,
      sn_id: sn_id,
      c_idx: zinfo.ch_no * 10,
      ztitle: zinfo.title,
      zchdiv: zinfo.chdiv,
      extra: "",
      mtime: (zinfo.mtime // 10).to_i
    )
  end

  ZR_DB.transaction do |tx|
    db = tx.connection
    zchaps.each(&.upsert_raw!(db: db))
  end
end

INP = "/2tb/var.chivi/stems"

snames = ARGV.reject(&.starts_with?('-'))

if ARGV.includes?("--up")
  snames.concat Dir.children(INP).select(&.starts_with?("up"))
end

if ARGV.includes?("--rm")
  snames.concat Dir.children(INP).select(&.starts_with?("rm"))
end

snames.each do |sname|
  files = Dir.glob("#{INP}/#{sname}/*-zdata.db3")
  puts "#{sname}: #{files.size} files"

  files.each do |file|
    import(file)
  rescue ex
    puts ex.colorize.red
  end
end
