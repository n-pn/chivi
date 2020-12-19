require "./_info_seeding.cr"

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
  getter cover : String { @node.css("img").first.attributes["data-src"] }

  getter mftime : String { rows[3].css(".fontime").first.inner_text }
  getter update : Time { SeedUtils.parse_time(mftime) }

  def extract_intro
    return unless node = rows[4]?
    SeedUtils.split_html(node.inner_text("\n"))
  end
end

class Chivi::ZhwenpgInfoSeeding
  getter checked = Set(String).new
  getter seeding = InfoSeeding.new("zhwenpg")

  def expiry(page : Int32 = 1)
    Time.utc - 8.hours * page
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

  def update!(page = 1, status = 0)
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
      update_info!(node, status, label: "#{idx + 1}/#{nodes.size}")
    end
  end

  def update_info!(node, status, label = "1/1") : Void
    parser = ZhwenpgParser.new(node, status)
    sbid = parser.sbid

    return if @checked.includes?(sbid)
    @checked << sbid

    author, btitle = parser.author, parser.btitle

    if @seeding._index.upsert(sbid, "#{btitle}  #{author}")
      @seeding.set_intro(sbid, parser.intro)
      @seeding.genres.upsert(sbid, parser.bgenre)
      @seeding.covers.upsert(sbid, parser.cover)
    end

    @seeding.status.upsert(sbid, status.to_s)
    @seeding.access.upsert(sbid, Time.utc.to_unix./(60).to_s)

    update_at = parser.update + 1.days
    update_at = Time.utc if update_at > Time.utc

    @seeding.update.upsert(sbid, update_at.to_unix.to_s)

    spider = RmInfo.init("zhwenpg", sbid, expiry: update_at)
    unless spider.cached? && @seeding.has_chaps?(sbid)
      chaps = spider.chlist.map { |x| "#{x.scid}\t#{x.text}" }
      @seeding.set_chaps(sbid, chaps)
    end

    puts "\n<#{label}> {#{sbid}} [#{btitle}  #{author}]"
  rescue err
    puts "ERROR: #{err}".colorize.red
  end

  def upsert_all!
    @checked.each_with_index do |sbid, idx|
      serial = @seeding.upsert_serial!(sbid) do |s|
        unless s.yousuu_bid
          author, btitle = @seeding.get_bname(sbid)
          s.zh_voters, s.zh_rating = fake_rating(author, btitle)

          s.fix_popularity
        end
      end

      source = @seeding.upsert_source!(sbid, serial.id)
      Chinfo.bulk_upsert!(source, @seeding.get_chaps(sbid))

      puts "- <#{idx + 1}/#{@checked.size}> [#{serial.hv_slug}] saved!".colorize.yellow
    end
  end

  RATING_TEXT = File.read("tasks/seeding/consts/ratings.json")
  RATING_DATA = Hash(String, Tuple(Int32, Float32)).from_json RATING_TEXT

  def fake_rating(author : String, btitle : String)
    RATING_DATA["#{btitle}--#{author}"]? || {0, 0_f32}
  end
end

worker = Chivi::ZhwenpgInfoSeeding.new
FileUtils.mkdir_p("_db/.cache/zhwenpg/pages")

puts "\n[-- Load indexes --]".colorize.cyan.bold
1.upto(3) { |page| worker.update!(page, status: 1) }
1.upto(10) { |page| worker.update!(page, status: 0) }

worker.upsert_all!
worker.seeding.save!
