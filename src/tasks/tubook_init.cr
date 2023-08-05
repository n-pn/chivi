require "../zroot/tubook"

DIR = "var/zroot/.keep/tuishu/listBookRepository"

OUT_DB = ZR::Tubook.db

Dir.glob("#{DIR}/*.json") do |path|
  rtime = File.info(path).modification_time.to_unix

  json = File.read(path)
  hash = XXHash.xxh32(json)

  begin
    data = ZR::RawTubookList.from_json(json)
    puts "- file: #{path}, books: #{data.books.size}"
  rescue ex
    puts [ex, json]
    next
  end

  OUT_DB.exec "begin"

  data.books.each do |input|
    entry = ZR::Tubook.from_raw(input, rtime: rtime, rhash: hash)
    entry.upsert!(OUT_DB)
  end

  OUT_DB.exec "commit"
end
