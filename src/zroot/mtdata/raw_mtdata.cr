require "json"

require "./raw_zctree"
require "./raw_entity"

struct ZR::RawMtdata
  include JSON::Serializable

  @[JSON::Field(key: "tok/fine")]
  getter tok : Array(String)

  @[JSON::Field(key: "pos/ctb")]
  getter pos : Array(String) = [] of String

  @[JSON::Field(key: "con")]
  getter con : RawConsti

  @[JSON::Field(key: "ner/msra")]
  getter ner_msra : Array(RawEntity) = [] of RawEntity

  @[JSON::Field(key: "ner/ontonotes")]
  getter ner_onto : Array(RawEntity) = [] of RawEntity

  @[JSON::Field(ignore: true)]
  getter ner : Array(RawEntity) do
    lst = [] of RawEntity
    lst.concat(ner_msra)
    lst.concat(ner_onto)
    lst.uniq!(&.zstr)
  end

  def self.from_file(file : String)
    File.open(file, "r") { |f| from_json(f) }
  end
end

struct ZR::RawMtlist
  include JSON::Serializable

  @[JSON::Field(key: "tok/fine")]
  getter tok : Array(Array(String))

  @[JSON::Field(key: "pos/ctb")]
  getter pos : Array(Array(String)) = [] of Array(String)

  @[JSON::Field(key: "con")]
  getter con : Array(RawConsti)

  @[JSON::Field(key: "ner/msra")]
  getter ner_msra : Array(Array(RawEntity)) = [] of Array(RawEntity)

  @[JSON::Field(key: "ner/ontonotes")]
  getter ner_onto : Array(Array(RawEntity)) = [] of Array(RawEntity)

  @[JSON::Field(ignore: true)]
  getter ner : Array(Array(RawEntity)) do
    Array(Array(RawEntity)).new(size: @tok.size) do |idx|
      lst = [] of RawEntity
      lst.concat(ner_msra[idx])
      lst.concat(ner_onto[idx])
      lst.uniq!(&.zstr)
    end
  end

  def self.from_file(file : String)
    File.open(file, "r") { |f| from_json(f) }
  end

  # data = from_file("var/zroot/test.mtl")

  # test = data.con.first
  # redo = RawConsti.from_json(test.to_json)
  # puts test == redo

  # puts data.ner_msra.to_json
end
