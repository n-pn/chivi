require "option_parser"

require "../../src/utils/path_utils"
require "../../src/utils/http_utils"

require "../../src/tabkv/value_map"
require "../../src/seeds/rm_nvinfo"

class CV::PrefetchInfoHtml
  def initialize(@sname : String)
    @encoding = HttpUtils.encoding_for(@sname)
  end

  def run!(upper = 0, cr_mode = 0, threads = 0)
    RmNvInfo.mkdir!(@sname) # ensure the `cache` folder exists

    upper = remote_upper_snvid.to_i if upper < 1
    queue = build_queue!(upper, cr_mode) # find missing info pages

    threads = default_max_threads if threads < 1
    threads = queue.size if threads > queue.size

    puts "[#{@sname}/#{upper}, missing: #{queue.size}, workers: #{threads}]".colorize.cyan.bold
    puts

    channel = Channel(Nil).new(threads)
    queue.each_with_index(1) do |(link, file), idx|
      spawn do
        html = HttpUtils.get_html(link, @encoding, label: "#{idx}/#{queue.size}")
        HttpUtils.save_html(file, html)
        sleep random_throttle_time.milliseconds # throttling


      rescue err
        puts err
      ensure
        channel.send(nil)
      end

      channel.receive if idx > threads
    end

    threads.times { channel.receive }
  end

  # cr_mode:
  # - 0: skip id if existed in `.cache` folder or `_index` file
  # - 1: skip id if existed in `.cache` folder
  # - 2: skip id if existed in `_index` file

  def build_queue!(upper : Int32, cr_mode : Int32)
    snvids = (1..upper).map(&.to_s)

    if cr_mode != 1 # cr_mode = 0 or 2
      index = ValueMap.new(PathUtils.seeds_map(@sname, "_index"))
      snvids -= index.data.keys
    end

    if cr_mode < 2 # cr_mode = 0 or 1
      dir, ext = PathUtils.cache_dir(@sname, "infos"), ".html.gz"
      existed = Dir.glob("#{dir}/*#{ext}").map { |f| File.basename(f, ext) }
      snvids -= existed
    end

    snvids.map do |snvid|
      file = RmSpider.nvinfo_file(@sname, snvid, gzip: true)
      link = RmSpider.nvinfo_link(@sname, snvid)
      {link, file}
    end
  end

  getter remote_upper_snvid : String do
    link = RmSpider.index_url(@sname)
    file = PathUtils.cache_file(@sname, "index.html.gz")

    html = HttpUtils.load_html(link, file, ttl: 12.hours, encoding: @encoding)
    rdoc = Myhtml::Parser.new(html)

    case @sname
    when "hetushu"
      href = rdoc.css("#list a:first-of-type").first.attributes["href"]
      File.basename(File.dirname(href))
    when "nofff"
      href = rdoc.css("#newscontent_n .s2 > a").first.attributes["href"]
      File.basename(href)
    when "rengshu", "xbiquge", "biqubao", "bxwxorg", "shubaow"
      href = rdoc.css("#newscontent > .r .s2 > a").first.attributes["href"]
      File.basename(href)
    when "bqg_5200", "paoshu8"
      href = rdoc.css("#newscontent > .r .s2 > a").first.attributes["href"]
      File.basename(href).split("_").last
    when "5200"
      href = rdoc.css(".up > .r .s2 > a").first.attributes["href"]
      File.basename(href).split("_").last
    when "duokan8"
      href = rdoc.css(".recommend-list ul:not([class]) a:first-of-type").first.attributes["href"]
      File.basename(href).split("_").last
    else
      raise "Unsupported source name!"
    end
  end

  private def default_max_threads
    case @sname
    when "zhwenpg", "shubaow"           then 1
    when "paoshu8", "69shu", "bqg_5200" then 3
    when "hetushu", "duokan8"           then 6
    else                                     10
    end
  end

  private def random_throttle_time
    case @sname
    when "shubaow"  then Random.rand(1000..2000)
    when "zhwenpg"  then Random.rand(500..1000)
    when "bqg_5200" then Random.rand(100..500)
    else                 Random.rand(10..50)
    end
  end
end

# def display_upper_snvids
#   seeds = {
#     "hetushu", "rengshu",
#     "xbiquge", "biqubao",
#     "5200", "duokan8",
#     "nofff", "bqg_5200",
#     "bxwxorg", "shubaow",
#   }

#   seeds.each do |sname|
#     print "- #{sname} upper: "
#     puts CV::PrefetchInfoHtml.new(sname).remote_upper_snvid
#   end
# end

def run!(argv = ARGV)
  sname, upper = "hetushu", 0
  cr_mode, threads = 1, 0

  OptionParser.parse(argv) do |parser|
    parser.banner = "Usage: map_remote [arguments]"
    parser.on("-s SNAME", "Remote name") { |x| sname = x }
    parser.on("-u UPPER", "Upper snvid") { |x| upper = x.to_i }
    parser.on("-m CR_MODE", "Crawling mode") { |x| cr_mode = x.to_i }
    parser.on("-t THREADS", "Concurrent threads") { |x| threads = x.to_i }

    parser.invalid_option do |flag|
      STDERR.puts "ERROR: `#{flag}` is not a valid option."
      STDERR.puts parser
      exit(1)
    end
  end

  worker = CV::PrefetchInfoHtml.new(sname)
  worker.run!(upper, cr_mode, threads)
end

run!(ARGV)
