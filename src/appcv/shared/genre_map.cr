require "tabkv"

module CV::GenreMap
  extend self

  DIR = "var/_common/fixes"

  class_getter zh_map : Tabkv(Array(String)) { Tabkv(Array(String)).new("#{DIR}/genres_zh.tsv") }
  class_getter vi_map : Tabkv(String) { Tabkv(String).new("#{DIR}/genres_vi.tsv") }
  class_getter id_map : Tabkv(Int32) { Tabkv(Int32).new("#{DIR}/genres_id.tsv") }

  def map_id(input : String) : Int32
    id_map[input.strip]
  end

  def map_id(input : Array(String)) : Array(Int32)
    input.map { |x| map_id(x) }.uniq
  end

  def to_s(ids : Array(Int32)) : Array(String)
    ids.map { |id| to_s(id) }
  end

  def to_s(index : Int32) : String
    vi_map[index.to_s]? || "Loại khác"
  end

  # mapping chinese genre to vietnamese one
  def map_zh(input : String) : Array(String)
    input == "轻小说" ? input : input.sub("小说", "")
    zh_map[input]? || [] of String
  end

  def map_zh(input : Array(String)) : Array(String)
    input.map { |x| map_zh(x) }.flatten.uniq
  end
end
