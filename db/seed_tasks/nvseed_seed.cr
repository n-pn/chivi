require "option_parser"
require "./nvinfo_seed"

class CV::NvseedSeed
  def initialize(@sname : String)
    @encoding = HttpUtil.encoding_for(@sname)
    @cache_dir = "_db/.cache/#{@sname}/infos"
    ::FileUtils.mkdir_p(@cache_dir)

    index_path = File.join(NvseedInit::OUT_DIR % sname, "index.tsv")
    @index = Tabkv.load(index_path)
  end

  def init!(upper : Int32 = 0, mode = 0)
    missings = [] of String
    1.upto(upper) do |snvid|
      snvid = snvid.to_s

      if index = @index.get(snvid)
        next unless index[0].empty? || index[1].empty?
      end

      missings << snvid
    end

    workers = ideal_threads
    workers = missings.size if workers > missing.size
    channel = Channel(Nil).new(workers)

    missings.each_with_index(1) do |snvid, idx|
      channel.receive if idx > workers

      spawn do
        entry = NvseedInit.load(@sname, snvid, mode: mode)
        @index.set!(snvid, [entry.btitle, entry.author])
      ensure
        channel.send(nil)
      end
    end

    workers.times { channel.receive }
  end

  def seed!(upper : Int32 = 0, mode = 0)
    upper = extract_upper.to_i if upper < 1

    1.upto(upper) do |snvid|
      NvinfoSeed.log(@sname, "#{ynvid}/#{upper}") if ynvid % 1000 == 0
      seed_entry!(snvid, mode: mode)
    end
  end

  def seed_entry!(snvid : Int32, mode = 0)
    return unless entry = load_entry(snivd.to_s, mode: mode)
    nvinfo = NvinfoSeed.seed!(entry) do |x|
      x.add_nvseed(SnameMap.map_int(@sname))
    end

    Nvseed.upsert!(nvinfo, @sname, snvid)
  end

  def load_entry(snvid : String, mode = 0)
    if index = @index.get(snvid)
      btitle, author = index
    else
    end

    btitle, author = BookUtil.fix_names(btitle, author)
    return unless good?(bitle, author)

    entry.btitle = btitle
    entry.author = author
    entry
  rescue err
    puts err
  end

  def good?(btitle : String, author : String)
    return true if @sname.in?("hetushu", "zhwenpg", "staff", "users")
    return false unless NvinfoSeed.get_author(author)
    return true if @sname.in?("rengshu", "69shu", "biqugee")
    !!Nvinfo.get(author, btitle)
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

  # cr_mode:
  # - 0: crawl missings, parse missing and updates/unparsed
  # - 1: crawl and parse missing
  # - 2: parse updates/unparsed only
  def self.run!(argv = ARGV)
    sname, upper = "hetushu", 0
    cr_mode, threads = 0, 0
    no_seed = false
    redo = false

    OptionParser.parse(argv) do |parser|
      parser.banner = "Usage: map_remote [arguments]"
      parser.on("-s SNAME", "Remote name") { |x| sname = x }
      parser.on("-u UPPER", "Upper snvid") { |x| upper = x.to_i }
      parser.on("-m CR_MODE", "Crawling mode") { |x| cr_mode = x.to_i }
      parser.on("-t THREADS", "Concurrent threads") { |x| threads = x.to_i }
      parser.on("-n", "--noseed", "Init only") { no_seed = true }
      parser.on("-r", "--redo", "Reseed") { redo = true }

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
