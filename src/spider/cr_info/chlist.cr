require "json"

class Spider::Chinfo
  include JSON::Serializable

  property csid : String = "0"
  property title : String = ""
  property volume : String = "正文"

  def initialize(@csid, title, @volume = "正文")
    @title = title.sub(/^\d+\.\s*第/, "第").tr("　 ", " ").strip
    # TODO: Extract volume from title
  end

  def to_s(io : IO)
    io << to_pretty_json
  end
end

class Spider::Chlist < Array(Chinfo)
  DIR = "data/txt-tmp/chlists"

  def self.load!(site, bsid)
    load!(file_path(site, bsid))
  end

  def self.load!(site : String, bsid : String)
    file = file_path(site, bsid)
    from_json(File.read(file))
  end

  def self.file_path(site : String, bsid : String)
    File.join(DIR, site, "#{bsid}.json")
  end

  def save!(site : String, bsid : String)
    save!(Chlist.file_path(site, bsid))
  end

  def save!(file : String)
    File.write(file, to_json)
  end
end

class Spider::Volume
  property label
  property chaps : Chlist

  def initialize(@label = "正文", @chaps = Chlist.new)
  end

  INDEX_RE = /([零〇一二两三四五六七八九十百千]+|\d+)[集卷]/

  def index
    if match = INDEX_RE.match(@label)
      match[1]
    else
      "0"
    end
  end
end
