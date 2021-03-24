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

  getter mftime : Int64 do
    update_str = rows[3].css(".fontime").first.inner_text
    updated_at = TimeUtils.parse_time(update_str) + 24.hours

    updated_at = Time.utc if updated_at > Time.utc
    updated_at.to_unix
  end
end

class CV::Seeds::MapZhwenpg
  getter meta = InfoSeed.new("zhwenpg")

  def initialize
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
    atime = InfoSeed.get_atime(file) || Time.utc.to_unix

    doc = Myhtml::Parser.new(html)
    nodes = doc.css(".cbooksingle").to_a[2..-2]
    nodes.each_with_index(1) do |node, idx|
      parser = ZhwenpgParser.new(node)
      snvid = parser.snvid

      next if @mftimes.has_key?(snvid)
      @mftimes[snvid] = parser.mftime

      btitle, author = parser.btitle, parser.author
      puts "\n<#{idx}/#{nodes.size}}> {#{snvid}} [#{btitle}  #{author}]"

      if @meta._index.set!(snvid, [atime.to_s, btitle, author])
        @meta.set_intro(snvid, parser.bintro)
        @meta.genres.set!(snvid, parser.bgenre)
        @meta.bcover.set!(snvid, parser.bcover)
        @meta.status.set!(snvid, status)
        @meta.update.set!(snvid, parser.mftime)
      end
    rescue err
      puts "ERROR: #{err}".colorize.red
    end
  end

  def seed!
    checked = @mftimes.keys

    checked.each_with_index(1) do |snvid, idx|
      nvinfo, existed = @meta.upsert!(snvid)
      fake_rating!(nvinfo, snvid) if nvinfo._meta.ival("voters") == 0

      bslug = nvinfo._meta.fval("bslug")
      colored = existed ? :yellow : :green

      puts "- <#{idx}/#{checked.size}> [#{bslug}] saved!".colorize(colored)
      nvinfo.save!(clean: false)
    end

    NvIndex.save!(clean: true)
  end

  FAKE_RATING = ValueMap.new("tasks/seeding/fake_ratings.tsv", mode: 2)

  def fake_rating!(nvinfo : Nvinfo, snvid : String)
    btitle = nvinfo._meta.fval("btitle")
    author = nvinfo._meta.fval("author")

    if vals = FAKE_RATING.get("#{btitle}  #{author}")
      voters, rating = vals[0].to_i, vals[1].to_i
    else
      voters, rating = Random.rand(10..50), Random.rand(40..60)
    end

    nvinfo.set_scores(voters, rating)
  end
end

worker = CV::Seeds::MapZhwenpg.new
puts "\n[-- Load indexes --]".colorize.cyan.bold

1.upto(3) { |page| worker.init!(page, status: 1) }
1.upto(11) { |page| worker.init!(page, status: 0) }
worker.meta.save!(clean: true)
worker.seed!
