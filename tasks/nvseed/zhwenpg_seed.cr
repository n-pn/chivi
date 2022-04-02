require "./init_nvinfo"

class CV::ZhwenpgParser
  getter status = 0

  def initialize(@node : Myhtml::Node, @status)
  end

  getter rows : Array(Myhtml::Node) { @node.css("tr").to_a }
  getter link : Myhtml::Node { rows[0].css("a").first }

  getter snvid : String { link.attributes["href"].sub("b.php?id=", "") }

  getter btitle : String { link.inner_text.strip }
  getter author : String { rows[1].css(".fontwt").first.inner_text.strip }

  getter bcover : String { @node.css("img").first.attributes["data-src"] }

  getter bgenre : String { rows[2].css(".fontgt").first.inner_text }
  getter genres : Array(String) { [bgenre.empty? ? "其他" : bgenre] }

  getter bintro : Array(String) do
    TextUtil.split_html(rows[4]?.try(&.inner_text("\n")) || "")
  end

  getter update : String { rows[3].css(".fontime").first.inner_text }
  getter mftime : Int64 { (TimeUtil.parse_time(update) + 24.hours).to_unix }
end

class CV::ZhwenpgSeed
  DIR = "_db/.cache/zhwenpg/pages"
  # ::FileUtils.mkdir_p(DIR)

  @seed = InitNvinfo.new("zhwenpg")
  @done = Set(String).new

  def init!(pages = 1, status = 0)
    1.upto(3) { |page| init_page!(page, 1) }
    1.upto(11) { |page| init_page!(page, 0) }
    @seed.save_stores!
  end

  def init_page!(page = 1, status = 0)
    puts "\n[-- Page: #{page} (status: #{status}) --]".colorize.light_cyan

    file = "#{DIR}/#{page}-#{status}.html"
    return unless atime = File.info?(file).try(&.modification_time.to_unix)

    page = Myhtml::Parser.new(File.read(file))
    nodes = page.css(".cbooksingle").to_a[2..-2]

    nodes.each do |node|
      parser = ZhwenpgParser.new(node, status)
      snvid = parser.snvid

      # make sure status is not rewrite
      next if @done.includes?(snvid)
      @done.add(snvid)

      @seed.add!(parser, snvid, atime)
    rescue err
      puts "ERROR: #{err}".colorize.red
      puts err.inspect_with_backtrace.colorize.red
    end
  end

  def seed!
    @seed.seed_all!(only_cached: false)
  end
end

worker = CV::ZhwenpgSeed.new
worker.init! if ARGV.includes?("-i")
worker.seed!
