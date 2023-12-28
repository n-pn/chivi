# INP = "/mnt/extra/Asset/chivi_db/rzips"
# INP = "/mnt/serve/chivi.all/ztext"
INP = "/2tb/var.chivi/_prev/ztext"
OUT = "/www/var.chivi/zroot/rawtxt"

Dir.glob("#{INP}/*/*/").each do |unzip_dir|
  zip_file = unzip_dir.sub(INP, OUT).sub(/\/$/, ".zip")
  puts "#{unzip_dir} => #{zip_file}"
  `zip -rjoyqum '#{zip_file}' '#{unzip_dir}'`
end

puts `find '#{INP}' -type d -empty -print -delete`
