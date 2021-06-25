module CV::Bgenre
  extend self

  VGENRES = {{ read_file("db/mapping/vgenres.txt").split("\n") }}

  def all(ids : Array(Int32))
    ids.map { |id| vname(id) }
  end

  def vname(idx : Int32)
    VGENRES[idx]? || "Loại khác"
  end

  def index(vname : String)
    VGENRES.index(vname) || 0
  end

  # mapping chinese genre to vietnamese one

  alias Mapping = Hash(String, Array(String))
  class_getter zgenres : Mapping do
    Mapping.from_json("db/mapping/zgenres.json")
  end

  def mapping(zname : String)
    zgenres[zname]? || [] of String
  end
end
