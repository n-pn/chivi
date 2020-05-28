files = Dir.glob("web/upload/covers/*.jpg")

files.each do |inp_file|
  puts inp_file
  out_file = inp_file.sub(".jpg", ".webp").sub("covers", "images")
  `magick "#{inp_file}" -quality 85 #{out_file}`
end
