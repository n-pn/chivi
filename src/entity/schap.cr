require "json"

class SChap
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

class SList < Array(SChap)
  @@dir = "data/txt-tmp/chlists"

  def self.dir
    @@dir
  end

  def self.chdir(dir : String)
    @@dir = dir
  end

  def self.file_path(site : String, bsid : String)
    "#{@@dir}/#{site}/#{bsid}.json"
  end

  def self.load(site, bsid)
    load(file_path(site, bsid))
  end

  def self.load(file : String)
    from_json(File.read(file))
  end

  def save!(site : String, bsid : String)
    save!(SList.file_path(site, bsid))
  end

  def save!(file : String)
    File.write(file, to_json)
  end
end
