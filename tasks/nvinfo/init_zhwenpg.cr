require "myhtml"
require "file_utils"

require "../../src/cutil/text_utils"
require "../../src/cutil/http_utils"

require "./shared/seed_data.cr"
require "./shared/seed_util.cr"

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

  getter update : String do
    rows[3].css(".fontime").first.inner_text
  end

  # getter mftime : Int64 do
  #   updated_at = TimeUtils.parse_time(update) + 24.hours

  #   updated_at = Time.utc if updated_at > Time.utc
  #   updated_at.to_unix
  # end
end

class CV::InitZhwenpg
  ::FileUtils.mkdir_p("_db/.cache/zhwenpg/pages")

  @seed = SeedData.new("zhwenpg")
  @checked = Set(String).new

  def page_link(page : Int32, status = 0)
    filter = status > 0 ? "genre" : "order"
    "https://novel.zhwenpg.com/index.php?page=#{page}&#{filter}=1"
  end

  def page_path(page : Int32, status = 0)
    "_db/.cache/zhwenpg/pages/#{page}-#{status}.html.gz"
  end

  def crawl!(page = 1, status = 0)
    puts "\n[-- Page: #{page} (status: #{status}) --]".colorize.light_cyan.bold

    file = page_path(page, status)
    link = page_link(page, status)

    html = HttpUtils.load_html(link, file, ttl: 4.hours * page, label: page.to_s)
    atime = SeedUtil.get_mtime(file)

    parser = Myhtml::Parser.new(html)
    nodes = parser.css(".cbooksingle").to_a[2..-2]

    nodes.each_with_index(1) do |node, idx|
      parser = ZhwenpgParser.new(node)
      snvid = parser.snvid

      next if @checked.includes?(snvid)
      @checked.add(snvid)

      btitle, author = parser.btitle, parser.author
      puts "\n<#{idx}/#{nodes.size}}> {#{snvid}} [#{btitle}  #{author}]"

      @seed._index.set!(snvid, [atime.to_s, btitle, author])
      @seed.set_intro(snvid, parser.bintro)

      @seed.genres.set!(snvid, parser.bgenre)
      @seed.bcover.set!(snvid, parser.bcover)

      @seed.update.set!(snvid, parser.update)
      @seed.status.set!(snvid, status.to_s)
    rescue err
      puts "ERROR: #{err}".colorize.red
    end
  end

  def save!
    @seed.save!(clean: true)
  end
end

worker = CV::InitZhwenpg.new
1.upto(3) { |page| worker.crawl!(page, status: 1) }
1.upto(11) { |page| worker.crawl!(page, status: 0) }
worker.save!
