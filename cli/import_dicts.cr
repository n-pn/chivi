require "file_utils"
require "../src/dictdb"

INP = File.join("var", "._old_info", "cv_dicts")
OUT = File.join("var", "dictdb")

def copy_files(type_inp, type_out = type_inp)
  files = Dir.glob("#{INP}/#{type_inp}_user/*.guest.dic")
  files.each do |file|
    name = File.basename(file, ".guest.dic")
    name = name.ljust(8, '0') if type_inp == "book"
    FileUtils.cp file, "#{OUT}/#{type_out}/#{name}.old.log"
  rescue
    puts file
  end
end

def update_dicts(type)
  UserDict.ext = type

  DictDB.generic.save!
  DictDB.suggest.save!

  Dir.glob("#{OUT}/uniq/*.#{type}").each do |file|
    name = File.basename(file, ".#{type}")
    next if name.includes?(".")
    UserDict.load!("uniq/#{name}").save!
  rescue
    puts file
  end
end

copy_files("core", "core")
copy_files("book", "uniq")

update_dicts("old.log")
update_dicts("log")
