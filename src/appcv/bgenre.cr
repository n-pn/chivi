require "../cutil/tsv_store"

module CV::Bgenre
  extend self

  VI_NAMES = {{ read_file("db/fixtures/vi_genres.txt").strip.split("\n") }}
  class_getter zh_names : TsvStore { TsvStore.new("db/fixtures/zh_genres.tsv") }

  def all(ids : Array(Int32))
    ids.map { |id| vname(id) }
  end

  def vname(idx : Int32)
    VI_NAMES[idx]? || "Loại khác"
  end

  def map_id(vname : String)
    VI_NAMES.index(vname) || 0
  end

  def map_ids(vnames : Array(String))
    vnames.map { |x| map_id(x) }.uniq
  end

  def zh_vname(zname : String)
    zh_names.get(zname) || [] of String
  end

  # mapping chinese genre to vietnamese one
  def zh_map_id(zname : String)
    zh_vname(zname).map { |vname| map_id(vname) }
  end

  def zh_map_ids(znames : Array(String))
    znames.map do |zname|
      zname = zname.sub("小说", "") unless zname == "轻小说"
      zh_map_id(zname)
    end.flatten.uniq
  end
end
