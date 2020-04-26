require "./zh_chap"

class ZhList
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
