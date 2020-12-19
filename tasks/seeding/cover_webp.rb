require "fileutils"

def out_path(file)
  ubid = File.basename(file).split(".").first
  "web/public/images/#{ubid}.webp"
end

def convert_image(inp_file, out_file, label)
  puts "- #{label}: #{inp_file}"
  `magick "#{inp_file}" -resize "400>x" "#{out_file}"`
end

files = Dir.glob("web/public/covers/*.{png,jpeg,gif}")
files.each_with_index do |inp_file, idx|
  out_file = out_path(inp_file)
  next if File.exists?(out_file)

  label = "<#{idx + 1}/#{files.size}>"
  convert_image(inp_file, out_file, label)
end


files = Dir.glob("web/public/covers/*.jpg")
files.each_with_index do |inp_file, idx|
  out_file = out_path(inp_file)
  next if File.exists?(out_file)

  label = "<#{idx + 1}/#{files.size}>"

  convert_image(inp_file, out_file, label)
  next if File.exists?(out_file)

  rem_file = inp_file.sub(".jpg", ".png")
  FileUtils.cp(inp_file, rem_file)

  convert_image(rem_file, out_file, label)
  FileUtils.rm(rem_file)
  next if File.exists?(out_file)

  rem_file = inp_file.sub(".jpg", ".gif")
  FileUtils.cp(inp_file, rem_file)

  convert_image(rem_file, out_file, label)
  FileUtils.rm(rem_file)
  next if File.exists?(out_file)

  FileUtils.cp("web/public/nocover.webp", out_file)
end
