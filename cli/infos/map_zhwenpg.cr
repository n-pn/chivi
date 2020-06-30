require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/utils/html_utils"
require "../../src/utils/file_utils"
require "../../src/utils/parse_time"

require "../../src/kernel/book_info"
require "../../src/kernel/book_misc"
require "../../src/kernel/book_seed"

class ZhwenpgImporter
  DIR = File.join("var", "appcv", ".cache", "zhwenpg")

  def self.run!(lower_page = 1, upper_page = 12, expiry = 24.hours)
    importer = new(expiry)

    (lower_page..upper_page).each do |page|
      importer.extract_page(page)
    end
  end

  def initialize(@expiry : Time::Span = 24.hours)
    @finished = Set(String).new
    (1..3).each { |page| load_finished(page) }
    # puts "- finished: #{@finished.to_a}"
  end

  def load_finished(page = 1)
    puts "- COMPLETED PAGE: #{page}"

    url = "https://novel.zhwenpg.com/index.php?page=#{page}&genre=1"
    file = File.join(DIR, "pages", "#{page}-done.html")

    unless html = Utils.read_file(file, time: @expiry)
      html = Utils.fetch_html(url)
      File.write(file, html)
    end

    doc = Myhtml::Parser.new(html)
    items = doc.css(".cbooksingle").to_a[2..-2]

    items.each do |item|
      rows = item.css("tr").to_a
      link = rows[0].css("a").first
      sbid = link.attributes["href"].sub("b.php?id=", "")
      @finished << sbid
    end
  end

  def should_skip?(title : String)
    case title
    when "我有一座恐怖屋",
         "恐怖修仙世界",
         "恐怖复苏",
         "极品全能学生",
         "民国谍影",
         "异能小神农",
         "从火凤凰开始的特种兵",
         "攻略极品",
         "带着青山穿越",
         "大刁民",
         "剑耀九歌",
         "商梯",
         "青橙年代",
         "亏成首富从游戏开始"
      true
    else
      false
    end
  end

  def random_score(label : String)
    puts "-- FRESH --".colorize(:yellow)
    {Random.rand(50..100), Random.rand(50..70)/10}
  end

  def extract_page(page = 1)
    puts "- PAGE: #{page}"

    url = "https://novel.zhwenpg.com/?page=#{page}"
    file = File.join(DIR, "pages", "#{page}.html")

    unless html = Utils.read_file(file, time: @expiry)
      html = Utils.fetch_html(url)
      File.write(file, html)
    end

    doc = Myhtml::Parser.new(html)
    items = doc.css(".cbooksingle").to_a[2..-2]
    items.each_with_index do |item, idx|
      extract_info(item, idx: "#{idx + 1}/#{items.size}")
    end
  end

  def status_of(sbid : String)
    @finished.includes?(sbid) ? 1 : 0
  end

  RATINGS_TXT = File.read(File.join("etc", "bookdb", "fix-ratings.json"))
  RATINGS_MAP = Hash(String, Tuple(Int32, Float64)).from_json RATINGS_TXT

  def fetch_score(label : String)
    RATINGS_MAP[label]? || {0, 0.0}
  end

  def extract_info(dom, idx = "1/1") : Void
    rows = dom.css("tr").to_a

    link = rows[0].css("a").first
    sbid = link.attributes["href"].sub("b.php?id=", "")

    title = link.inner_text.strip
    author = rows[1].css(".fontwt").first.inner_text.strip

    label = "#{title}--#{author}"
    return if should_skip?(title)

    info = BookInfo.init!(title, author)

    genre = rows[2].css(".fontgt").first.inner_text
    info.add_genre(genre)

    voters, rating = fetch_score(label)

    info.voters = voters
    info.rating = rating
    info.fix_weight!

    BookInfo.save!(info)

    misc = BookMisc.init!(info.uuid)

    misc.prefer_seed = "zhwenpg" if misc.prefer_seed.empty?
    misc.shield = 1

    if intro = rows[4]?
      # TODO: trad to sim
      misc.intro_zh = intro.inner_text("\n") if misc.intro_zh.empty?
    end

    misc.add_cover(dom.css("img").first.attributes["data-src"])
    misc.set_status(status_of(sbid))

    mfdate = rows[3].css(".fontime").first.inner_text
    mftime = extract_time(mfdate)
    misc.set_mftime(mftime)

    BookMisc.save!(misc)

    # TODO: add book_seed

    fresh = misc.yousuu_link.empty?
    color = fresh ? :green : :blue
    puts "- <#{idx.colorize(color)}> [#{info.uuid}] #{label.colorize(color)}"
  end

  TIME = Time.utc.to_unix_ms
  DATE = TIME - 24.hours.total_milliseconds.to_i64

  private def extract_time(time : String)
    mftime = Utils.parse_time(time).to_unix_ms
    return mftime if mftime <= DATE
    return TIME
  end
end

ZhwenpgImporter.run!(1, 12)
