require "json"
require "colorize"
require "file_utils"

require "../../src/crawls/yousuu_info"

files = Dir.glob("data/inits/txt-inp/yousuu/infos/*.json")
puts "- input: #{files.size} entries".colorize(:blue)

INFO_DIR = File.join("data", "appcv", "zhinfos", "yousuu")
FileUtils.mkdir_p(INFO_DIR)

STAT_DIR = File.join("data", "appcv", "zhstats")
FileUtils.mkdir_p(STAT_DIR)

special = Set(String).new
sitemap = {} of String => NamedTuple(bsid: String, title: String, author: String, mtime: Int64)

keep = 0

files.each do |file|
  if parser = YousuuInfo.load!(file)
    info = parser.get_info!
    next if info.title.empty? || info.author.empty?

    info_file = File.join(INFO_DIR, "#{info.bsid}.json")
    File.write(info_file, info.to_pretty_json)

    if mapped = sitemap[info.hash]?
      # puts info.label
      next if mapped[:mtime] < info.mtime
    end

    special << info.title if info.title =~ /\(.+\)$/
    sitemap[info.hash] = {bsid: info.bsid, title: info.title, author: info.author, mtime: info.mtime}

    # info_dir = File.join(INFO_DIR, info.hash)
    # FileUtils.mkdir_p(info_dir)

    stat = parser.get_stat!
    next if stat.score == 0

    keep += 1
    stat_file = File.join(STAT_DIR, "#{info.hash}.json")
    File.write(stat_file, stat.to_pretty_json)
  end
rescue err
  puts "#{file} err: #{err}".colorize(:red)
end

puts "TOTAL: #{sitemap.size}, KEEPS: #{keep}"
File.write "data/appcv/sitemap/yousuu.json", sitemap.to_pretty_json
File.write "src/crawls/fixes/keep-titles.txt", special.to_a.join("\n")
