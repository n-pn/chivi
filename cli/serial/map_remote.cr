require "file_utils"
require "option_parser"

require "../../src/_utils/file_util"
require "../../src/_utils/http_util"
require "../../src/_utils/time_util"

require "../../src/kernel/bookdb"
require "../../src/kernel/chapdb"

class MapRemote
  SEEDS = {
    "hetushu", "xbiquge", "69shu",
    "biquge5200", "5200", "zhwenpg",
    "duokan8", "rengshu", "nofff",
    "paoshu8", "jx_la", "shubaow",
  }

  def self.run!(argv = ARGV)
    seed = "hetushu"
    mode = 0
    from = 1
    upto = 1

    OptionParser.parse(argv) do |parser|
      parser.banner = "Usage: map_remote [arguments]"
      parser.on("-s SEED", "--seed=SEED", "Seed name") { |x| seed = x }
      parser.on("-m MODE", "--mode=MODE", "Map mode") { |x| mode = x.to_i }
      parser.on("-f FROM", "--from=FROM", "First sbid") { |x| from = x.to_i }
      parser.on("-u UPTO", "--upto=UPTO", "Last sbid") { |x| upto = x.to_i }

      parser.invalid_option do |flag|
        STDERR.puts "ERROR: `#{flag}` is not a valid option."
        STDERR.puts parser
        exit(1)
      end
    end

    unless SEEDS.includes?(seed)
      STDERR.puts "ERROR: invalid seed `#{seed}`."
      exit(1)
    end

    upto = default_upto(seed) if upto <= 1
    new(seed).crawl!(from, upto, mode)
  end

  def self.default_from(seed : String) : Int32
    1 # TODO: read from input?
  end

  def self.default_upto(seed : String) : Int32
    case seed
    when "hetushu" then 4831
    when "jx_la"   then 252941
    when "rengshu" then 4275
    when "xbiquge" then 52986
    when "nofff"   then 69766
    when "duokan8" then 23377
    when "69shu"   then 32113
    when "paoshu8" then 147456
    when "5200"    then 28208
    else                1
    end
  end

  def initialize(@seed : String, @type = 0)
    @existed = Set(String).new(BookInfo.ubids)
    @sitemap = OldLabelMap.load_name("_import/sites/#{@seed}")

    @crawled = {} of String => String
    @sitemap.each do |key, val|
      ubid, title, author = val.split("¦")
      ubid = "--" if title.empty? || author.empty?
      @crawled[key] = ubid
    end
  end

  def crawl!(from = 1, upto = 1, mode = 0)
    queue = [] of Tuple(String, Time)

    from.upto(upto) do |id|
      sbid = id.to_s
      queue << {sbid, expiry_for(sbid)} if should_crawl?(sbid, mode)
    end

    puts "\n[-- seed: #{@seed}, from: #{from}, upto: #{upto}, mode: #{mode}, size: #{queue.size} --] ".colorize.cyan.bold

    limit = queue.size
    limit = 8 if limit > 8
    limit = 1 if @seed == "shubaow"

    channel = Channel(Nil).new(limit)

    queue.shuffle.each_with_index do |(sbid, expiry), idx|
      channel.receive if idx > limit

      spawn do
        parse!(sbid, expiry, "#{idx + 1}/#{queue.size}")
        sleep 500.milliseconds
      ensure
        channel.send(nil)
      end
    end

    limit.times { channel.receive }

    puts "\n[-- Save indexes --]".colorize.cyan.bold
    OldOrderMap.flush!
    OldLabelMap.flush!
    OldTokenMap.flush!

    @sitemap.save!

    puts "\n[-- seed: #{@seed}, from: #{from}, upto: #{upto}, mode: #{mode}, size: #{queue.size} --] ".colorize.cyan.bold
  end

  CACHED = ARGV.includes?("cached")

  def expiry_for(sbid : String)
    if CACHED || @seed == "jx_la" || @seed == "duokan8"
      return Time.utc - 10.year
    end

    return Time.utc - 9.months unless ubid = @crawled[sbid]?
    return Time.utc - 6.months unless @existed.includes?(ubid)
    return Time.utc - 3.months unless time = OldOrderMap.book_update.value(ubid)
    Time.unix_ms(time) + 6.hours
  end

  def should_crawl?(sbid : String, mode = 0) : Bool
    return true if @seed == "hetushu" # accept all book from hetushu

    return true unless meta = @sitemap.fetch(sbid)
    ubid, title, author = meta.split("¦")
    return true if mode == 2 && title.empty? || author.empty?
    qualified?(ubid, author)
  end

  def qualified?(ubid : String, author : String)
    return true if @existed.includes?(ubid)
    BookDB.whitelist?(author)
  end

  def parse!(sbid : String, expiry = Time.utc - 1.years, label = "1/1")
    remote = SeedInfo.new(@seed, sbid, expiry: expiry, freeze: true)

    info = BookDB.find_or_create(remote.title, remote.author)
    save_info(sbid, info.ubid, info.zh_title, info.zh_author)

    return if info.zh_title.empty? || info.zh_author.empty? || BookDB.blacklist?(info)

    return unless qualified?(info.ubid, info.zh_author)

    puts "\n<#{label}> [#{sbid}] #{info.ubid}-#{info.zh_title}".colorize.cyan

    BookDB.upsert_info(info)
    BookDB.update_info(info, remote)

    info.save! if info.changed?

    unless CACHED || @seed == "jx_la" || @seed == "duokan8"
      expiry = Time.unix_ms(info.mftime)
    end

    return unless ChapList.outdated?(info.ubid, @seed, expiry)
    chlist = ChapList.get_or_create(info.ubid, @seed)
    chlist = ChapDB.update_list(chlist, remote)

    chlist.save! if chlist.changed?
  rescue err
    puts "Error parsing `#{sbid}`: #{err.colorize.red}".colorize.bold
    # puts err.backtrace
    save_info(sbid)
  end

  def save_info(sbid, ubid = "--", title = "", author = "")
    @sitemap.upsert(sbid, "#{ubid}¦#{title}¦#{author}")
  end
end

MapRemote.run!
