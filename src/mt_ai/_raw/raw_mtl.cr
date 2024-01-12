require "json"
require "http/client"

require "./raw_con"
require "./raw_dep"
require "./raw_ent"

struct MT::RawMtl
  include JSON::Serializable

  @[JSON::Field(key: "tok")]
  getter tok : Array(String) { @tok_fine }

  @[JSON::Field(key: "tok/fine")]
  getter tok_fine : Array(String)

  @[JSON::Field(key: "con")]
  getter con : RawCon

  @[JSON::Field(key: "dep")]
  getter dep : Array(RawDep)

  @[JSON::Field(key: "pos/ctb")]
  getter pos : Array(String) = [] of String

  @[JSON::Field(key: "ner/msra")]
  getter ner_msra : Array(RawEnt) = [] of RawEnt

  @[JSON::Field(key: "ner/ontonotes")]
  getter ner_onto : Array(RawEnt) = [] of RawEnt

  def self.from_file(file : String)
    File.open(file, "r") { |f| from_json(f) }
  end
end

struct MT::RawMtlBatch
  include JSON::Serializable

  @[JSON::Field(key: "tok")]
  getter tok : Array(Array(String)) { @tok_fine }

  @[JSON::Field(key: "tok/fine")]
  getter tok_fine : Array(Array(String))

  @[JSON::Field(key: "con")]
  getter con = [] of RawCon

  @[JSON::Field(key: "dep")]
  getter dep = [] of Array(RawDep)

  @[JSON::Field(key: "pos/ctb")]
  getter pos : Array(Array(String)) = [] of Array(String)

  @[JSON::Field(key: "ner/msra")]
  getter ner_msra = [] of Array(RawEnt)

  @[JSON::Field(key: "ner/ontonotes")]
  getter ner_onto = [] of Array(RawEnt)

  # def to_mcache
  #   self.tok.map_with_index do |tok, idx|
  #     MCache.new(
  #       rid: MCache.gen_rid(tok),
  #       tok: tok.join('\t'),
  #       con: @con[idx]?.try(&.to_json) || "",
  #       dep: @dep[idx]?.try(&.to_json) || "[]",
  #       msra: @ner_msra[idx]?.try(&.to_json) || "[]",
  #       onto: @ner_onto[idx]?.try(&.to_json) || "[]",
  #       uname: "", mtime: 0,
  #     )
  #   end
  # end

  ###

  def self.from_file(file : String)
    File.open(file, "r") { |f| from_json(f) }
  end

  def self.call_hanlp(text : String, ver : Int16 = 1_i16) : self
    link = "http://localhost:5555/mtl_text/mtl_#{ver}"

    HTTP::Client.post(link, body: text) do |res|
      raise "error: #{res.body_io.gets_to_end}" unless res.status.success?
      from_json(res.body_io)
    end
  end

  # data = from_file("var/zroot/test.mtl")

  # test = data.con.first
  # redo = RawCon.from_json(test.to_json)
  # pp test
  # puts test == redo

  # puts data.ner_msra.to_json
end
