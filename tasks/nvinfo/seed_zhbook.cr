require "option_parser"
require "../shared/seed_data"

class CV::SeedZhbook
  def initialize(@sname : String)
    ::FileUtils.mkdir_p("_db/.cache/#{@sname}")
    @seed = SeedData.new(@sname)
  end

  def build!(upper : Int32)
    upper = upper_snvid.to_i if upper < 1
    missing, updates = [] of String, [] of String

    read_stats(upper) do |snvid, state|
      missing << snvid if state > 1
      updates << snvid if state == 0 || state == 2
    end

    {missing, updates}
  end

  def read_stats(upper : Int32)
    limit = 20
    channel = Channel(Tuple(String, Int32)).new(limit + 1)

    1.upto(upper) do |index|
      spawn do
        snvid = index.to_s
        fpath = "_db/.cache/#{@sname}/infos/#{snvid}.html.gz"

        mtime = SeedUtil.get_mtime(fpath)   # html cached if mtime > 0
        atime = @seed._index.ival_64(snvid) # book parsed if atime > 0

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

    RmInfo.mkdir!(@sname) # ensure the seed cache folde
    channel = Channel(Nil).new(threads)
    encoding = HttpUtils.encoding_for(@sname)

    queue.each_with_index(1) do |snvid, index|
      spawn do
        entry = RmInfo.new(@sname, snvid)
        label = "#{index}/#{queue.size}"

        html = HttpUtils.get_html(entry.link, label: label, encoding: encoding)
        HttpUtils.save_html(entry.file, html)

        # throttling if success
        case @sname
        when "shubaow"
          sleep Random.rand(1000..2000).milliseconds
        when "zhwenpg"
          sleep Random.rand(500..1000).milliseconds
        when "bqg_5200"
          sleep Random.rand(100..500).milliseconds
        end
      rescue err
        puts err
      ensure
        channel.send(nil)
      end

      channel.receive if index > threads
    end

    threads.times { channel.receive }
  end

  def init!(queue : Array(String))
    puts "[#{@sname}], parsing: #{queue.size}\n".colorize.cyan.bold

    queue.each_with_index(1) do |snvid, idx|
      entry = RmInfo.new(@sname, snvid, label: "#{idx}/#{queue.size}")
      atime = SeedUtil.get_mtime(entry.file)

      @seed._index.set!(snvid, [atime.to_s, entry.btitle, entry.author])
      @seed.set_intro(snvid, entry.bintro)

      @seed.genres.set!(snvid, entry.genres)
      @seed.bcover.set!(snvid, entry.bcover)

      if @sname == "hetushu"
        @seed.status.set!(snvid, [entry.status])
      else
        status_int = SeedUtil.parse_status(entry.status)
        @seed.status.set!(snvid, [status_int.to_s, entry.status])
      end

      @seed.mftime.set!(snvid, [entry.mftime.to_s, entry.update])

      if idx % 100 == 0
        puts "- [#{@sname}]: <#{idx}/#{queue.size}>"
        @seed.save!(clean: false)
      end
    end

    @seed.save!(clean: false)
  end

  def upper_snvid : String
    page = begin
      file = "_db/.cache/#{@sname}/index.html.gz"
      link = site_index_link(@sname)
      encoding = HttpUtils.encoding_for(@sname)
      html = HttpUtils.load_html(link, file, ttl: 12.hours, encoding: encoding)
      HtmlParser.new(html)
    end

    case @sname
    when "69shu"
      href = page.attr(".ranking:nth-child(2) a:first-of-type", "href")
      File.basename(href, ".htm")
    when "hetushu"
      href = page.attr("#list a:first-of-type", "href")
      File.basename(File.dirname(href))
    when "nofff"
      href = page.attr("#newscontent_n .s2 > a", "href")
      File.basename(href)
    when "rengshu", "xbiquge", "biqubao", "bxwxorg"
      href = page.attr("#newscontent > .r .s2 > a", "href")
      File.basename(href)
    when "bqg_5200", "paoshu8", "shubaow"
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

  private def site_index_link(sname : String) : String
    case sname
    when "69shu"    then "https://www.69shu.com/"
    when "hetushu"  then "https://www.hetushu.com/book/index.php"
    when "rengshu"  then "http://www.rengshu.com/"
    when "xbiquge"  then "https://www.xbiquge.so/"
    when "biqubao"  then "https://www.biqubao.com/"
    when "5200"     then "https://www.5200.tv/"
    when "duokan8"  then "http://www.duokan8.com/"
    when "nofff"    then "https://www.nofff.com/"
    when "bqg_5200" then "https://www.biquge5200.com/"
    when "bxwxorg"  then "https://www.bxwxorg.com/"
    when "shubaow"  then "https://www.shubaow.net/"
    when "paoshu8"  then "http://www.paoshu8.com/"
    else                 raise "Unsupported source name!"
    end
  end

  private def ideal_threads
    case @sname
    when "zhwenpg", "shubaow"           then 1
    when "paoshu8", "69shu", "bqg_5200" then 3
    when "hetushu", "duokan8"           then 6
    else                                     10
    end
  end

  def seed!(redo = false)
    input = @seed._index.data.to_a

    puts "- Input: #{input.size.colorize.cyan} entries, \
            authors: #{Author.query.count.colorize.cyan}, \
            cvbooks: #{Cvbook.query.count.colorize.cyan}"

    input.sort_by(&.[0].to_i).each_with_index(1) do |(snvid, values), idx|
      save_book(snvid, values, redo: redo)

      if idx % 100 == 0
        puts "- [#{@sname}] <#{idx.colorize.cyan}/#{input.size}>, \
                authors: #{Author.query.count.colorize.cyan}, \
                cvbooks: #{Cvbook.query.count.colorize.cyan}"
      end
    end

    puts "- authors: #{Author.query.count.colorize.cyan}, \
            cvbooks: #{Cvbook.query.count.colorize.cyan}"

    @seed.save!
  end

  def save_book(snvid : String, values : Array(String), redo = false)
    bumped, p_ztitle, p_author = values
    return if p_ztitle.empty? || p_author.empty?

    author = SeedUtil.get_author(p_author, p_ztitle, @sname == "hetushu")
    return unless author

    ztitle = BookUtils.fix_zh_btitle(p_ztitle, author.zname)
    return unless cvbook = load_cvbook(author, ztitle)

    zhbook = Zhbook.upsert!(@sname, snvid)
    bumped = bumped.to_i64

    if redo || zhbook.unmatch?(cvbook.id)
      zhbook.cvbook = cvbook
      cvbook.add_zhseed(zhbook.zseed)

      cvbook.set_genres(@seed.get_genres(snvid))
      cvbook.set_bcover("#{@sname}-#{snvid}.webp")
      cvbook.set_zintro(@seed.get_intro(snvid).join("\n"))

      if cvbook.voters == 0
        voters, rating = @seed.get_scores(snvid)
        cvbook.set_scores(voters, rating)
      end
    else # zhbook already created before
      return unless bumped > zhbook.bumped
    end

    zhbook.status = @seed.status.ival(snvid)
    cvbook.set_status(zhbook.status)

    zhbook.bumped = bumped
    zhbook.mftime = @seed.mftime.ival_64(snvid)

    if zhbook.mftime < 1
      zhbook.mftime = cvbook.mftime
    else
      cvbook.set_mftime(zhbook.mftime)
    end

    if zhbook.chap_count == 0 || redo
      vals = @seed.chsize.get(snvid)

      if vals = @seed.chsize.get(snvid)
        chap_count = vals[0].to_i
        last_schid = vals[1]
      else
        puts "-- parsing: #{cvbook.bhash}".colorize.red
        # ttl = get_ttl(zhbook.mftime)
        chinfo = ChInfo.new(cvbook.bhash, @sname, snvid)
        _, chap_count, last_schid = chinfo.update!(mode: 1, ttl: 10.years)
        @seed.chsize.set!(snvid, [chap_count.to_s, last_schid])
      end

      zhbook.chap_count = chap_count
      zhbook.last_schid = last_schid
    end

    zhbook.save!
    cvbook.save!
  end

  def get_ttl(mftime : Int64)
    return 10.years if @sname == "hetushu" || @sname == "jx_la"
    Time.utc - Time.unix(mftime) - 1.days
  end

  private def get_fake_scores
    case @sname
    when "hetushu"
      [Random.rand(30..100), Random.rand(50..65)]
    else
      [Random.rand(25..50), Random.rand(40..50)]
    end
  end

  def load_cvbook(author : Author, ztitle : String)
    case @sname
    when "hetushu", "rengshu", "xbiquge", "69shu" # reliable source
      Cvbook.upsert!(author, ztitle)
    else
      Cvbook.get(author, ztitle)
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
    seeder.seed!(redo: redo) unless no_seed
  end
end

CV::SeedZhbook.run!(ARGV)
