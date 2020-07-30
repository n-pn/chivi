require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/common/file_util"
require "../../src/common/http_util"
require "../../src/common/time_util"

require "../../src/kernel/book_repo"
require "../../src/kernel/chap_repo"

class MapZhwenpg
  DIR = File.join("var", ".book_cache", "zhwenpg", "pages")

  def initialize
    puts "\n[-- Load indexes --]".colorize.cyan.bold
    @sitemap = LabelMap.load("_import/sites/zhwenpg")
    @checked = Set(String).new
  end

  def expiry(page : Int32 = 1)
    Time.utc - 12.hours * page
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

    @sitemap.upsert(sbid, "#{info.ubid}¦#{info.zh_title}¦#{info.zh_author}")

    BookRepo.upsert_info(info)

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

      OrderMap.author_voters.upsert!(info.zh_author, info.voters.to_i64)
      OrderMap.author_rating.upsert!(info.zh_author, info.scored)
      OrderMap.author_weight.upsert!(info.zh_author, info.weight)
    end

    color = fresh ? :light_cyan : :light_blue
    puts "\n<#{index}> [#{sbid}] #{info.zh_title}--#{info.zh_author}".colorize(color)

    # info.add_seed("zhwenpg", 0)
    mftime = parse_time(rows[3].css(".fontime").first.inner_text)
    latest = latest_chap(rows[3].css("a[target=_blank]").first)

    info.add_seed("zhwenpg")
    info.set_seed_sbid("zhwenpg", sbid)
    info.set_seed_type("zhwenpg", 0)

    BookRepo.update_seed(info, "zhwenpg", latest, mftime)

    info.save! if info.changed?

    expiry = Time.unix_ms(info.mftime)
    remote = SeedInfo.init("zhwenpg", sbid, expiry: expiry, freeze: true)

    chlist = ChapList.get_or_create(info.ubid, "zhwenpg")
    chlist = ChapRepo.update_list(chlist, remote)

    chlist.save! if chlist.changed?
  rescue err
    puts "ERROR: #{err.colorize.red}!"
  end

  def latest_chap(node)
    link = node.attributes["href"]
    scid = link.sub("r.php?id=", "")
    text = node.inner_text
    ChapInfo.new(scid, text)
  end

  private def parse_time(time : String)
    TimeUtil.parse(time).to_unix_ms
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
