require "json"
require "colorize"
require "file_utils"

require "../../src/crawls/yousuu_info"

files = Dir.glob("data/txt-inp/yousuu/infos/*.json")
puts "- input: #{files.size} entries".colorize(:blue)

infos = Hash(String, ZhInfo).new

INFO_DIR = File.join("data", "appcv", "zhinfos")
STAT_DIR = File.join("data", "appcv", "zhstats")
FileUtils.mkdir_p(STAT_DIR)

existed = Set(String).new
special = Set(String).new

files.each do |file|
  if parser = YousuuInfo.load!(file)
    info = parser.get_info!

    existed << "#{info.bsid}--#{info.title}--#{info.author}"
    special << info.title if info.title =~ /\(.+\)$/

    next if info.title.empty? || info.author.empty?

    if old_info = infos[info.hash]?
      puts info.label
      next if old_info.mtime < info.mtime
    end

    infos[info.hash] = info

    info_dir = File.join(INFO_DIR, info.hash)
    FileUtils.mkdir_p(info_dir)

    info_file = File.join(info_dir, "yousuu.json")
    File.write(info_file, info.to_pretty_json)

    stat = parser.get_stat!
    next unless stat.shield == 0 && stat.score > 0
    stat_file = File.join(STAT_DIR, "#{info.hash}.json")
    File.write(stat_file, stat.to_pretty_json)
  end
rescue err
  puts "#{file} err: #{err}".colorize(:red)
end

puts "TOTAL: #{existed.size}, PICKED: #{infos.size}"
File.write "data/appcv/sitemap/yousuu.txt", existed.to_a.join("\n")
File.write "src/crawls/fixes/keep-titles.txt", special.to_a.join("\n")
