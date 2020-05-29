require 'fileutils'

files = Dir.glob("web/upload/covers/*.jpg")

files.each_with_index do |inp_file, idx|
  out_file = inp_file.sub(".jpg", ".webp").sub("covers", "images")
  next if File.exists?(out_file)

  puts "- #{idx}: #{inp_file}"
  `magick "#{inp_file}" -quality 96 #{out_file}`
end

files = Dir.glob("web/upload/covers/*.jpg")

files.each_with_index do |inp_file, idx|
  out_file = inp_file.sub(".jpg", ".webp").sub("covers", "images")
  next if File.exists?(out_file)

  rem_file = inp_file.sub(".jpg", ".png")
  FileUtils.cp(inp_file, rem_file)

  puts "- #{idx}: #{rem_file}"
  `magick "#{rem_file}" -quality 96 #{out_file}`
end

Dir.glob("web/upload/covers/*.png") do |file|
  FileUtils.rm(file)
end
