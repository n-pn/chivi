require "file_utils"
require "../src/libcv/library"

INP = File.join("var", "libcv", ".backup", "lexicon")
OUT = File.join("var", "libcv", "lexicon")

def copy_files(dir)
  files = Dir.glob("#{INP}/#{dir}/*.log")
  files.each do |file|
    next if File.basename(file, ".log").includes?(".")
    FileUtils.cp file, file.sub(INP, OUT)
  rescue err
    puts err
    puts file
  end
end

def update_dicts(type)
  Libcv::UserDict.ext = type

  Libcv::Library.generic.save!
  Libcv::Library.suggest.save!
  Libcv::Library.hanviet.save!

  Dir.glob("#{OUT}/uniq/*.#{type}").each do |file|
    name = File.basename(file, ".#{type}")
    next if name.includes?(".")
    Libcv::UserDict.load!("uniq/#{name}").save!
  rescue err
    puts err
    puts file
  end
end

system "rsync -azi nipin@ssh.nipin.xyz:web/chivi/var/libcv/lexicon var/libcv/.backup"

copy_files("core")
copy_files("uniq")

update_dicts("log")
