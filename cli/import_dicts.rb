require "fileutils"

INP = File.join("var", "._old_info", "cv_dicts")
OUT = File.join("var", "dictdb")

files = Dir.glob("#{INP}/core_user/*.guest.dic")
files.each do |file|
  name = File.basename(file, ".guest.dic")
  out_file = "#{OUT}/#{name}.appcv.fix"

  FileUtils.cp(file, out_file)
  FileUtils.cp(file, out_file.sub("appcv", "local"))
rescue
  puts file
end


files = Dir.glob("#{INP}/book_user/*.guest.dic")
files.each do |file|
  name = File.basename(file, ".guest.dic")
  name = name.ljust(8, '0')
  out_file = "#{OUT}/unique/#{name}.appcv.fix"

  FileUtils.cp file, out_file
  FileUtils.cp(file, out_file.sub("appcv", "local"))
rescue
  puts file
end
