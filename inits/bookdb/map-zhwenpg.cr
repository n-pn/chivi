require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/crawls/models/zh_info"
require "../../src/crawls/models/zh_stat"
require "../../src/crawls/utils/html_utils"
require "../../src/crawls/utils/file_utils"

def extract_info(dom, label = "1/1")
  rows = dom.css("tr").to_a

  link = rows[0].css("a").first
  bsid = link.attributes["href"].sub("b.php?id=", "")

  info = ZhInfo.new("zhwenpg", bsid)

  info.title = link.inner_text.strip
  info.author = rows[1].css(".fontwt").first.inner_text.strip

  info.genre = rows[2].css(".fontgt").first.inner_text
  info.cover = dom.css("img").first.attributes["data-src"]

  utime = rows[3].css(".fontime").first.inner_text
  info.mtime = Time.parse(utime, "%F", LOCATION).to_unix_ms

  if intro = rows[4]?
    info.intro = intro.inner_text("\n")
  end

  info
end

PAGE_URL = "https://novel.zhwenpg.com/?page=%i"
LOCATION = Time::Location.fixed(3600 * 8)

def fetch_page(page = 1)
  puts "PAGE: #{page}"

  file = "data/inits/txt-inp/zhwenpg/pages/#{page}.html"
  url = PAGE_URL % page

  unless html = Utils.read_file(file, expiry: 24.hours)
    html = Utils.fetch_html(url)
    File.write(file, html)
  end

  doc = Myhtml::Parser.new(html)
  items = doc.css(".cbooksingle").to_a[2..-2]
  items.map_with_index do |item, idx|
    extract_info(item, "#{idx + 1}/#{items.size}")
  end
end

DONE_URL = "https://novel.zhwenpg.com/index.php?page=%i&genre=1"

def fetch_done(page = 1)
  puts "DONE PAGE: #{page}"

  file = "data/inits/txt-inp/zhwenpg/pages/#{page}-done.html"
  url = DONE_URL % page

  unless html = Utils.read_file(file, expiry: 24.hours)
    html = Utils.fetch_html(url)
    File.write(file, html)
  end

  doc = Myhtml::Parser.new(html)
  items = doc.css(".cbooksingle").to_a[2..-2]

  items.map do |item|
    rows = item.css("tr").to_a
    link = rows[0].css("a").first
    link.attributes["href"].sub("b.php?id=", "")
  end
end

sitemap = {} of String => NamedTuple(bsid: String, title: String, author: String, mtime: Int64)

infos = [] of ZhInfo?
1.upto(12) { |page| infos.concat(fetch_page(page)) }

dones = Set(String).new
1.upto(2) { |page| dones.concat(fetch_done(page)) }

puts "BOOKS: #{infos.size}, DONES: #{dones}"

INFO_DIR = File.join("data", "appcv", "zhinfos", "zhwenpg")
FileUtils.mkdir_p(INFO_DIR)

STAT_DIR = File.join("data", "appcv", "zhstats")

ratings_txt = File.read("data/inits/txt-inp/zhwenpg/ratings.json")
ratings_map = Hash(String, Tuple(Int32, Float64)).from_json ratings_txt

ignores = {
  "我有一座恐怖屋--我会修空调",
  "恐怖修仙世界--龙蛇枝",
  "恐怖复苏--佛前献花",
  "极品全能学生--花都大少",
  "民国谍影--寻青藤",
}

checked_txt = File.read("data/appcv/sitemap/yousuu.json")
checked_map = Hash(String, NamedTuple(title: String)).from_json(checked_txt)

infos.each do |info|
  next unless info
  next if ignores.includes?(info.label)

  info.state = 1 if dones.includes?(info.bsid)

  # puts info.to_pretty_json

  info_file = File.join(INFO_DIR, "#{info.bsid}.json")
  File.write(info_file, info.to_pretty_json)

  sitemap[info.hash] = {
    bsid:   info.bsid,
    title:  info.title,
    author: info.author,
    mtime:  info.mtime,
  }

  next if checked_map.has_key?(info.hash)

  stat_file = File.join(STAT_DIR, "#{info.hash}.json")

  stat = ZhStat.new

  stat.title = info.title
  stat.author = info.author

  stat.status = info.state
  stat.shield = 1

  votes, score = ratings_map[info.label]? || {Random.rand(50..100), Random.rand(50..70)/10}

  stat.votes = votes
  stat.score = score
  stat.tally = (votes * score * 2).round / 2

  files = "data/inits/txt-tmp/zhtexts/zhwenpg/#{info.bsid}/*.txt"
  stat.word_count = Dir.glob(files).map { |file| File.read(file).size }.sum

  File.write(stat_file, stat.to_pretty_json)
end

File.write "data/appcv/sitemap/zhwenpg.json", sitemap.to_pretty_json
