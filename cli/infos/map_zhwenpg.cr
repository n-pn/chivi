require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/_utils/html_utils"
require "../../src/_utils/file_utils"
require "../../src/_utils/time_utils"
require "../../src/_utils/text_utils"

require "../../src/kernel/book_info"
require "../../src/kernel/order_map"

require "../../src/source/remote_info"

class MapZhwenpg
  DIR = File.join("var", ".book_cache", "zhwenpg", "pages")

  def initialize
    @book_access = OrderMap.load("book_access", cache: false, preload: true)
    @book_update = OrderMap.load("book_update", cache: false, preload: true)
    @book_weight = OrderMap.load("book_weight", cache: false, preload: true)
    @book_rating = OrderMap.load("book_rating", cache: false, preload: true)

    @top_authors = OrderMap.load("top_authors")
  end

  def expiry(page : Int32 = 1)
    24.hours * page
  end

  def page_url(page : Int32, status : Int32 = 0)
    if status > 0
      "https://novel.zhwenpg.com/index.php?page=#{page}&genre=1"
    else
      "https://novel.zhwenpg.com/index.php?page=#{page}&order=1"
    end
  end

  def page_path(page : Int32, status : Int32 = 0)
    File.join(DIR, "#{page}-#{status}.html")
  end

  def parse_page!(page = 1, status = 0)
    puts "\n[-- Page: #{page} --]".colorize.light_cyan.bold

    url = page_url(page, status)
    file = page_path(page, status)

    unless html = Utils.read_file(file, time: expiry(page))
      html = Utils.fetch_html(url)
      File.write(file, html)
    end

    doc = Myhtml::Parser.new(html)
    nodes = doc.css(".cbooksingle").to_a[2..-2]
    nodes.each_with_index do |node, idx|
      parse_info!(node, status, index: "#{idx + 1}/#{nodes.size}")
    end
  end

  def random_score
    puts "-- FRESH --".colorize.yellow
    {Random.rand(50..100), Random.rand(50..70)/10}
  end

  RATING_TEXT = File.read("#{__DIR__}/fix-ratings.json")
  RATING_DATA = Hash(String, Tuple(Int32, Float32)).from_json RATING_TEXT

  def fetch_score(caption : String)
    RATING_DATA[caption]? || {0, 0_f32}
  end

  def parse_info!(node, status, index = "1/1") : Void
    rows = node.css("tr").to_a

    link = rows[0].css("a").first
    sbid = link.attributes["href"].sub("b.php?id=", "")

    title = link.inner_text.strip
    author = rows[1].css(".fontwt").first.inner_text.strip

    return if SourceUtil.blacklist?(title)
    info = BookInfo.find_or_create(title, author, cache: false)

    genre = rows[2].css(".fontgt").first.inner_text
    info.add_genre(genre)

    fresh = info.yousuu_url.empty?
    info.shield = 1 if fresh

    if info.yousuu_url.empty? && info.weight == 0
      caption = "#{title}--#{author}"
      voters, rating = fetch_score(caption)

      info.voters = voters
      info.rating = rating
      info.fix_weight

      @book_weight.upsert(info.uuid, info.weight)
      @book_rating.upsert(info.uuid, info.scored)
      @top_authors.upsert(info.author_zh, info.weight)
    end

    color = fresh ? :light_cyan : :light_blue
    puts "\n<#{index}> [#{info.uuid}] #{info.title_zh}--#{info.author_zh}".colorize(color)

    if (intro = rows[4]?) && info.intro_zh.empty?
      intro_text = Utils.split_text(intro.inner_text("\n"))
      # intro_text = Engine.tradsim(intro_text)
      info.intro_zh = intro_text.join("\n")
    end

    info.status = status
    info.add_cover(node.css("img").first.attributes["data-src"])

    latest_node = rows[3].css("a[target=_blank]").first
    latest_text = latest_node.inner_text

    latest_link = latest_node.attributes["href"]
    latest_scid = latest_link.sub("r.php?id=", "")

    latest_chap = ChapItem.new(latest_scid, latest_text)

    info.add_seed("zhwenpg", 0)
    mftime = parse_time(rows[3].css(".fontime").first.inner_text)

    seed = info.update_seed("zhwenpg", sbid, mftime, latest_chap)
    info.mftime = seed.mftime

    return unless info.changed?
    info.save!

    @book_access.upsert(info.uuid, info.mftime)
    @book_update.upsert(info.uuid, info.mftime)

    expiry = Time.utc - Time.unix_ms(mftime)
    expiry = expiry > 24.hours ? expiry - 24.hours : expiry

    remote = RemoteInfo.new("zhwenpg", sbid, expiry: expiry, freeze: true)
    remote.emit_chap_list.tap { |list| list.save! if list.changed? }
  end

  TIME = Time.utc.to_unix_ms
  DATE = TIME - 24.hours.total_milliseconds.to_i64

  private def parse_time(time : String)
    mftime = Utils.parse_time(time).to_unix_ms
    mftime <= DATE ? mftime : TIME
  end

  def save_indexes!
    puts "\n[-- Save indexes --]".colorize.cyan.bold

    @book_access.save!
    @book_update.save!
    @book_rating.save!
    @book_weight.save!
    @top_authors.save!
  end
end

worker = MapZhwenpg.new

1.upto(3) { |page| worker.parse_page!(page, status: 1) }
1.upto(12) { |page| worker.parse_page!(page, status: 0) }

worker.save_indexes!
