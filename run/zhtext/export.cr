require "sqlite3"
require "colorize"

record Cztext, ch_no : Int32, chdiv : String, parts : String, mtime : Int64 do
  include DB::Serializable
end

def export(db_path)
  chaps = DB.open("sqlite3:#{db_path}?immutable=1") do |db|
    query = "select ch_no, chdiv, parts, mtime from czinfos where parts <> '' order by ch_no asc, mtime desc"
    db.query_all(query, as: Cztext).uniq!(&.ch_no)
  end

  puts "#{db_path}: #{chaps.size} files"
  return if chaps.empty?

  sname = File.basename(File.dirname(db_path)).sub(/^wn|rm|up/, "")
  sn_id = File.basename(db_path, "-zdata.db3")

  out_dir = "/2tb/zroot/ztext/#{sname}/#{sn_id}"
  Dir.mkdir_p(out_dir)

  chaps.each do |zchap|
    out_file = "#{out_dir}/#{zchap.ch_no}0.zh"
    File.write(out_file, "///#{zchap.chdiv}\n#{zchap.parts}")
    mtime = Time.unix(zchap.mtime)
    File.utime(mtime, mtime, out_file)
  end

  `zip -FSrjyomq '#{out_dir}.zip' '#{out_dir}'`
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
    export(file)
  rescue ex
    puts ex.colorize.red
  end
end
