require "file_utils"
require "option_parser"

require "../../src/_utils/file_utils.cr"
require "../../src/_utils/html_utils.cr"

require "../../src/kernel/book_info.cr"
require "../../src/kernel/order_map.cr"
require "../../src/kernel/label_map.cr"

require "../../src/source/remote_info.cr"

class MapRemote
  SEEDS = {
    "hetushu", "jx_la", "rengshu",
    "xbiquge", "nofff", "duokan8",
    "paoshu8", "69shu", "zhwenpg",
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
    else                1
    end
  end

  BOOK_WEIGHT = OrderMap.load("book_weight")
  BOOK_RATING = OrderMap.load("book_rating")
  BOOK_ACCESS = OrderMap.load("book_access")
  BOOK_UPDATE = OrderMap.load("book_update")
  TOP_AUTHORS = OrderMap.load("top_authors")

  def initialize(@seed : String, @type = 0)
    @seed_uuids = LabelMap.load("seeds/#{seed}_uuids")
    @seed_titles = LabelMap.load("seeds/#{seed}_titles")
    @seed_authors = LabelMap.load("seeds/#{seed}_authors")
  end

  alias TimeSpan = Time::Span | Time::MonthSpan

  def crawl!(from = 1, upto = 1, mode = 0)
    queue = [] of Tuple(String, TimeSpan)

    from.upto(upto) do |id|
      sbid = id.to_s
      queue << {sbid, expiry_for(sbid)} if should_crawl?(sbid, mode)
    end

    puts "\n[-- seed: #{@seed}, from: #{from}, upto: #{upto}, mode: #{mode}, size: #{queue.size} --] ".colorize.cyan.bold

    limit = queue.size
    limit = 8 if limit > 8
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

    BOOK_RATING.save!
    BOOK_WEIGHT.save!
    BOOK_UPDATE.save!
    BOOK_ACCESS.save!

    @seed_uuids.save!
    @seed_titles.save!
    @seed_authors.save!

    puts "\n[-- seed: #{@seed}, from: #{from}, upto: #{upto}, mode: #{mode}, size: #{queue.size} --] ".colorize.cyan.bold
  end

  def expiry_for(sbid : String)
    return 3.months unless uuid = @seed_uuids.fetch(sbid)
    return 6.months unless time = BOOK_UPDATE.value(uuid)

    expiry = Time.utc - Time.unix_ms(time)
    expiry > 24.hours ? expiry - 24.hours : expiry
  end

  def should_crawl?(sbid : String, mode = 0) : Bool
    return true unless uuid = @seed_uuids.fetch(sbid)
    return true if mode == 2 && uuid == "--"

    qualified?(uuid, @seed_authors.fetch(sbid, ""))
  end

  def qualified?(uuid : String, author : String)
    return true if @seed == "hetushu" || @seed == "rengshu"
    return true if BOOK_UPDATE.has_key?(uuid)
    return false unless weight = TOP_AUTHORS.value(author)
    weight >= 2000
  end

  def parse!(sbid : String, expiry = 24.hours, label = "1/1")
    remote = RemoteInfo.new(@seed, sbid, expiry: expiry, freeze: true)

    uuid = remote.uuid
    return if uuid == "--"

    title = remote.title
    author = remote.author

    return if SourceUtil.blacklist?(title)

    puts "\n<#{label}> [#{sbid}] #{uuid}-#{author}-#{title}".colorize.cyan

    @seed_uuids.upsert(sbid, uuid)
    @seed_titles.upsert(sbid, title)
    @seed_authors.upsert(sbid, author)

    return unless qualified?(uuid, author)
    info = remote.emit_book_info

    if info.weight == 0 && info.yousuu_url.empty?
      puts "- FAKING RANDOM RATING -".colorize.yellow

      weight = TOP_AUTHORS.value(info.author_zh) || 2000_i64
      weight = Random.rand((weight // 2)..weight)
      scored = Random.rand(30..70)

      info.rating = (scored / 10).to_f32
      info.voters = (weight // scored).to_i32
      info.weight = (scored * info.voters).to_i64

      BOOK_WEIGHT.upsert(info.uuid, info.weight)
      BOOK_RATING.upsert(info.uuid, info.scored)
    end

    return unless info.changed?
    info.save!

    BOOK_UPDATE.upsert(uuid, info.mftime)
    BOOK_ACCESS.upsert(uuid, info.mftime)

    remote.emit_chap_list.tap { |x| x.save! if x.changed? }
  rescue err
    puts "Error parsing `#{sbid}`: #{err.colorize.red}".colorize.bold
    # puts err.backtrace

    @seed_uuids.upsert(sbid, "--")
    @seed_titles.upsert(sbid, "")
    @seed_authors.upsert(sbid, "")
  end
end

MapRemote.run!
