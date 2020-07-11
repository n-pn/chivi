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

  BOOK_ACCESS = OrderMap.load("book_access")
  BOOK_UPDATE = OrderMap.load("book_update")
  TOP_AUTHORS = OrderMap.load("top_authors")

  BOOK_INFOS = BookInfo.load_all!

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
    return true if BOOK_INFOS.has_key?(uuid)
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

# RETRY = ARGV.includes?("mode")

# module Mapping
#   DIR = File.join("data", "sitemaps")

#   def self.path(site : String)
#     File.join(DIR, "#{site}.txt")
#   end

#   def self.load(site : String)
#     sitemap = {} of String => String
#     mapfile = path(site)

#     if File.exists?(mapfile)
#       File.read_lines(mapfile).each do |line|
#         next if line.empty?
#         bsid, uuid = line.split("--")
#         sitemap[bsid] = uuid unless RETRY && uuid.empty?
#       rescue
#         next
#       end
#     end

#     puts "- mapped: #{sitemap.size.colorize(:blue)} entries"

#     sitemap
#   end

#   def self.append(site : String, text) : Void
#     File.open(path(site), "a") { |f| f.puts(text) }
#   end

#   def self.compact(site : String)
#     file = path(site)
#     lines = File.read_lines(file).uniq
#     File.write(file, lines.join("\n"))
#   end
# end

# SITES = {
#   "hetushu", "jx_la", "rengshu",
#   "xbiquge", "nofff", "duokan8",
#   "paoshu8", "69shu", "zhwenpg",
# }

# def prefered?(info, site) : Bool
#   case info.cr_site_df
#   when "", "zhwenpg" then true
#   when "manual"      then false
#   else
#     old_pos = SITES.index(info.cr_site_df) || 99
#     new_pos = SITES.index(site) || 0
#     new_pos < old_pos
#   end
# end

# def gen_expiry(status : Int32)
#   case status
#   when 0 then 10.hours
#   when 1 then 20.days
#   else        30.months
#   end
# end

# def update_infos(site, bsid, uuid, label) : Void
#   if uuid
#     info = VpInfo.load!(uuid)
#     expiry = gen_expiry(info.status)
#   else
#     expiry = 360.days
#   end

#   spider = InfoSpider.load(site, bsid, expiry, frozen: true)

#   title = spider.get_title!
#   author = spider.get_author!
#   uuid ||= Utils.book_uid(title, author)

#   Mapping.append(site, "#{bsid}--#{uuid}--#{title}--#{author}")

#   if info ||= VpInfo.load(uuid)
#     info = spider.get_infos!(info)
#     info.cr_site_df = site if prefered?(info, site)

#     puts "- <#{label.colorize(:green)}> #{title}"
#     VpInfo.save!(info)
#   else
#     puts "- <#{label.colorize(:cyan)}> #{title}"
#   end
# rescue err
#   Mapping.append(site, bsid)
#   file = SpiderUtil.info_path(site, bsid)
#   File.delete(file) if RETRY && File.exists?(file)

#   puts "- <#{label.colorize(:red)}> #{err.message}"
# end

# def load_skipping(site : String)
#   skipping = Set(String).new

#   skip_dir = File.join("data", ".inits", "txt-inp", site, "skips")
#   if File.exists?(skip_dir)
#     Dir.children(skip_dir).map do |file|
#       skipping << File.basename(file, ".txt")
#     end
#   end

#   skipping
# end

# def map_spider(site = "rengshu", upto = 4275, uuids = Set(String).new)
#   puts "- site: #{site.colorize(:yellow)}"
#   puts "- upto: #{upto.colorize(:yellow)}"

#   skipping = load_skipping(site)
#   sitemap = Mapping.load(site)
#   mapping = [] of Tuple(String, String?)

#   1.upto(upto) do |idx|
#     bsid = idx.to_s
#     next if skipping.includes?(bsid)

#     if uuid = sitemap[bsid]?
#       next unless uuids.includes?(uuid)
#     end

#     mapping << {bsid, uuid}
#   end

#   puts "- size: #{mapping.size.colorize(:yellow)}"

#   return if mapping.empty?

#   limit = 16
#   limit = mapping.size if limit > mapping.size

#   channel = Channel(Nil).new(limit)

#   mapping.each_with_index do |(bsid, uuid), idx|
#     channel.receive unless idx < limit

#     spawn do
#       update_infos(site, bsid, uuid, "#{idx + 1}/#{mapping.size}-#{site}/#{bsid}")
#       channel.send(nil)
#     end
#   end

#   limit.times { channel.receive }
# end

# def parse_args(site = "rengshu", upto = 4275)
#   OptionParser.parse do |parser|
#     parser.banner = "Usage: mapping [arguments]"
#     parser.on("-h", "--help", "Show this help") { puts parser }

#     parser.on("-s SITE", "--site=SITE", "Site") { |x| site = x }
#     parser.on("-u UPTO", "--upto=UPTO", "Upto") { |x| upto = x.to_i }

#     parser.invalid_option do |flag|
#       STDERR.puts "ERROR: #{flag} is not a valid option."
#       STDERR.puts parser
#       exit(1)
#     end
#   end

#   {site, upto}
# end

# files = Dir.children(VpInfo::DIR)
# uuids = Set(String).new files.map { |file| File.basename(file, ".json") }

# site, upto = parse_args

# FileUtils.mkdir_p(Mapping::DIR)
# map_spider(site, upto, uuids)
# Mapping.compact(site)
