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

def load_existed(zip_path)
  return Set(String).new unless File.file?(zip_path)

  Compress::Zip::File.open(zip_path) do |zip|
    zip.entries.map { |x| File.basename(x.filename, ".zh") }.to_set
  end
end

def copy_to_new_dir(inp_path)
  out_path = inp_path.sub(INP_DIR, OUT_DIR).rchop('/')

  sname = File.basename(File.dirname(out_path))
  sn_id = File.basename(out_path)
  cinfos = load_cinfos("var/stems/up#{sname}/#{sn_id}")

  zip_path = "#{out_path}.zip"
  existed = load_existed(zip_path)

  files = Dir.glob("#{inp_path}*.gbk")
  fresh = 0

  files.each do |file|
    unless File.basename(file, ".gbk").in?(existed)
      fresh += 1

      ch_no = File.basename(file, ".gbk").to_i // 10
      chdiv = cinfos[ch_no]?.try(&.zchdiv) || ""
      ztext = RD::Cztext.fix_raw(File.read(file, encoding: "GB18030"))

      fpath = "#{inp_path}/#{ch_no}0.zh"
      File.write(fpath, "///#{chdiv}\n#{ztext}")

      utime = File.info(file).modification_time
      File.utime(utime, utime, fpath)
    end

    File.delete(file)
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
