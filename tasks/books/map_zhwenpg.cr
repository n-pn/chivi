require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/bookdb/book_info"
require "../../src/_utils/file_utils"
require "../../src/_utils/parse_time"
require "../../src/spider/spider_util"

EXPIRY = 24.hours

PAGE_URL = "https://novel.zhwenpg.com/?page=%i"
DONE_URL = "https://novel.zhwenpg.com/index.php?page=%i&genre=1"

INPUT_DIR = File.join("data", ".inits", "txt-inp", "zhwenpg")

def fetch_done(page = 1)
  puts "DONE PAGE: #{page}"

  file = File.join(INPUT_DIR, "pages", "#{page}-done.html")

  url = DONE_URL % page

  unless html = Utils.read_file(file, time: EXPIRY)
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
1.upto(3) { |page| FINISHS.concat(fetch_done(page)) }

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
  "青橙年代--萧明",
  "亏成首富从游戏开始--绝不咸鱼",
}

RATINGS_TXT = File.read(File.join("tasks", "books", "fixes", "ratings.json"))
RATINGS_MAP = Hash(String, Tuple(Int32, Float64)).from_json RATINGS_TXT

def random_score(label)
  puts "-- FRESH --".colorize(:yellow)
  {Random.rand(50..100), Random.rand(50..70)/10}
end

def extract_info(dom, idx = "1/1") : Void
  rows = dom.css("tr").to_a

  link = rows[0].css("a").first
  bsid = link.attributes["href"].sub("b.php?id=", "")

  title = link.inner_text.strip
  author = rows[1].css(".fontwt").first.inner_text.strip

  label = "#{title}--#{author}"
  return if IGNORES.includes?(label)

  info = VpInfo.load(title, author)

  fresh = info.yousuu.empty?
  color = fresh ? :green : :blue
  puts "- <#{idx.colorize(color)}> \
          [#{info.uuid.colorize(color)}] #{title.colorize(color)}--#{author.colorize(color)}"

  unless info.cr_anchors.has_key?("zhwenpg")
    info.cr_anchors["zhwenpg"] = bsid
    info.cr_site_df = "zhwenpg" if info.cr_site_df.empty?

    if fresh
      unless checked = RATINGS_MAP[label]?
        puts "-- SKIP UNCHECKED --".colorize(:yellow)
        return
      end

      votes, score = checked
      info.shield = 1

      info.votes = votes
      info.score = score
      info.reset_tally
    end

    if intro = rows[4]?
      # TODO: trad to sim
      info.zh_intro = intro.inner_text("\n") if info.zh_intro.empty?
    end

    genre = rows[2].css(".fontgt").first.inner_text
    if info.zh_genre.empty?
      info.zh_genre = genre
    else
      info.add_tag(genre)
    end

    info.add_cover(dom.css("img").first.attributes["data-src"])
  end

  info.set_status(FINISHS.includes?(bsid) ? 1 : 0)

  mfdate = rows[3].css(".fontime").first.inner_text
  mftime = Utils.parse_time(mfdate).to_unix_ms
  puts "- #{title} - #{mftime}"

  info.set_mftime(mftime)
  info.cr_mftimes["zhwenpg"] = mftime

  VpInfo.save!(info)
end

def fetch_page(page = 1)
  puts "PAGE: #{page}"

  file = File.join(INPUT_DIR, "pages", "#{page}.html")
  url = PAGE_URL % page

  unless html = Utils.read_file(file, time: EXPIRY)
    html = SpiderUtil.fetch_html(url)
    File.write(file, html)
  end

  doc = Myhtml::Parser.new(html)
  items = doc.css(".cbooksingle").to_a[2..-2]
  items.each_with_index do |item, idx|
    extract_info(item, idx: "#{idx + 1}/#{items.size}")
  end
end

1.upto(12) { |page| fetch_page(page) }
