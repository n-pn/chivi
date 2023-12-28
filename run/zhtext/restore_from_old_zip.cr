require "sqlite3"
require "compress/zip"

require "../../src/rdapp/data/cztext"

INP_DIR = "/2tb/zroot/restore"
OUT_DIR = "/2tb/zroot/ztext"

record Czinfo, ch_no : Int32, zchdiv : String, mtime : Int64 do
  include DB::Serializable
end

def load_cinfos(db_path : String)
  return {} of Int32 => Czinfo unless File.file?(db_path)

  DB.open("sqlite3:#{db_path}?immutable=1") do |db|
    query = "select ch_no, zchdiv, mtime from chinfos"
    db.query_all(query, as: Czinfo).to_h { |x| {x.ch_no, x} }
  end
end

def extract_zip(zip_path : String)
  sname = File.basename(File.dirname(zip_path))
  sn_id = File.basename(zip_path, ".zip")

  out_dir = "#{INP_DIR}/#{sname}/#{sn_id}"
  Dir.mkdir_p(out_dir)

  cinfos = load_cinfos("var/stems/up#{sname}/#{sn_id}-cinfo.db3")

  Compress::Zip::File.open(zip_path) do |zip|
    puts "#{zip_path}: #{zip.entries.size} files"

    zip.entries.each do |entry|
      if entry.filename.ends_with?(".gbk")
        ch_no = File.basename(entry.filename, ".gbk").to_i
      else
        ch_no = File.basename(entry.filename, ".txt").to_i
      end

      chdiv = cinfos[ch_no]?.try(&.zchdiv) || ""

      ztext = entry.open do |io|
        io.set_encoding("GB18030") if entry.filename.ends_with?(".gbk")
        RD::Cztext.fix_raw(io.gets_to_end)
      end

      fpath = "#{out_dir}/#{ch_no}0.zh"
      File.write(fpath, "///#{chdiv}\n#{ztext}")
      File.utime(entry.time, entry.time, fpath)
    end
  end
end

def load_existed(zip_path)
  return Set(String).new unless File.file?(zip_path)

  Compress::Zip::File.open(zip_path) do |zip|
    zip.entries.map(&.filename).to_set
  end
end

def copy_to_new_dir(inp_path)
  out_path = inp_path.sub(INP_DIR, OUT_DIR).rchop('/')
  zip_path = "#{out_path}.zip"
  existed = load_existed(zip_path)

  files = Dir.glob("#{inp_path}*.zh")
  fresh = 0

  files.each do |file|
    if File.basename(file).in?(existed)
      File.delete(file)
    else
      fresh += 1
    end
  end

  return if fresh == 0
  puts "total: #{files.size}, fresh: #{fresh} to #{zip_path}"
  `zip -rjyoq '#{zip_path}' '#{inp_path}'`
end

# Dir.glob("#{INP_DIR}/*/*.zip").each do |zip_path|
#   extract_zip(zip_path)
# end

Dir.glob("#{INP_DIR}/*/*/").each do |dir_path|
  copy_to_new_dir dir_path
end
