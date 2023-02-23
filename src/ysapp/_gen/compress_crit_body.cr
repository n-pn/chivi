TXT_DIR = "var/ysapp/crits-txt"
ZIP_DIR = "var/ysapp/crits-zip"

Dir.glob("#{TXT_DIR}/*-zh").each do |dir_path|
  zip_path = dir_path.sub(TXT_DIR, ZIP_DIR) + ".zip"
  puts "#{dir_path} => #{zip_path}"

  `zip -FSrjyoq '#{zip_path}' '#{dir_path}'`
end

# Dir.glob("#{TXT_DIR}/*-vi").each do |dir_path|
#   zip_path = dir_path.sub(TXT_DIR, ZIP_DIR) + ".zip"
#   puts "#{dir_path} => #{zip_path}"

#   `zip -FSrjyoq '#{zip_path}' '#{dir_path}'`
# end
