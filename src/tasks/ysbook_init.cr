require "../zroot/ysbook"

DIR = "var/.keep/yousuu/book-infos"

yn_ids = Dir.children(DIR).sort_by!(&.to_i)

yn_ids.each_slice(1000) do |slice|
  entries = [] of ZR::Ysbook

  entries = ZR::Ysbook.open_db do |db|
    slice.compact_map do |yn_id|
      file = "#{DIR}/#{yn_id}/latest.json"
      next unless File.file?(file)
      puts file

      loop do
        break ZR::Ysbook.from_raw_json_file(file, db: db)
      rescue ex : SQLite3::Exception
        puts ex
        sleep 1.second
      rescue ex
        puts ex
        break nil
      end
    end
  end

  next if entries.empty?

  ZR::Ysbook.open_tx do |db|
    entries.each do |entry|
      loop do
        break if entry.upsert!(db)
      rescue ex
        puts ex
        sleep 1.second
      end
    end
  end
end
