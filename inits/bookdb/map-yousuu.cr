require "json"
require "colorize"
require "file_utils"

require "../../src/crawls/yousuu_info"

files = Dir.glob("data/inits/txt-inp/yousuu/infos/*.json").sort_by do |file|
  File.basename(file, ".json").to_i
end

puts "- input: #{files.size} entries".colorize(:blue)

INFO_DIR = File.join("data", "appcv", "zhinfos")
# FileUtils.mkdir_p(INFO_DIR)

STAT_DIR = File.join("data", "appcv", "zhstats")
FileUtils.mkdir_p(STAT_DIR)

sitemap = {} of String => NamedTuple(bsid: String, title: String, author: String, mtime: Int64)

keep_stat = 0
files.each do |file|
  if parser = YousuuInfo.load!(file)
    info = parser.get_info!
    next if info.title.empty? || info.author.empty?

    info_dir = File.join(INFO_DIR, info.hash)
    FileUtils.mkdir_p(info_dir)

    info_file = File.join(info_dir, "yousuu.json")
    File.write(info_file, info.to_pretty_json)

    if mapped = sitemap[info.hash]?
      # puts info.label
      next if mapped[:mtime] >= info.mtime
    end

    sitemap[info.hash] = {
      bsid:   info.bsid,
      title:  info.title,
      author: info.author,
      mtime:  info.mtime,
    }
    stat = parser.get_stat!
    next if stat.score == 0

    keep_stat += 1
    stat_file = File.join(STAT_DIR, "#{info.hash}.json")
    File.write(stat_file, stat.to_pretty_json)
  end
rescue err
  puts "#{file} err: #{err}".colorize(:red)
end

puts "TOTAL: #{sitemap.size}, KEEPS: #{keep_stat}"
File.write "data/appcv/sitemap/yousuu.json", sitemap.to_pretty_json
