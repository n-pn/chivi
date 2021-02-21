require "./_seeding.cr"

class CV::Seeds::ZhwenpgParser
  def initialize(@node : Myhtml::Node)
  end

  getter rows : Array(Myhtml::Node) { @node.css("tr").to_a }
  getter link : Myhtml::Node { rows[0].css("a").first }

  getter snvid : String { link.attributes["href"].sub("b.php?id=", "") }

  getter author : String { rows[1].css(".fontwt").first.inner_text.strip }
  getter btitle : String { link.inner_text.strip }

  getter bcover : String { @node.css("img").first.attributes["data-src"] }
  getter bgenre : String { rows[2].css(".fontgt").first.inner_text }

  getter bintro : Array(String) do
    TextUtils.split_html(rows[4]?.try(&.inner_text("\n")) || "")
  end

  getter _utime : Int64 do
    update_str = rows[3].css(".fontime").first.inner_text
    updated_at = TimeUtils.parse_time(update_str) + 24.hours

    updated_at = Time.utc if updated_at > Time.utc
    updated_at.to_unix
  end
end

class CV::Seeds::MapZhwenpg
  def initialize
    @seeding = InfoSeed.new("zhwenpg")
    @mftimes = {} of String => Int64

    ::FileUtils.mkdir_p("_db/.cache/zhwenpg/pages")
  end

  def expiry(page : Int32 = 1)
    Time.utc - 4.hours * page
  end

  def page_link(page : Int32, status = 0)
    filter = status > 0 ? "genre" : "order"
    "https://novel.zhwenpg.com/index.php?page=#{page}&#{filter}=1"
  end

  def page_path(page : Int32, status = 0)
    "_db/.cache/zhwenpg/pages/#{page}-#{status}.html"
  end

  def init!(page = 1, status = 0)
    puts "\n[-- Page: #{page} --]".colorize.light_cyan.bold

    file = page_path(page, status)
    link = page_link(page, status)

    valid = 4.hours * page
    html = RmSpider.fetch(file, link, "zhwenpg", valid: valid, label: page.to_s)

    doc = Myhtml::Parser.new(html)
    nodes = doc.css(".cbooksingle").to_a[2..-2]
    nodes.each_with_index(1) do |node, idx|
      update!(node, status, label: "#{idx}/#{nodes.size}")
    end

    @seeding.save!(mode: :upds)
  end

  private def update!(node, status, label = "1/1") : Void
    parser = ZhwenpgParser.new(node)
    snvid = parser.snvid

    return if @mftimes.has_key?(snvid)
    @mftimes[snvid] = parser._utime

    btitle, author = parser.btitle, parser.author

    @seeding._index.add(snvid, [btitle, author])
    @seeding.set_intro(snvid, parser.bintro)
    @seeding.genres.add(snvid, parser.bgenre)
    @seeding.bcover.add(snvid, parser.bcover)
    @seeding.status.add(snvid, status)

    puts "\n<#{label}> {#{snvid}} [#{btitle}  #{author}]"
  rescue err
    puts "ERROR: #{err}".colorize.red
  end

  def seed!
    @checked.each_with_index(1) do |snvid, idx|
      bhash, existed = @seeding.upsert!(snvid)
      fake_rating!(bhash, snvid) if NvValues.voters.ival(bhash) == 0

      bslug = NvValues._index.fval(bhash)
      colored = existed ? :yellow : :green

      puts "- <#{idx}/#{@checked.size}> [#{bslug}] saved!".colorize(colored)
      if idx % 10 == 0
        Nvinfo.save!(mode: :upds)
      end
    end

    Nvinfo.save!(mode: :full)
  end

  FAKE_RATING = ValueMap.new("tasks/seeding/fake_ratings.tsv", mode: 2)

  def fake_rating!(bhash : String, snvid : String)
    btitle, author = @seeding._index.get(snvid).not_nil!

    if vals = FAKE_RATING.get("#{btitle}  #{author}")
      voters, rating = vals[0].to_i, vals[1].to_i
    else
      voters, rating = Random.rand(10..50), Random.rand(40..60)
    end

    NvValues.set_score(bhash, voters, rating)
  end
end

worker = CV::Seeds::MapZhwenpg.new
puts "\n[-- Load indexes --]".colorize.cyan.bold

1.upto(3) { |page| worker.init!(page, status: 1) }
1.upto(10) { |page| worker.init!(page, status: 0) }

worker.save!(mode: :full)
worker.seed!
