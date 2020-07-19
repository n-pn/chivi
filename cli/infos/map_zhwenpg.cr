require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/common/file_util"
require "../../src/common/http_util"
require "../../src/common/time_util"
require "../../src/common/text_util"

require "../../src/kernel/book_repo"
require "../../src/kernel/chap_repo"

class MapZhwenpg
  DIR = File.join("var", ".book_cache", "zhwenpg", "pages")

  def initialize
    puts "\n[-- Load indexes --]".colorize.cyan.bold
    @sitemap = LabelMap.get_or_create("zhwenpg-infos")
    @checked = Set(String).new
  end

  def expiry(page : Int32 = 1)
    Time.utc - 4.hours * page
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

    unless html = FileUtil.read(file, expiry: expiry(page))
      html = HttpUtil.fetch_html(url, HttpUtil.encoding_for("zhwenpg"))
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

    return if @checked.includes?(sbid)
    @checked << sbid

    title = link.inner_text.strip
    author = rows[1].css(".fontwt").first.inner_text.strip

    info = BookRepo.find_or_create(title, author, fixed: false)
    return if BookRepo.blacklist?(info)

    @sitemap.upsert(sbid, "#{info.ubid}¦#{info.zh_title}¦#{info.zh_author}¦#{Time.utc.to_unix}")

    BookRepo.reset_info(info) if info.slug.empty?

    fresh = info.yousuu_bid.empty?
    BookRepo.set_shield(info, 1) if fresh

    genre = rows[2].css(".fontgt").first.inner_text
    BookRepo.set_genre(info, "zhwenpg", genre, force: false)

    cover = node.css("img").first.attributes["data-src"]
    BookRepo.set_cover(info, "zhwenpg", cover, force: false)

    if (intro = rows[4]?) && info.zh_intro.empty?
      intro_text = TextUtil.split_html(intro.inner_text("\n"))
      # intro_text = Engine.tradsim(intro_text)
      BookRepo.set_intro(info, intro_text.join("\n"), force: false)
    end

    BookRepo.set_status(info, status)

    if info.yousuu_bid.empty? && info.weight == 0
      caption = "#{title}--#{author}"
      voters, rating = fetch_score(caption)

      BookRepo.set_voters(info, voters, force: false)
      BookRepo.set_rating(info, rating, force: false)

      weight = (rating * 10).to_i64 * voters
      BookRepo.set_weight(info, weight, force: false)

      OrderMap.top_authors.upsert(info.zh_author, info.weight) if info.weight >= 2000
    end

    color = fresh ? :light_cyan : :light_blue
    puts "\n<#{index}> [#{sbid}] #{info.zh_title}--#{info.zh_author}".colorize(color)

    # info.add_seed("zhwenpg", 0)
    mftime = parse_time(rows[3].css(".fontime").first.inner_text)
    latest = latest_chap(rows[3].css("a[target=_blank]").first)

    seed = info.set_seed("zhwenpg") do |seed|
      seed.update_latest(ChapRepo.translate(latest, info.ubid), mftime)
    end

    BookRepo.set_mftime(info, seed.mftime)
    info.save! if info.changed?

    if ChapList.outdated?(info.ubid, "zhwenpg", Time.unix_ms(info.mftime))
      expiry = Time.unix_ms(mftime) + 1.days * status
      remote = SeedInfo.init("zhwenpg", sbid, expiry: expiry, freeze: true)

      list = ChapList.get_or_create(info.ubid, "zhwenpg")
      list = ChapRepo.update_list(list, remote)

      list.save! if list.changed?
    end
  rescue err
    puts "ERROR: #{err.colorize.red}!"
  end

  def latest_chap(node)
    link = node.attributes["href"]
    scid = link.sub("r.php?id=", "")
    text = node.inner_text
    ChapInfo.new(scid, text)
  end

  TIME = Time.utc.to_unix
  DATE = TIME - 24.hours.total_milliseconds.to_i64

  private def parse_time(time : String)
    mftime = TimeUtil.parse(time).to_unix
    mftime <= DATE ? mftime : TIME
  end

  def save_indexes!
    puts "\n[-- Save indexes --]".colorize.cyan.bold

    OrderMap.flush!
    LabelMap.flush!
    TokenMap.flush!

    @sitemap.save!
  end
end

worker = MapZhwenpg.new

1.upto(3) { |page| worker.parse_page!(page, status: 1) }
1.upto(12) { |page| worker.parse_page!(page, status: 0) }

worker.save_indexes!
