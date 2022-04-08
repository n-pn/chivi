require "./nvinfo_data"

class CV::ZhwenpgParser
  getter status_int = 0
  getter status_str : String { @status_int.to_s }

  def initialize(@node : Lexbor::Node, @status_int)
  end

  getter rows : Array(Lexbor::Node) { @node.css("tr").to_a }
  getter link : Lexbor::Node { rows[0].css("a").first }

  getter snvid : String { link.attributes["href"].sub("b.php?id=", "") }

  getter btitle : String { link.inner_text.strip }
  getter author : String { rows[1].css(".fontwt").first.inner_text.strip }

  getter bcover : String { @node.css("img").first.attributes["data-src"] }

  getter bgenre : String { rows[2].css(".fontgt").first.inner_text }
  getter genres : Array(String) { [bgenre.empty? ? "其他" : bgenre] }

  getter bintro : Array(String) do
    TextUtil.split_html(rows[4]?.try(&.inner_text("\n")) || "")
  end

  getter update_str : String { rows[3].css(".fontime").first.inner_text }
  getter update_int : Int64 { (TimeUtil.parse_time(update_str) + 24.hours).to_unix }
end

class CV::ZhwenpgSeed
  DIR = "_db/.cache/zhwenpg/pages"
  # ::FileUtils.mkdir_p(DIR)

  @seed = NvinfoData.new("var/nvinfos/zhwenpg/0")
  @done = Set(String).new

  def init!(pages = 1, status = 0)
    1.upto(3) { |page| init_page!(page, 1) }
    1.upto(11) { |page| init_page!(page, 0) }
    @seed.save!(clean: true)
  end

  def init_page!(page = 1, status = 0)
    puts "\n[-- Page: #{page} (status: #{status}) --]".colorize.light_cyan

    file = "#{DIR}/#{page}-#{status}.html"
    return unless atime = File.info?(file).try(&.modification_time.to_unix)

    page = Lexbor::Parser.new(File.read(file))
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
    NvinfoData.print_stats("yousuu")
    @seed.seed!(force: force, index: index)
  end
end

init = 0
seed = 1

OptionParser.parse(argv) do |parser|
  parser.banner = "Usage: zhwenpg_seed [arguments]"
  parser.on("-i INIT", "Init mode: 0 => skip, 1 => only updated, 2 => reinit all") { |x| init = x.to_i }
  parser.on("-s SEED", "Seed mode: 0 => skip, 1 => only updated, 2 => reseed all") { |x| seed = x.to_i }

  parser.invalid_option do |flag|
    STDERR.puts "ERROR: `#{flag}` is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

task = CV::ZhwenpgSeed.new
task.init!(redo: init == 2) if init > 0
task.seed!(force: seed == 2) if seed > 0