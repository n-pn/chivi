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
      jb.field "bslug", "#{@data.id}-#{@data.bslug}"

      jb.field "vauthor", @data.author.vname
      jb.field "vtitle", @data.vname

      jb.field "genres", @data.genres
      jb.field "bcover", @data.bcover
      jb.field "scover", @data.scover

      jb.field "voters", @data.voters
      jb.field "rating", @data.rating / 10

      jb.field "status", @data.status
      jb.field "mftime", @data.utime
    }
  end

  def self.as_hash(inp : Enumerable(CvBook))
    res = {} of Int64 => self
    inp.each { |obj| res[obj.id] = new(obj) }
    res
  end
end
