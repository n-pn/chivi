require "json"

class Serial::ZhInfo
  include JSON::Serializable

  property slug = ""

  property title = ""
  property author = ""

  property intro = ""
  property genre = ""

  property tags = [] of String
  property cover = ""

  property yousuu_bids = [] of Int32
  property source_urls = [] of String
  property crawl_links = {} of String => String

  def initialize
  end

  def initialize(@title, @author)
  end

  def save(name : String)
    File.write(self.class.file_path(name), to_json)
  end

  DIR = "data/txt-out/serials"

  def self.file_path(name : String)
    "#{DIR}/#{name}.info.zh.json"
  end

  def self.load!(name : String)
    from_json(File.read(file_path(name)))
  end
end
