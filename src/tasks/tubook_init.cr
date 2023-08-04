require "../zdeps/data/tubook"

DIR = "/2tb/var.chivi/.keep/random/tuishujin/listBookRepository"

OUT_DB = ZD::Tubook.db

(1..).each do |page|
  path = "#{DIR}/#{page}-100.json"
  break unless rtime = File.info?(path).try(&.modification_time.to_unix)

  json = File.read(path)
  hash = XXHash.xxh32(json).unsafe_as(Int32)

  begin
    data = ZD::RawTubookList.from_json(json)
    puts "- page: #{page}, books: #{data.books.size}"
  rescue ex
    puts [ex, json]
    next
  end

  OUT_DB.exec "begin"

  data.books.each do |input|
    entry = ZD::Tubook.from_raw(input, rtime: rtime, rhash: hash)
    entry.upsert!(OUT_DB)
  end

  OUT_DB.exec "commit"
end
