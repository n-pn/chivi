require "tabkv"

module CV::Bgenre
  extend self

  DIR = "var/nvinfos/fixes"

  GENRES = File.read_lines("#{DIR}/vi_genres.txt").reject(&.empty?)
  class_getter map_name : Tabkv { Tabkv.new("#{DIR}/zh_genres.tsv") }

  def vname(ids : Array(Int32))
    ids.map { |id| vname(id) }
  end

  def vname(index : Int32)
    GENRES[index]? || "Loại khác"
  end

  def map_vi(vname : String)
    GENRES.index(vname) || 0
  end

  def map_vi(vnames : Array(String))
    vnames.map { |x| index(x) }.uniq
  end

  def cv_name(zname : String)
    map_name.get(zname) || [] of String
  end

  # mapping chinese genre to vietnamese one
  def map_zh(zname : String) : Array(Int32)
    cv_name(zname).map { |vname| map_vi(vname) }
  end

  def map_zh(znames : Array(String)) : Array(Int32)
    znames.map do |zname|
      map_zh(zname == "轻小说" ? zname : zname.sub("小说", ""))
    end.flatten.uniq
  end
end
