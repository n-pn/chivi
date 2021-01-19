require "fileutils"

INP_DIR = "_db/.miscs/zxcs_me/texts/fetch"
OUT_DIR = "_db/.miscs/zxcs_me/texts/unrar"

files = Dir.glob("#{INP_DIR}/*.rar")
files.sort_by! {|f| File.basename(f, ".rar").to_i }

files.each_with_index do |rar_file, index|
  size = File.size(rar_file)
  next if size < 1000

  s_bid = File.basename(rar_file, ".rar")

  out_dir = File.join(OUT_DIR, s_bid)
  FileUtils.rm_rf(out_dir) if File.exists?(out_dir)

  out_file = File.join(OUT_DIR, "#{s_bid}.txt")
  next if File.exists?(out_file)

  puts "- <#{index+1}/#{files.size}> [#{s_bid}]"
  `7z e "#{rar_file}" -o#{out_dir}`

  raise "Rar corrupted! Folder not found!" unless File.exists?(out_dir)

  txt_file = Dir.glob("#{out_dir}/*.txt").first
  raise "Rar corrupted! File not found!" unless File.exists?(txt_file)

  FileUtils.mv(txt_file, out_file)
  FileUtils.rm_rf(out_dir)
rescue => err
  puts "Error: #{err}"
  print "Delete it? "
  File.delete(rar_file) unless gets.chomp == "n"
end
