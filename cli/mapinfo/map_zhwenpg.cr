require "./_bookgen.cr"

class CV::ZhwenpgParser
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

class CV::MapZhwenpg
  ::FileUtils.mkdir_p("_db/.cache/zhwenpg/pages")

  def initialize
    @meta = Bookgen::Seed.new("zhwenpg")
    @checked = Set(String).new
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
    puts "\n[-- Page: #{page} (status: #{status}) --]".colorize.light_cyan.bold

    file = page_path(page, status)
    link = page_link(page, status)

    valid = 4.hours * page
    html = RmSpider.fetch(file, link, "zhwenpg", valid: valid, label: page.to_s)
    atime = Bookgen.get_atime(file) || Time.utc.to_unix

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

      @meta.update.set!(snvid, parser.mftime.to_s)
      @meta.status.set!(snvid, status.to_s)
    rescue err
      puts "ERROR: #{err}".colorize.red
    end
  end

  def save_meta!(clean = false)
    @meta.save!(clean: clean)
  end

  def seed!
    @checked.to_a.each_with_index(1) do |snvid, idx|
      bhash, btitle, author = @meta.upsert!(snvid, fixed: false)

      if NvOrders.get_voters(bhash) == 0
        voters, rating = Bookgen.get_scores(btitle, author)
        NvOrders.set_scores!(bhash, voters, rating)
      end

      puts "- <#{idx}/#{@checked.size}> [#{bhash}] saved!".colorize.yellow

      # @meta.upsert_chinfo!(bhash, snvid, mode: 0)
      NvInfo.save!(clean: false)
    end

    NvInfo.save!(clean: false)
  end
end

worker = CV::MapZhwenpg.new
puts "\n[-- Load indexes --]".colorize.cyan.bold

unless ARGV.includes?("-init")
  1.upto(3) { |page| worker.init!(page, status: 1) }
  1.upto(11) { |page| worker.init!(page, status: 0) }
  worker.save_meta!(clean: true)
end

worker.seed! unless ARGV.includes?("-seed")
