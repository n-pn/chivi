require "json"

require "../../data/wninfo_data"

struct YS::BookView
  def initialize(@data : Wninfo)
  end

  def to_json(io : IO)
    JSON.build(io) { |jb| to_json(jb) }
  end

  def cover_url
    return "/covers/#{@data.bcover}" unless @data.bcover.empty?
    @data.scover.blank? ? "/covers/_blank.webp" : @data.scover
  end

  def to_json(jb = JSON::Builder.new)
    jb.object {
      jb.field "id", @data.id
      jb.field "bslug", "#{@data.id}-#{@data.bslug}"

      jb.field "vauthor", @data.author_vi
      jb.field "vtitle", @data.btitle_vi

      jb.field "genres", @data.genres
      jb.field "bcover", cover_url

      jb.field "voters", @data.voters
      jb.field "rating", @data.rating / 10

      jb.field "status", @data.status
      jb.field "mftime", @data.utime
    }
  end

  def self.as_hash(inp : Enumerable(Wninfo))
    res = {} of Int64 => self
    inp.each { |obj| res[obj.id] = new(obj) }
    res
  end
end
