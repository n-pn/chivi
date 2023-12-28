require "sqlite3"

require "compress/zip"

DIR = "/2tb/zroot/ztext"

def load_existed(db_path : String)
  return Set(String).new unless File.file?(db_path)

  DB.open("sqlite3:#{db_path}?immutable=1") do |db|
    db.query_all("select ch_no from chinfos where mtime > 0", as: Int32).to_set
  end
end

def check_missing(zip_path)
  sname = File.basename(File.dirname(zip_path))
  sn_id = File.basename(zip_path, ".zip")

  existed = load_existed("var/stems/up#{sname}/#{sn_id}-cinfo.db3")

  Compress::Zip::File.open(zip_path) do |zip|
    zip.entries.each do |entry|
      ch_no = File.basename(entry.filename, ".zh").to_i // 10
      existed.delete(ch_no)
    end
  end

  puts "#{zip_path}: missing #{existed} files" unless existed.empty?
end

files = Dir.glob("#{DIR}/@*/*.zip")
files.each do |zip_file|
  check_missing(zip_file)
end
