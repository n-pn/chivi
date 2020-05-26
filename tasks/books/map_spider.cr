require "option_parser"
require "file_utils"

require "../../src/bookdb/book_info.cr"
require "../../src/spider/info_spider.cr"

RETRY = ARGV.includes?("retry")

module Mapping
  DIR = File.join("data", "sitemaps")

  def self.path(site : String)
    File.join(DIR, "#{site}.txt")
  end

  def self.load(site : String)
    sitemap = {} of String => String
    mapfile = path(site)

    if File.exists?(mapfile)
      File.read_lines(mapfile).each do |line|
        next if line.empty?
        bsid, uuid = line.split("--")
        sitemap[bsid] = uuid unless RETRY && uuid.empty?
      rescue
        next
      end
    end

    puts "- mapped: #{sitemap.size.colorize(:blue)} entries"

    sitemap
  end

  def self.append(site : String, text) : Void
    File.open(path(site), "a") { |f| f.puts(text) }
  end

  def self.compact(site : String)
    file = path(site)
    lines = File.read_lines(file).uniq
    File.write(file, lines.join("\n"))
  end
end

SITES = {
  "hetushu", "jx_la", "rengshu",
  "xbiquge", "nofff", "duokan8",
  "paoshu8", "69shu", "zhwenpg",
}

def prefered?(info, site) : Bool
  case info.cr_site_df
  when "", "zhwenpg" then true
  when "manual"      then false
  else
    old_pos = SITES.index(info.cr_site_df) || 99
    new_pos = SITES.index(site) || 0
    new_pos < old_pos
  end
end

def gen_expiry(status : Int32)
  case status
  when 0 then 10.hours
  when 1 then 20.days
  else        30.months
  end
end

def update_infos(site, bsid, uuid, label) : Void
  if uuid
    info = VpInfo.load!(uuid)
    expiry = gen_expiry(info.status)
  else
    expiry = 360.days
  end

  spider = InfoSpider.load(site, bsid, expiry, frozen: true)

  title = spider.get_title!
  author = spider.get_author!
  uuid ||= Utils.book_uid(title, author)

  Mapping.append(site, "#{bsid}--#{uuid}--#{title}--#{author}")

  if info ||= VpInfo.load(uuid)
    info = spider.get_infos!(info)
    info.cr_site_df = site if prefered?(info, site)

    puts "- <#{label.colorize(:green)}> #{title}"
    VpInfo.save!(info)
  else
    puts "- <#{label.colorize(:cyan)}> #{title}"
  end
rescue err
  Mapping.append(site, bsid)
  file = SpiderUtil.info_path(site, bsid)
  File.delete(file) if RETRY && File.exists?(file)

  puts "- <#{label.colorize(:red)}> #{err.message}"
end

def load_skipping(site : String)
  skipping = Set(String).new

  skip_dir = File.join("data", ".inits", "txt-inp", site, "skips")
  if File.exists?(skip_dir)
    Dir.children(skip_dir).map do |file|
      skipping << File.basename(file, ".txt")
    end
  end

  skipping
end

def map_spider(site = "rengshu", upto = 4275, uuids = Set(String).new)
  puts "- site: #{site.colorize(:yellow)}"
  puts "- upto: #{upto.colorize(:yellow)}"

  skipping = load_skipping(site)
  sitemap = Mapping.load(site)
  mapping = [] of Tuple(String, String?)

  1.upto(upto) do |idx|
    bsid = idx.to_s
    next if skipping.includes?(bsid)

    if uuid = sitemap[bsid]?
      next unless uuids.includes?(uuid)
    end

    mapping << {bsid, uuid}
  end

  puts "- size: #{mapping.size.colorize(:yellow)}"

  return if mapping.empty?

  limit = 16
  limit = mapping.size if limit > mapping.size

  channel = Channel(Nil).new(limit)

  mapping.each_with_index do |(bsid, uuid), idx|
    channel.receive unless idx < limit

    spawn do
      update_infos(site, bsid, uuid, "#{idx + 1}/#{mapping.size}-#{site}/#{bsid}")
      channel.send(nil)
    end
  end

  limit.times { channel.receive }
end

def parse_args(site = "rengshu", upto = 4275)
  OptionParser.parse do |parser|
    parser.banner = "Usage: mapping [arguments]"
    parser.on("-h", "--help", "Show this help") { puts parser }

    parser.on("-s SITE", "--site=SITE", "Site") { |x| site = x }
    parser.on("-u UPTO", "--upto=UPTO", "Upto") { |x| upto = x.to_i }

    parser.invalid_option do |flag|
      STDERR.puts "ERROR: #{flag} is not a valid option."
      STDERR.puts parser
      exit(1)
    end
  end

  {site, upto}
end

files = Dir.children(VpInfo::DIR)
uuids = Set(String).new files.map { |file| File.basename(file, ".json") }

site, upto = parse_args

FileUtils.mkdir_p(Mapping::DIR)
map_spider(site, upto, uuids)
Mapping.compact(site)
