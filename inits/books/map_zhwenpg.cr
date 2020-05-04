require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/models/vp_info"
require "../../src/spider/spider_util"

require "./mapping_util"

EXPIRY = 24.hours

DONE_URL = "https://novel.zhwenpg.com/index.php?page=%i&genre=1"

def fetch_done(page = 1)
  puts "DONE PAGE: #{page}"

  file = "data/inits/txt-inp/zhwenpg/pages/#{page}-done.html"
  url = DONE_URL % page

  unless html = SpiderUtil.read_file(file, expiry: EXPIRY)
    html = SpiderUtil.fetch_html(url)
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

FINISHS = Set(String).new
1.upto(2) { |page| FINISHS.concat(fetch_done(page)) }

puts "- finished: #{FINISHS.to_a}"

IGNORES = {
  "我有一座恐怖屋--我会修空调",
  "恐怖修仙世界--龙蛇枝",
  "恐怖复苏--佛前献花",
  "极品全能学生--花都大少",
  "民国谍影--寻青藤",
  "异能小神农--张家三叔",
  "从火凤凰开始的特种兵--燕草",
  "攻略极品--萨琳娜",
  "带着青山穿越--漆黑血海",
  "大刁民--仲星羽",
  "剑耀九歌--极光之北",
  "商梯--钓人的鱼",
}

RATINGS_TXT = File.read("data/inits/txt-inp/zhwenpg/ratings.json")
RATINGS_MAP = Hash(String, Tuple(Int32, Float64)).from_json RATINGS_TXT

SITEMAP = {} of String => Mapping

def random_score(label)
  puts "- new title: #{label.colorize(:yellow)}"
  {Random.rand(50..100), Random.rand(50..70)/10}
end

def extract_info(dom, idx = "1/1", maptime = Time.local) : Void
  rows = dom.css("tr").to_a

  link = rows[0].css("a").first
  bsid = link.attributes["href"].sub("b.php?id=", "")

  title = link.inner_text.strip
  author = rows[1].css(".fontwt").first.inner_text.strip

  label = "#{title}--#{author}"
  uuid = Utils.hash_id(label)

  SITEMAP[bsid] = Mapping.new(uuid, title, author)
  return if IGNORES.includes?(label)

  if File.exists?(VpInfo.file_path(uuid))
    puts "- <#{idx.colorize(:blue)}> #{title.colorize(:blue)} - #{author.colorize(:blue)}"

    info = VpInfo.load_json(uuid)
  else
    puts "- <#{idx.colorize(:green)}> #{title.colorize(:green)} - #{author.colorize(:green)}"

    info = VpInfo.new(title, author, uuid)
    votes, score = RATINGS_MAP[label]? || random_score(label)

    info.shield = 1

    info.votes = votes
    info.score = score
    info.reset_tally
  end

  if intro = rows[4]?
    # TODO: trad to sim
    info.set_intro_zh(intro.inner_text("\n"))
  end

  info.set_genre_zh(rows[2].css(".fontgt").first.inner_text)
  info.add_cover(dom.css("img").first.attributes["data-src"])

  info.set_status(FINISHS.includes?(bsid) ? 1 : 0)

  mftime = rows[3].css(".fontime").first.inner_text
  update = SpiderUtil.parse_time(mftime)
  info.set_update(update)

  info.cr_anchors["zhwenpg"] = bsid
  info.cr_updates["zhwenpg"] = update

  if info.cr_site_df.empty?
    info.cr_site_df = "zhwenpg"
    info.cr_bsid_df = bsid
  end

  VpInfo.save_json(info)
end

PAGE_URL = "https://novel.zhwenpg.com/?page=%i"

def fetch_page(page = 1)
  puts "PAGE: #{page}"

  file = "data/inits/txt-inp/zhwenpg/pages/#{page}.html"
  url = PAGE_URL % page

  unless html = SpiderUtil.read_file(file, expiry: EXPIRY)
    html = SpiderUtil.fetch_html(url)
    File.write(file, html)
  end

  maptime = Mapping.maptime(file)

  doc = Myhtml::Parser.new(html)
  items = doc.css(".cbooksingle").to_a[2..-2]
  items.each_with_index do |item, idx|
    extract_info(item, idx: "#{idx + 1}/#{items.size}", maptime: maptime)
  end
end

1.upto(12) { |page| fetch_page(page) }
Mapping.save!("zhwenpg", SITEMAP)
