require "json"

require "./schap"
require "./vtran"

class VChap
  include JSON::Serializable

  property csid : String

  property title = VTran.new
  property vlume = VTran.new

  def initialize(chap : SChap, book : String? = nil, user = "local")
    @csid = chap.csid
    set_title(chap.title, book, user)
    set_volume(chap.volume, book, user)
  end

  def initialize(@csid : String, title : String, volume : String, book : String? = nil, user = "local")
    set_title(title, book, user)
    set_volume(volume, book, user)
  end

  def set_title(title, book : String? = nil, user = "local")
    title_vi = Engine.convert(title, :title, book, user).vi_text
    @title.update(title, title_vi)
  end

  def set_volume(title, book : String? = nil, user = "local")
    volume_vi = Engine.convert(volume, :title, book, user).vi_text

    @volume.update(volume, volume_vi)
  end

  def slug(site)
    "#{@title.us}-#{site}-#{@csid}"
  end
end

class VList < Array(VChap)
  @@dir = "data/txt-out/chlists"

  def self.import(list : SList, book : String? = nil, user = "local")
    res = new
    list.each { |chap| res << VChap.new(chap) }
    res
  end

  def update(list : SList, book : String? = nil, user = "local")
    changed = list.size != size

    # in rare case when the list is truncated
    (size - list.size).times { pop() }

    upto = size

    0.upto(upto - 1) do |i|
      slist = list[i]
      vlist = self[i]

      if vlist.csid != slist.csid
        vlist.ccid = slist.csid
        changed = true
      end

      if vlist.title.zh != slist.title
        vlist.set_title(slist.title, book, user)
        changed = true
      end

      if vlist.volume.zh != slist.volume
        vlist.set_volume(slist.volume, book, user)
        changed = true
      end
    end

    upto.upto(list.size - 1).each do |j|
      self << VChap.new(list[j])
    end

    changed
  end

  def to_s(io : IO)
    to_pretty_json(io)
  end

  def save!(site : String, bsid : String)
    save!(VList.file_path(site, bsid))
  end

  def save!(file : String)
    puts "- save vlist [#{file}]".colorize(:blue)
    File.write(file, to_json)
  end

  def self.dir
    @@dir
  end

  def self.chdir(dir : String)
    @@dir = dir
  end

  def self.file_path(site : String, bsid : String)
    "#{@@dir}/#{site}/#{bsid}.json"
  end

  def self.load(site : String, bsid : String)
    load(file_path(site, bsid))
  end

  def self.load(file : String)
    return new() unless File.exists?(file)
    from_json(File.read(file))
  end

  def self.get(book : VBook)
    site = book.prefer_site
    bsid = book.prefer_bsid
    return nil if bsid.empty?

    get(site, bsid)
  end

  @@cache = {} of String => VList

  def self.get(site : String, bsid : String)
    @@cache["#{site}/#{bsid}"] ||= load(site, bsid)
  end

  def self.save(list : VList, site : String, bsid : String)
    list.save!(site, bsid)
    @@cache["#{site}/#{bsid}"] = list
  end
end
