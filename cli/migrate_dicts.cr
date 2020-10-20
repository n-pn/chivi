require "file_utils"
require "../src/engine/library"

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
  Engine::UserDict.ext = type

  Engine::Library.generic.save!
  Engine::Library.suggest.save!
  Engine::Library.hanviet.save!

  Dir.glob("#{OUT}/uniq/*.#{type}").each do |file|
    name = File.basename(file, ".#{type}")
    next if name.includes?(".")
    Engine::UserDict.load!("uniq/#{name}").save!
  rescue err
    puts err
    puts file
  end
end

system "rsync -azi nipin@ssh.nipin.xyz:web/chivi/var/libcv/lexicon var/libcv/.backup"

copy_files("core")
copy_files("uniq")

update_dicts("log")
