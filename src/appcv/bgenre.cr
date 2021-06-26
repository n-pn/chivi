require "../tsvfs/value_map"

module CV::Bgenre
  extend self

  DIR = "db/fixtures"

  VI_NAMES = {{ read_file("#{DIR}/vi_genres.txt").strip.split("\n") }}
  class_getter zh_names : ValueMap { ValueMap.new("#{DIR}/zh_genres.tsv") }

  def all(ids : Array(Int32))
    ids.map { |id| vname(id) }
  end

  def vname(idx : Int32)
    VI_NAMES[idx]? || "Loại khác"
  end

  # mapping chinese genre to vietnamese one
  def vnames(zname : String)
    zh_names.get(zname) || [] of String
  end

  def index(vname : String)
    VI_NAMES.index(vname) || 0
  end
end
