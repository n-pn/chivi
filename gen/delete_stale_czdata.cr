require "zstd"
require "sqlite3"

INP_DIR = "/2tb/zroot/wn_db"

snames = ARGV.reject(&.starts_with?('-'))

if ARGV.includes?("--users")
  snames.concat Dir.children(INP_DIR).select!(&.starts_with?('@'))
end

snames.each do |sname|
  files = Dir.glob("#{INP_DIR}/#{sname}/*.zst")
  files.each_with_index(1) do |zst_path, idx|
    db_path = zst_path.rstrip(".zst")
    next unless db_info = File.info?(db_path)

    zst_info = File.info(zst_path)
    next unless zst_info.size < 290 # || db_info.modification_time < zst_info.modification_time

    puts "deleting #{db_path}"
    File.delete(db_path)
    File.delete(zst_path) if zst_info.size < 290
  rescue ex
    Log.error(exception: ex) { zst_path }
  end
end
