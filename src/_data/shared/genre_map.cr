require "tabkv"

module CV::GenreMap
  extend self

  DIR = "/srv/chivi/_conf/fixes"

  class_getter zh_map : Tabkv(Array(String)) { Tabkv(Array(String)).new("#{DIR}/genres_zh.tsv") }
  class_getter vi_map : Tabkv(String) { Tabkv(String).new("#{DIR}/genres_vi.tsv") }
  class_getter vz_map : Tabkv(String) { Tabkv(String).new("#{DIR}/genres_vz.tsv") }
  class_getter id_map : Tabkv(Int32) { Tabkv(Int32).new("#{DIR}/genres_id.tsv") }

  def map_int(input : String) : Int32
    id_map[input]? || -1
  end

  def map_int(input : Array(String)) : Array(Int32)
    input.map { |x| map_int(x) }.reject(&.< 0)
  end

  def to_str(ids : Array(Int32)) : Array(String)
    ids.map { |id| to_str(id) }
  end

  def to_str(index : Int32) : String
    vi_map[index.to_s]? || "Loại khác"
  end

  # mapping chinese genre to vietnamese one
  def zh_to_vi(input : String) : Array(String)
    input == "轻小说" ? input : input.sub("小说", "")
    zh_map[input]? || [""]
  end

  def zh_to_vi(zgenres : Array(String)) : Array(String)
    vgenres = zgenres.each_with_object([] of String) do |zgenre, output|
      zh_map[zgenre]?.try { |x| output.concat(x) }
    end

    vgenres.uniq!
  end

  def vi_to_zh(input : String) : String
    vz_map[input]? || "其他"
  end

  def vi_to_zh(input : Array(String)) : Array(String)
    input.flat_map { |x| vi_to_zh(x) }.uniq!
  end
end
