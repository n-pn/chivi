require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/shared/file_utils"
require "../../src/shared/http_utils"
require "../../src/shared/seed_utils"

require "../../src/kernel/book_repo"

class Chivi::ZhwenpgParser
  def initialize(@node : Myhtml::Node, @status : Int32)
  end

  getter rows : Array(Myhtml::Node) { @node.css("tr").to_a }
  getter link : Myhtml::Node { rows[0].css("a").first }
  getter sbid : String { link.attributes["href"].sub("b.php?id=", "") }

  getter author : String { rows[1].css(".fontwt").first.inner_text.strip }
  getter btitle : String { link.inner_text.strip }
  getter bgenre : String { rows[2].css(".fontgt").first.inner_text }

  getter intro : Array(String) { extract_intro || [] of String }
  getter cover : String { node.css("img").first.attributes["data-src"] }

  getter mftime : String { rows[3].css(".fontime").first.inner_text }
  getter update : Time { SeedUtils.parse_time(mftime) }

  def extract_intro
    return unless node = rows[4]?
    SeedUtils.split_html(node.inner_text("\n"))
  end
end

class Chivi::SeedZhwenpg
  getter checked = Set(String).new

  def expiry(page : Int32 = 1)
    Time.utc - 12.hours * page
  end

  def page_url(page : Int32, status = 0)
    if status > 0
      "https://novel.zhwenpg.com/index.php?page=#{page}&genre=1"
    else
      "https://novel.zhwenpg.com/index.php?page=#{page}&order=1"
    end
  end

  def page_path(page : Int32, status = 0)
    "_db/.cache/zhwenpg/pages/#{"#{page}-#{status}.html"}"
  end

  def parse_page!(page = 1, status = 0)
    puts "\n[-- Page: #{page} --]".colorize.light_cyan.bold

    url = page_url(page, status)
    file = page_path(page, status)

    unless html = FileUtils.read(file, expiry: expiry(page))
      html = HttpUtils.get_html(url)
      File.write(file, html)
    end

    doc = Myhtml::Parser.new(html)
    nodes = doc.css(".cbooksingle").to_a[2..-2]
    nodes.each_with_index do |node, idx|
      parse_info!(node, status, label: "#{idx + 1}/#{nodes.size}")
    end
  end

  RATING_TEXT = File.read("tasks/seeding/consts/ratings.json")
  RATING_DATA = Hash(String, Tuple(Int32, Float32)).from_json RATING_TEXT

  def fix_score(author : String, btitle : String)
    RATING_DATA["#{btitle}--#{author}"]? || {0, 0_f32}
    # {voters, rating.*(10).round / 10}
  end

  def parse_info!(node, status, label = "1/1") : Void
    parser = ZhwenpgParser.new(node, status)
    sbid = parser.sbid
    return if @checked.includes?(sbid)
    @checked << sbid

    zh_author = parser.author
    zh_btitle = parser.btitle

    serial = Serial.upsert!(zh_author, zh_btitle)
    engine = Convert.content(serial.zh_slug) # TODO: change to hv_slug

    unless serial.zh_intro || parser.intro.empty?
      serial.set_intro(parser.intro, "zhwenpg")
    end

    serial.set_bgenre(parser.bgenre)

    # .concat().uniq!
    # serial.vi_bgenres.concat(bgenres.map(&.vi_name)).uniq!

    serial.status = status if serial.status < status

    update_at = parser.update.to_unix
    serial.update_at = update_at if serial.update_at < update_at
    serial.access_at = update_at if serial.access_at < update_at

    unless serial.yousuu_bid
      voters, rating = fix_score(zh_author, zh_btitle)
      serial.zh_voters = voters
      serial.zh_rating = rating
      serial.fix_popularity
    end

    serial.save!

    puts "\n<#{label}> {#{sbid}} [#{zh_btitle}  #{zh_author}]"
  rescue err
    puts "ERROR: #{err}".colorize.red
  end
end

worker = Chivi::SeedZhwenpg.new

puts "\n[-- Load indexes --]".colorize.cyan.bold
1.upto(3) { |page| worker.parse_page!(page, status: 1) }
1.upto(10) { |page| worker.parse_page!(page, status: 0) }
