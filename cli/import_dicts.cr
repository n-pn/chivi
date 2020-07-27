require "file_utils"
require "../src/dictdb"

INP = File.join("var", "._old_info", "cv_dicts")
OUT = File.join("var", "dictdb")

files = Dir.glob("#{INP}/core_user/*.guest.dic")
files.each do |file|
  name = File.basename(file, ".guest.dic")

  FileUtils.cp file, "#{OUT}/core/#{name}.log"
rescue
  puts file
end

files = Dir.glob("#{INP}/book_user/*.guest.dic")
files.each do |file|
  name = File.basename(file, ".guest.dic")
  name = name.ljust(8, '0')

  FileUtils.cp file, "#{OUT}/uniq/#{name}.log"
rescue
  puts file
end

UserDict.ext = "log"
DictDB.generic.save!
DictDB.suggest.save!

Dir.glob("#{OUT}/uniq/*.log").each do |file|
  name = File.basename(file, ".log")
  next if name.ends_with?("test")
  UserDict.load!("uniq/#{name}").save!
end
