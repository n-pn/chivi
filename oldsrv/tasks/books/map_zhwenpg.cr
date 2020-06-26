require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/bookdb/book_info"
require "../../src/bookdb/import/import_util"

require "../../src/_utils/file_utils"
require "../../src/_utils/parse_time"

class ZhwenpgImporter
  DIR = File.join("data", ".inits", "texts", "zhwenpg")

  def self.run!(lower_page = 1, upper_page = 12, expiry = 24.hours)
    importer = new(expiry)

    (lower_page..upper_page).each do |page|
      importer.extract_page(page)
    end
  end

  def initialize(@expiry : Time::Span = 24.hours)
    @completed = Set(String).new
    (1..3).each { |page| load_completed(page) }
    # puts "- completed: #{@completed.to_a}"
  end

  def load_completed(page = 1)
    puts "- COMPLETED PAGE: #{page}"

    url = "https://novel.zhwenpg.com/index.php?page=#{page}&genre=1"
    file = File.join(DIR, "pages", "#{page}-done.html")

    unless html = Utils.read_file(file, time: @expiry)
      html = ImportUtil.fetch_html(url)
      File.write(file, html)
    end

    doc = Myhtml::Parser.new(html)
    items = doc.css(".cbooksingle").to_a[2..-2]

    items.each do |item|
      rows = item.css("tr").to_a
      link = rows[0].css("a").first
      bsid = link.attributes["href"].sub("b.php?id=", "")
      @completed << bsid
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

  RATINGS_TXT = File.read(File.join("src", "bookdb", "_fixes", "ratings.json"))
  RATINGS_MAP = Hash(String, Tuple(Int32, Float64)).from_json RATINGS_TXT

  def extract_page(page = 1)
    puts "- PAGE: #{page}"

    url = "https://novel.zhwenpg.com/?page=#{page}"
    file = File.join(DIR, "pages", "#{page}.html")

    unless html = Utils.read_file(file, time: @expiry)
      html = ImportUtil.fetch_html(url)
      File.write(file, html)
    end

    doc = Myhtml::Parser.new(html)
    items = doc.css(".cbooksingle").to_a[2..-2]
    items.each_with_index do |item, idx|
      extract_info(item, idx: "#{idx + 1}/#{items.size}")
    end
  end

  def status_of(bsid : String)
    @completed.includes?(bsid) ? 1 : 0
  end

  def extract_info(dom, idx = "1/1") : Void
    rows = dom.css("tr").to_a

    link = rows[0].css("a").first
    bsid = link.attributes["href"].sub("b.php?id=", "")

    title = link.inner_text.strip
    return if should_skip?(title)

    author = rows[1].css(".fontwt").first.inner_text.strip
    info = VpInfo.load(title, author)

    fresh = info.yousuu.empty?
    color = fresh ? :green : :blue
    puts "- <#{idx.colorize(color)}> \
            [#{info.uuid.colorize(color)}] #{title.colorize(color)}--#{author.colorize(color)}"

    unless info.cr_sitemap.has_key?("zhwenpg")
      info.cr_sitemap["zhwenpg"] = bsid
      info.cr_site_df = "zhwenpg" if info.cr_site_df.empty?

      if fresh
        unless checked = RATINGS_MAP["#{title}--#{author}"]?
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

    info.set_status(status_of(bsid))

    mfdate = rows[3].css(".fontime").first.inner_text
    mftime = Utils.parse_time(mfdate).to_unix_ms
    puts "- #{title} - #{mftime}"

    info.set_mftime(mftime)
    info.last_times["zhwenpg"] = mftime

    VpInfo.save!(info)
  end
end

ZhwenpgImporter.run!(1, 12)
