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
  ::FileUtils.mkdir_p("_db/.cache/zhwenpg/pages")

  getter meta = Seeding.new("zhwenpg")
  @checked = Set(String).new

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
    atime = Seeding.get_atime(file) || Time.utc.to_unix

    doc = Myhtml::Parser.new(html)
    nodes = doc.css(".cbooksingle").to_a[2..-2]
    nodes.each_with_index(1) do |node, idx|
      parser = ZhwenpgParser.new(node)
      snvid = parser.snvid

      next if @checked.includes?(snvid)
      @checked.add(snvid)

      btitle, author = parser.btitle, parser.author
      puts "\n<#{idx}/#{nodes.size}}> {#{snvid}} [#{btitle}  #{author}]"

      @meta._index.set!(snvid, [atime.to_s, btitle, author])

      @meta.set_intro(snvid, parser.bintro)
      @meta.genres.set!(snvid, parser.bgenre)
      @meta.bcover.set!(snvid, parser.bcover)

      @meta.update.set!(snvid, parser.mftime)
      @meta.status.set!(snvid, status)
    rescue err
      puts "ERROR: #{err}".colorize.red
    end
  end

  def seed!
    @checked.to_a.each_with_index(1) do |snvid, idx|
      bhash, btitle, author = @meta.upsert!(snvid, fixed: false)

      if NvOrders.get_voters(bhash) == 0
        voters, rating = get_ratings(btitle, author)
        NvOrders.set_scores!(bhash, voters, rating)
      end

      puts "- <#{idx}/#{@checked.size}> [#{bhash}] saved!".colorize.yellow

      @meta.upsert_chinfo!(bhash, snvid, mode: 0)
      NvInfo.save!(clean: false)
    end

    NvInfo.save!(clean: false)
  end

  RATINGS = ValueMap.new("src/appcv/nv_info/_fixes/ratings.tsv", mode: 2)

  private def get_ratings(btitle : String, author : String)
    if vals = RATINGS.get("#{btitle}  #{author}")
      {vals[0].to_i, vals[1].to_i}
    else
      {Random.rand(30..100), Random.rand(50..70)}
    end
  end
end

worker = CV::Seeds::MapZhwenpg.new
puts "\n[-- Load indexes --]".colorize.cyan.bold

1.upto(3) { |page| worker.init!(page, status: 1) }
1.upto(11) { |page| worker.init!(page, status: 0) }
worker.meta.save!(clean: true)
worker.seed!
