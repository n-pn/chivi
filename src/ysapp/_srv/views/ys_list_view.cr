require "json"
require "../../data/yslist"

struct YS::ListView
  def initialize(@data : Yslist, @full = false)
  end

  def to_json(io : IO)
    JSON.build(io) { |jb| to_json(jb) }
  end

  def to_json(jb = JSON::Builder.new)
    jb.object do
      jb.field "id", @data.id
      jb.field "user_id", @data.ysuser_id

      jb.field "vname", @data.vname
      jb.field "vslug", @data.vslug

      jb.field "klass", @data.klass
      jb.field "book_count", @data.book_count

      if @full
        jb.field "orig_id", @data.yl_id.join(&.to_s(base: 16))
        jb.field "vdesc", @data.vdesc

        jb.field "genres", @data.genres
        jb.field "covers", @data.covers

        jb.field "like_count", @data.like_count
        jb.field "view_count", @data.view_count
        jb.field "star_count", @data.star_count

        jb.field "ctime", @data.created_at.to_unix
        jb.field "utime", @data.utime
      end
    end
  end

  def self.as_list(inp : Enumerable(Yslist), full = false)
    inp.map { |obj| new(obj, full: full) }
  end

  def self.as_hash(data : Enumerable(Yslist))
    hash = {} of Int64 => self
    data.each { |obj| hash[obj.id] = new(obj) }
    hash
  end
end
