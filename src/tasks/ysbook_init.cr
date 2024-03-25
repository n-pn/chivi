require "../zroot/ysbook"

DIR = "/srv/chivi/.keep/yousuu/book-infos"

yn_ids = Dir.children(DIR).sort_by!(&.to_i)

yn_ids.each_slice(500) do |slice|
  entries = [] of ZR::Ysbook

  entries = ZR::Ysbook.db.open_ro do |db|
    slice.compact_map do |yn_id|
      file = "#{DIR}/#{yn_id}/latest.json"
      next unless File.file?(file)
      puts file

      ZR::Ysbook.from_raw_json_file(file, db: db) rescue nil
    end
  end

  next if entries.empty?

  ZR::Ysbook.db.open_tx do |db|
    entries.each do |entry|
      loop do
        entry.upsert!(db: db)
        break
      rescue ex
        puts ex
        sleep 1.second
      end
    end
  end
end
