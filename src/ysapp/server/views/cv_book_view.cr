require "json"

require "../../models/cv_book"

struct YS::BookView
  def initialize(@data : CvBook)
  end

  def to_json(io : IO)
    JSON.build(io) { |jb| to_json(jb) }
  end

  def to_json(jb = JSON::Builder.new)
    {
      id:    @data.id,
      bslug: @data.bslug,

      author: @data.author.vname,
      btitle: @data.vname,

      bgenre: @data.bgenre,
      bcover: @data.bcover,
      scover: @data.scover,

      voters: @data.voters,
      rating: @data.rating / 10,

      status: @data.status,
      update: @data.utime,
    }
  end

  def self.as_hash(inp : Enumerable(CvBook))
    res = {} of Int64 => self
    inp.each { |obj| res[obj.id] = new(obj) }
    res
  end
end
