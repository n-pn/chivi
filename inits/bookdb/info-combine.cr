require "json"
require "colorize"
require "file_utils"

require "../../src/models/zh_stat"
require "../../src/models/zh_info"
require "../../src/models/vp_info"

STAT_DIR = File.join("data", "appcv", "zhstats")
files = Dir.glob(File.join(STAT_DIR, "*.json"))

puts "INPUT: #{files.size}"

infos = [] of VpInfo

files.each do |file|
  hash = File.basename(file, ".json")
  stat = ZhStat.from_json File.read(file)
  info = VpInfo.new(hash: hash, title_zh: stat.title, author_zh: stat.author)

  info.votes = stat.votes
  info.score = stat.score
  info.tally = stat.tally

  info.status = stat.status
  info.shield = stat.shield

  info.word_count = stat.word_count
  info.crit_count = stat.crit_count

  infos << info
end

INFO_DIR = File.join("data", "appcv", "zhinfos")
MAPS_DIR = File.join("data", "appcv", "sitemap")

alias Mapping = Hash(String, NamedTuple(bsid: String, mtime: Int64))

def update_info(list, site)
  mapfile = File.join(MAPS_DIR, "#{site}.json")
  sitemap = Mapping.from_json(File.read(mapfile))

  list.each do |info|
    if mapped = sitemap[info.hash]?
      bsid = mapped[:bsid]
      mtime = mapped[:mtime]

      if site == "yousuu"
        info.yousuu = bsid
      else
        info.crawls[site] = {bsid: bsid, mtime: mtime}

        if info.cr_site.empty?
          info.cr_site = site
          info.cr_bsid = bsid
        end
      end

      zh_file = File.join(INFO_DIR, site, "#{bsid}.#{info.hash}.json")
      zh_info = ZhInfo.from_json(File.read(zh_file))

      info.covers << zh_info.cover unless zh_info.cover.empty?

      info.intro_zh = zh_info.intro if info.intro_zh.empty?

      unless zh_info.genre.empty?
        if info.genre_zh.empty?
          info.genre_zh = zh_info.genre
        else
          info.tags_zh << zh_info.genre
        end
      end

      info.tags_zh.concat(zh_info.tags)

      if info.mtime < zh_info.mtime
        info.mtime = zh_info.mtime
      end

      if info.status < zh_info.state
        info.status = zh_info.state
      end
    end
  end

  list
end

infos = update_info(infos, "yousuu")

CRAWLS = {
  "hetushu", "jx_la", "rengshu",
  "xbiquge", "nofff", "duokan8",
  "paoshu8", "69shu", "zhwenpg",
}

CRAWLS.each do |site|
  infos = update_info(infos, site)
end

OUT_DIR = File.join("data", "appcv", "vpinfos")
FileUtils.rm_rf(OUT_DIR)
FileUtils.mkdir_p(OUT_DIR)

infos.each_with_index do |info, idx|
  # puts "- <#{idx + 1}/#{infos.size}> [#{info.hash}] #{info.title_zh}"
  File.write File.join(OUT_DIR, "#{info.hash}.json"), info.to_pretty_json
end
