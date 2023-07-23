require "colorize"
require "compress/zip"
require "xxhash"

require "../src/_data/remote/zhcata"
require "../src/_util/hash_util"

DIR = "/2tb/var.chivi/zchap/globs"

# TXT = "var/texts/rgbks"

def update_seed(sname : String)
  db_paths = Dir.glob("#{DIR}/#{sname}/*.db3")

  db_paths.each_with_index(1) do |db_path, idx|
    puts "- <#{idx}/#{db_paths.size}> #{db_path}"
    extract_and_update(db_path)
  end
end

record Stat, s_cid : String, chlen : Int32, xxh32 : Int32, mtime : Int64

def extract_and_update(db_path : String)
  zip_path = db_path.sub(".db3", ".zip")
  return unless File.file?(zip_path)

  stats = [] of Stat

  Compress::Zip::File.open(zip_path) do |zip|
    zip.entries.each do |entry|
      text = entry.open do |io|
        io.set_encoding("GB18030", invalid: :skip)
        io.gets_to_end
      end

      s_cid = File.basename(entry.filename, ".gbk")
      chlen = text.size
      xxh32 = XXHash.xxh32(text).unsafe_as(Int32)
      mtime = entry.time.to_unix

      stats << Stat.new(s_cid, chlen, xxh32, mtime)
    end
  end

  zh_cata = Zhcata.new(db_path)
  zh_cata.open_tx do |db|
    stats.each do |stat|
      db.exec <<-SQL, stat.chlen, stat.xxh32, stat.mtime, stat.s_cid
        update chaps set chlen = $1, xxh32 = $2, mtime = $3
        where s_cid = $4
        SQL
    end
  end

  # missing = recorded - existing
  # uncount = existing - recorded

  # return if missing.empty? && uncount.empty?

  # puts "- <#{zip_path}> total: #{recorded.size}, missing: #{missing}, uncount: #{uncount}".colorize.yellow
end

update_seed "!zxcs_me"
