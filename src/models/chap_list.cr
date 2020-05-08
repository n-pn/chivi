require "json"

require "../_utils/file_utils"
require "../_utils/string_utils"

class ChapItem
  include JSON::Serializable

  property csid = ""

  property zh_title = ""
  property vi_title = ""

  property zh_volume = ""
  property vi_volume = ""

  property title_slug = ""

  def initialize(@csid, title : String, volume : String = "")
    if volume.empty?
      @zh_title, @zh_volume = Utils.split_title(title)
    else
      @zh_title = Utils.fix_title(title)
      @zh_volume = Utils.clean_title(volume)
    end
  end

  def to_s(io : IO)
    io << to_pretty_json
  end

  def zh_title=(title : String)
    return if title.empty? || title == @zh_title

    @zh_title = title
    @vi_title = ""
    @title_slug = ""
  end

  def zh_volume=(volume : String)
    return if volume.empty? || volume == @zh_volume

    @zh_volume = volume
    @vi_volume = ""
  end

  def gen_slug(words : Int32 = 10) : Bool
    return false if @title.empty?

    slug = Utils.slugify(@title, no_accent: true)
    @title_slug = slug.split("-").first(words).join("-")

    true
  end

  def slug_for(site : String)
    "#{@title_slug}-#{site}-#{@csid}"
  end
end

class ChapList < Array(ChapItem)
  DIR = File.join("data", "vp_lists")

  # class methods
  def self.files
    Dir.glob(File.join(DIR, "*.json"))
  end

  def self.path_for(guid : String, site : String, bsid : String)
    File.join(DIR, "#{guid}.#{site}.#{bsid}.json")
  end

  def self.load(guid : String, site : String, bsid : String)
    file = path_for(guid, site, bsid)
    File.exists?(file) ? read!(file) : ChapList.new
  end

  def self.read!(file : String)
    from_json(File.read(file))
  end

  def self.save!(file : String, list : ChapList)
    File.write(file, list.to_pretty_json)
  end
end

# file = ChapList.zh_files.first
# puts file, ChapList.zh_list(file).first(10)
