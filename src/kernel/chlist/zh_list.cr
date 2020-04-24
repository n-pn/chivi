require "json"

class Chlist::ZhChap
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

class Chlist::Volume
  property label
  property chaps : Array(ZhChap)

  def initialize(@label = "正文", @chaps = [] of ZhChap)
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

class Chlist::ZhList
  DIR = "data/txt-out/chlists"

  def self.load!(site, bsid)
    load!(file_path(site, bsid))
  end

  def self.load!(site : String, bsid : String)
    file = file_path(site, bsid)
    from_json(File.read(file))
  end

  def self.save!(list : ZhList, file : String? = nil)
    file ||= file_path(list.site, list.bsid)
    File.write(file, list.to_json)
  end

  def self.file_path(site : String, bsid : String)
    File.join(DIR, site, "#{bsid}.json")
  end

  include JSON::Serializable

  property site : String
  property bsid : String
  property list : Array(ZhChap)

  def initialize(@site, @bsid, @list = [] of ZhChap)
  end

  def to_s(io : IO)
    to_pretty_json(io)
  end

  def <<(chap : ZhChap)
    @list << chap
  end

  def concat(list : Array(ZhChap))
    @list.concat(list)
  end

  include Indexable(ZhChap)

  def unsafe_fetch(i : Int)
    @list.unsafe_fetch(i)
  end

  include Enumerable(ZhChap)

  def each
    @list.each { |item| yield item }
  end
end
