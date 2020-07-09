require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/_utils/html_utils"
require "../../src/_utils/file_utils"
require "../../src/_utils/time_utils"
require "../../src/_utils/text_utils"

require "../../src/kernel/book_info"
# require "../../src/kernel/book_meta"

require "../../src/kernel/order_map"

require "../../src/snipes/remote_seed"

ACCESS = OrderMap.load("book_access", cache: false, preload: true)
UPDATE = OrderMap.load("book_update", cache: false, preload: true)
WEIGHT = OrderMap.load("book_weight", cache: false, preload: true)
RATING = OrderMap.load("book_rating", cache: false, preload: true)

module MapZhwenpg
  extend self

  DIR = File.join("var", ".book_cache", "zhwenpg", "pages")

  BLACKLIST_FILE = File.join("etc", "title-blacklist.txt")
  BLACKLIST_DATA = Set(String).new File.read_lines(BLACKLIST_FILE)

  RATING_FILE = File.join("etc", "bookdb", "fix-ratings.json")
  RATING_TEXT = File.read(RATING_FILE)
  RATING_DATA = Hash(String, Tuple(Int32, Float32)).from_json RATING_TEXT

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

  def should_skip?(title : String)
    BLACKLIST_DATA.includes?(title)
  end

  def parse_page!(page = 1, status = 0)
    puts "- PAGE: #{page}"

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
    puts "-- FRESH --".colorize(:yellow)
    {Random.rand(50..100), Random.rand(50..70)/10}
  end

  def fetch_score(caption : String)
    RATING_DATA[caption]? || {0, 0_f32}
  end

  def parse_info!(node, status, index = "1/1") : Void
    rows = node.css("tr").to_a

    link = rows[0].css("a").first
    sbid = link.attributes["href"].sub("b.php?id=", "")

    title = link.inner_text.strip
    author = rows[1].css(".fontwt").first.inner_text.strip

    return if should_skip?(title)
    info = BookInfo.find_or_create(title, author, cache: false)

    genre = rows[2].css(".fontgt").first.inner_text
    info.set_genre(genre)
    info.add_tag(genre)

    caption = "#{title}--#{author}"
    voters, rating = fetch_score(caption)

    info.voters = voters
    info.rating = rating
    info.fix_weight

    fresh = info.yousuu_url.empty?
    info.shield = 1 if fresh

    if (intro = rows[4]?) && info.intro_zh.empty?
      intro_text = Utils.split_text(intro.inner_text("\n"))
      # intro_text = Engine.tradsim(intro_text)
      info.intro_zh = intro_text.join("\n")
    end

    info.status = status
    info.add_cover(node.css("img").first.attributes["data-src"])

    info.add_seed("zhwenpg", 0)
    latest_node = rows[3].css("a[target=_blank]").first
    latest_text = latest_node.inner_text

    latest_link = latest_node.attributes["href"]
    latest_scid = latest_link.sub("r.php?id=", "")

    mftime = parse_time(rows[3].css(".fontime").first.inner_text)
    seed = info.update_seed("zhwenpg", sbid, latest_scid, mftime) do |seed|
      seed.chap_text = latest_text
    end

    info.mftime = seed.mftime

    ACCESS.upsert(info.uuid, info.mftime)
    UPDATE.upsert(info.uuid, info.mftime)
    WEIGHT.upsert(info.uuid, info.weight)
    RATING.upsert(info.uuid, info.scored)

    info.save! if info.changed?

    expiry = Time.utc - Time.unix_ms(mftime)
    expiry = expiry > 24.hours ? expiry - 24.hours : expiry

    remote = RemoteSeed.new("zhwenpg", sbid, expiry: expiry, freeze: true)
    chaps = remote.emit_chaps
    chaps.save! if chaps.changed?

    color = fresh ? :green : :blue
    puts "- <#{index.colorize(color)}> [#{info.uuid}] #{caption.colorize(color)}"
  end

  TIME = Time.utc.to_unix_ms
  DATE = TIME - 24.hours.total_milliseconds.to_i64

  private def parse_time(time : String)
    mftime = Utils.parse_time(time).to_unix_ms
    return mftime if mftime <= DATE
    TIME
  end
end

1.upto(3) { |page| MapZhwenpg.parse_page!(page, status: 1) }
1.upto(12) { |page| MapZhwenpg.parse_page!(page, status: 0) }

ACCESS.save!
UPDATE.save!
RATING.save!
WEIGHT.save!
