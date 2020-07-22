require "file_utils"
require "option_parser"

require "../../src/common/file_util"
require "../../src/common/http_util"
require "../../src/common/time_util"

require "../../src/kernel/book_repo"
require "../../src/kernel/chap_repo"

class MapRemote
  SEEDS = {
    "hetushu", "qu_la", "jx_la", "rengshu",
    "xbiquge", "nofff", "duokan8",
    "paoshu8", "69shu",
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
    when "qu_la"   then 252941
    when "jx_la"   then 252941
    when "rengshu" then 4275
    when "xbiquge" then 52986
    when "nofff"   then 69766
    when "duokan8" then 23377
    when "69shu"   then 32113
    when "paoshu8" then 147456
    else                1
    end
  end

  def initialize(@seed : String, @type = 0)
    @existed = Set(String).new(BookInfo.ubids)
    @sitemap = LabelMap.load("_import/sites/#{@seed}")

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
    limit = 16 if limit > 16
    channel = Channel(Nil).new(limit)

    queue.each_with_index do |(sbid, expiry), idx|
      channel.receive if idx > limit

      spawn do
        parse!(sbid, expiry, "#{idx + 1}/#{queue.size}")
      ensure
        channel.send(nil)
      end
    end

    limit.times { channel.receive }

    puts "\n[-- Save indexes --]".colorize.cyan.bold
    OrderMap.flush!
    LabelMap.flush!
    TokenMap.flush!

    @sitemap.save!

    puts "\n[-- seed: #{@seed}, from: #{from}, upto: #{upto}, mode: #{mode}, size: #{queue.size} --] ".colorize.cyan.bold
  end

  CACHED = ARGV.includes?("cached")

  def expiry_for(sbid : String)
    return Time.utc - 1.year if CACHED
    return Time.utc - 9.months unless ubid = @crawled[sbid]?
    return Time.utc - 6.months unless @existed.includes?(ubid)
    return Time.utc - 3.months unless time = OrderMap.book_update.value(ubid)
    Time.unix_ms(time) + 6.hours
  end

  def should_crawl?(sbid : String, mode = 0) : Bool
    return true unless meta = @sitemap.fetch(sbid)
    ubid, title, author = meta.split("¦")
    return true if mode == 2 && title.empty? || author.empty?
    qualified?(ubid, author)
  end

  def qualified?(ubid : String, author : String)
    return true if @existed.includes?(ubid)
    OrderMap.top_authors.has_key?(author)
  end

  def parse!(sbid : String, expiry = Time.utc - 24.hours, label = "1/1")
    remote = SeedInfo.init(@seed, sbid, expiry: expiry, freeze: true)

    info = BookRepo.find_or_create(remote.title, remote.author)
    save_info(sbid, info.ubid, info.zh_title, info.zh_author)

    return if info.zh_title.empty? || info.zh_author.empty? || BookRepo.blacklist?(info)

    return unless qualified?(info.ubid, info.zh_author)

    puts "\n<#{label}> [#{sbid}] #{info.ubid}-#{info.zh_title}".colorize.cyan

    BookRepo.upsert_info(info)
    BookRepo.update_info(info, remote)

    info.save! if info.changed?
    expiry = Time.unix_ms(info.mftime) unless CACHED

    return unless ChapList.outdated?(info.ubid, @seed, expiry)
    chlist = ChapList.get_or_create(info.ubid, @seed)
    chlist = ChapRepo.update_list(chlist, remote)

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
