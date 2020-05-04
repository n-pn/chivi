require "json"
require "colorize"
require "file_utils"

struct Mapping
  include JSON::Serializable
  property uuid = ""
  property title = ""
  property author = ""
  property maptime : Time

  def initialize(@uuid, @title, @author, @maptime = Time.local)
  end

  def self.maptime(file : String)
    File.info(file).modification_time
  end

  MAP_DIR = File.join("data", "sitemaps")

  def self.mkdir!
    FileUtils.mkdir_p(MAP_DIR)
  end

  def self.file_path(site : String)
    File.join(MAP_DIR, "#{site}.json")
  end

  alias Sitemap = Hash(String, Mapping)

  INFO_DIR = File.join("data", "inits", "txt-inp")

  def self.load!(site : String)
    map_file = file_path(site)

    if File.exists?(map_file)
      sitemap = Sitemap.from_json File.read(map_file)
    else
      sitemap = Sitemap.new
    end

    puts "- mapped: #{sitemap.size.colorize(:blue)} entries"

    ext = site == "yousuu" ? ".json" : ".html"
    dir = File.join(INFO_DIR, site, "infos")

    unmapped = Dir.glob(File.join(dir, "*" + ext)).reject do |file|
      bsid = File.basename(file, ext)
      if mapped = sitemap[bsid]?
        mapped.maptime < maptime(file)
      else
        false
      end
    end

    puts "- unmapped: #{unmapped.size.colorize(:blue)} entries"

    {sitemap, unmapped}
  end

  def self.save!(site : String, sitemap : Sitemap)
    File.write(file_path(site), sitemap.to_pretty_json)
  end
end
