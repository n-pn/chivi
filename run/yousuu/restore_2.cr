require "json"
require "compress/zip"

files = Dir.glob("var/ysapp/crits-zip/*-zh.zip")

output = File.open("var/ysapp/yscrits-ztext-orig.jsonl", "w")

files.each do |zip_path|
  puts zip_path
  Compress::Zip::File.open(zip_path) do |zip|
    zip.entries.each do |entry|
      yc_id = File.basename(entry.filename, ".txt")
      ztext = entry.open(&.gets_to_end)

      ztext = ztext.tr("\u0000", "\n").lines.map(&.strip).reject(&.empty?).join('\n')
      output << {yc_id: yc_id, ztext: ztext}.to_json << '\n'
    end
  end
end

output.close
