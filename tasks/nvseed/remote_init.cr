require "option_parser"
require "./init_nvinfo"

class CV::SeedNvseed
  def initialize(@sname : String)
    @infos_dir = "_db/.cache/#{@sname}/infos"
    Dir.mkdir_p(@infos_dir)

    # Dir.mkdir_p(@infos_dir.sub("infos", "texts"))

    @seed = InitNvinfo.new(@sname)
    @encoding = HttpUtil.encoding_for(@sname)
  end

  def build!(upper : Int32)
    if upper < 1
      upper = extract_upper.tap { |x| puts x }.to_i
    end

    missing = [] of String
    updates = [] of String

    read_stats(upper) do |snvid, state|
      missing << snvid if state == 2
      updates << snvid if state == 0
    end

    {missing, updates}
  end

  def read_stats(upper : Int32)
    limit = 20
    channel = Channel(Tuple(String, Int32)).new(limit + 1)

    1.upto(upper) do |index|
      spawn do
        snvid = index.to_s
        fpath = "#{@infos_dir}/#{snvid}.html.gz"

        mtime = InitNvinfo.get_mtime(fpath)
        atime = @seed.get_map(:_index, snvid).ival_64(snvid)

        if mtime > 0
          channel.send({snvid, atime >= mtime ? 1 : 0})
        else
          channel.send({snvid, atime > 0 ? 3 : 2})
        end
      end

      yield channel.receive if index > limit
    end

    limit.times { yield channel.receive }
  end

  def prep!(queue : Array(String), threads = 0)
    threads = ideal_threads if threads < 1
    threads = queue.size if threads > queue.size

    puts "[#{@sname}], missing: #{queue.size}, workers: #{threads}\n".colorize.cyan.bold

    channel = Channel(Nil).new(threads)

    queue.each_with_index(1) do |snvid, index|
      channel.receive if index > threads
      load_info_html(snvid, lbl: "#{index}/#{queue.size}")
      thrott!
    rescue err
      puts err
    ensure
      channel.send(nil)
    end

    threads.times { channel.receive }
  end

  def thrott!
    # throttling if success
    case @sname
    when "shubaow"
      sleep Random.rand(1000..2000).milliseconds
    when "zhwenpg"
      sleep Random.rand(500..1000).milliseconds
    when "biqu5200"
      sleep Random.rand(100..500).milliseconds
    end
  end

  def load_info_html(snvid : String, lbl = "1/1")
    file = "#{@infos_dir}/#{snvid}.html.gz"

    GzipFile.new(file).read(ttl: 10.years) do
      url = SiteLink.info_url(@sname, snvid)
      HttpUtil.get_html(url, encoding: @encoding, lbl: lbl)
    end
  end

  def init!(queue : Array(String))
    puts "[#{@sname}], parsing: #{queue.size}\n".colorize.cyan.bold

    queue.each_with_index(1) do |snvid, idx|
      bfile = PathUtil.binfo_cpath(@sname, snvid)
      atime = InitNvinfo.get_mtime(bfile)

      entry = RemoteInfo.new(@sname, snvid, lbl: "#{idx}/#{queue.size}")
      @seed.add!(entry, snvid, atime)

      if idx % 100 == 0
        puts "- [#{@sname}]: <#{idx}/#{queue.size}>"
        @seed.save_stores!
      end
    end

    @seed.save_stores!
  end

  def extract_upper : String
    page = begin
      file = @infos_dir.sub("infos", "index.html.gz")
      link = site_index_link(@sname)
      encoding = HttpUtil.encoding_for(@sname)
      html = HttpUtil.load_html(link, file, ttl: 12.hours, encoding: encoding)
      HtmlParser.new(html)
    end

    case @sname
    when "69shu"
      href = page.attr(".ranking:nth-child(2) a:first-of-type", "href")
      File.basename(href, ".htm")
    when "hetushu"
      href = page.attr("#list a:first-of-type", "href")
      File.basename(File.dirname(href))
    when "sdyfcm"
      href = page.attr("#newscontent_n .s2 > a", "href")
      File.basename(href)
    when "rengshu", "xbiquge", "biqugee", "bxwxorg"
      href = page.attr("#newscontent > .r .s2 > a", "href")
      File.basename(href)
    when "biqu5200", "paoshu8", "shubaow"
      href = page.attr("#newscontent > .r .s2 > a", "href")
      File.basename(href).split("_").last
    when "5200"
      href = page.attr(".up > .r .s2 > a", "href")
      File.basename(href).split("_").last
    when "duokan8"
      href = page.attr(".recommend-list ul:not([class]) a:first-of-type", "href")
      File.basename(href).split("_").last
    else
      raise "Unsupported source name!"
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  private def site_index_link(sname : String) : String
    case sname
    when "69shu"    then "https://www.69shu.com/"
    when "hetushu"  then "https://www.hetushu.com/book/index.php"
    when "rengshu"  then "http://www.rengshu.com/"
    when "xbiquge"  then "https://www.xbiquge.so/"
    when "biqugee"  then "https://www.biqugee.com/"
    when "5200"     then "https://www.5200.tv/"
    when "duokan8"  then "http://www.duokan8.com/"
    when "sdyfcm"   then "https://www.sdyfcm.com/"
    when "biqu5200" then "http://www.biqu5200.net/"
    when "bxwxorg"  then "https://www.bxwxorg.com/"
    when "shubaow"  then "https://www.shubaow.net/"
    when "paoshu8"  then "http://www.paoshu8.com/"
    else                 raise "Unsupported source name!"
    end
  end

  private def ideal_threads
    case @sname
    when "zhwenpg", "shubaow"           then 1
    when "paoshu8", "69shu", "biqu5200" then 3
    when "hetushu", "duokan8"           then 6
    else                                     10
    end
  end

  def seed!(redo = false)
    @seed.seed_all!(only_cached: false)
  end

  private def get_fake_scores
    case @sname
    when "hetushu"
      [Random.rand(30..100), Random.rand(50..65)]
    else
      [Random.rand(25..50), Random.rand(40..50)]
    end
  end

  # cr_mode:
  # - 0: crawl missings, parse missing and updates/unparsed
  # - 1: crawl and parse missing
  # - 2: parse updates/unparsed only
  def self.run!(argv = ARGV)
    sname, upper = "hetushu", 0
    cr_mode, threads = 0, 0
    no_seed = false

    OptionParser.parse(argv) do |parser|
      parser.banner = "Usage: map_remote [arguments]"
      parser.on("-s SNAME", "Remote name") { |x| sname = x }
      parser.on("-u UPPER", "Upper snvid") { |x| upper = x.to_i }
      parser.on("-m CR_MODE", "Crawling mode") { |x| cr_mode = x.to_i }
      parser.on("-t THREADS", "Concurrent threads") { |x| threads = x.to_i }
      parser.on("-n", "--noseed", "Init only") { no_seed = true }

      parser.invalid_option do |flag|
        STDERR.puts "ERROR: `#{flag}` is not a valid option."
        STDERR.puts parser
        exit(1)
      end
    end

    seeder = new(sname)
    missing, updates = seeder.build!(upper)

    if cr_mode < 2
      seeder.prep!(missing, threads)
      seeder.init!(missing)
    end

    updates -= missing if sname == "jx_la"
    seeder.init!(updates) if cr_mode != 1
    seeder.seed!(true) unless no_seed
  end
end

CV::SeedNvseed.run!(ARGV)