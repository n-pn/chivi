require "option_parser"
require "file_utils"

require "../../src/bookdb/info_spider.cr"
require "../../src/models/vp_info.cr"

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
        sitemap[bsid] = uuid
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

FileUtils.mkdir_p(Mapping::DIR)

def update_anchor(vp_info, sp_info) : Void
  if updated = vp_info.cr_updates[sp_info.site]?
    return if updated > sp_info.update
  end

  vp_info.cr_anchors[sp_info.site] = sp_info.bsid
  vp_info.cr_updates[sp_info.site] = sp_info.update
end

SITES = {
  "hetushu", "jx_la", "rengshu",
  "xbiquge", "nofff", "duokan8",
  "paoshu8", "69shu", "zhwenpg",
}

def prefered?(vp_info, sp_info) : Bool
  case vp_info.cr_site_df
  when "", "zhwenpg"
    true
  when sp_info.site
    sp_info.update > vp_info.cr_updates[sp_info.site]
  else
    old_pos = SITES.index(vp_info.cr_site_df) || 0
    new_pos = SITES.index(sp_info.site) || 0
    new_pos < old_pos
  end
end

def gen_expiry(status : Int32)
  case status
  when 0 then 4.hours
  when 1 then 10.days
  else        360.days
  end
end

LIST_DIR = File.join("data", "zh_lists")
FileUtils.mkdir_p(LIST_DIR)

def update_infos(site, bsid, uuid, label) : Void
  if uuid
    vp_info = VpInfo.load_json(uuid)
    # return if vp_info.cr_anchors[site]? == bsid
    expiry = gen_expiry(vp_info.status)
  else
    expiry = 360.days
  end

  spider = InfoSpider.load(site, bsid, expiry, frozen: true)
  sp_info = spider.get_infos!

  Mapping.append(site, "#{bsid}--#{sp_info.uuid}--#{sp_info.title}--#{sp_info.author}")

  if vp_info ||= VpInfo.load_json?(sp_info.uuid)
    vp_info.set_intro_zh(sp_info.intro)
    vp_info.set_genre_zh(sp_info.genre)
    vp_info.set_tags_zh(sp_info.tags)
    vp_info.add_cover(sp_info.cover)
    vp_info.set_status(sp_info.status)

    sp_info.update = vp_info.update if sp_info.site == "hetushu"
    vp_info.set_update(sp_info.update)
    update_anchor(vp_info, sp_info)
    vp_info.cr_site_df = site if prefered?(vp_info, sp_info)

    puts "- <#{label.colorize(:green)}> #{sp_info.title}"
    VpInfo.save_json(vp_info)

    list_file = File.join(LIST_DIR, "#{vp_info.uuid}.#{site}.#{bsid}.json")
    File.write(list_file, spider.get_chaps!.to_pretty_json)
  else
    puts "- <#{label.colorize(:blue)}> #{sp_info.title}"
  end
rescue err
  Mapping.append(site, "#{bsid}--")
  puts "- <#{label.colorize(:red)}> #{err.message}"
end

def load_skipping(site : String)
  skip_dir = File.join("data", ".inits", "txt-inp", site, "skips")
  return Set(String).new unless File.exists?(skip_dir)

  skip_ids = Dir.children(skip_dir).map do |file|
    File.basename(file, ".txt")
  end
  Set(String).new(skip_ids)
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
map_spider(site, upto, uuids)
Mapping.compact(site)
