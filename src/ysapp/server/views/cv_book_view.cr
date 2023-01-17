require "json"

require "../../models/cv_book"

struct YS::BookView
  def initialize(@data : CvBook)
  end

  def to_json(io : IO)
    JSON.build(io) { |jb| to_json(jb) }
  end

  def to_json(jb = JSON::Builder.new)
    jb.object {
      jb.field "id", @data.id
      jb.field "bslug", @data.bslug

      jb.field "author", @data.author.vname
      jb.field "btitle", @data.vname

      jb.field "bgenre", @data.bgenre
      jb.field "bcover", @data.bcover
      jb.field "scover", @data.scover

      jb.field "voters", @data.voters
      jb.field "rating", @data.rating / 10

      jb.field "status", @data.status
      jb.field "update", @data.utime
    }
  end

  def self.as_hash(inp : Enumerable(CvBook))
    res = {} of Int64 => self
    inp.each { |obj| res[obj.id] = new(obj) }
    res
  end
end
