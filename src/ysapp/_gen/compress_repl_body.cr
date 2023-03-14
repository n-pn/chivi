TXT_DIR = "var/ysapp/repls-txt"
ZIP_DIR = "var/ysapp/repls-zip"

Dir.glob("#{TXT_DIR}/*-zh").each do |dir_path|
  zip_path = dir_path.sub(TXT_DIR, ZIP_DIR) + ".zip"
  puts "#{dir_path} => #{zip_path}"

  `zip -urjyoq '#{zip_path}' '#{dir_path}'`
end

Dir.glob("#{TXT_DIR}/*-vi").each do |dir_path|
  zip_path = dir_path.sub(TXT_DIR, ZIP_DIR) + ".zip"
  puts "#{dir_path} => #{zip_path}"

  `zip -urjyoq '#{zip_path}' '#{dir_path}'`
end
