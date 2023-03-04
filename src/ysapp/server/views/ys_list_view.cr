require "json"
require "../../models/ys_list"

struct YS::ListView
  def initialize(@data : Yslist, @full = false)
  end

  def to_json(io : IO)
    JSON.build(io) { |jb| to_json(jb) }
  end

  def to_json(jb = JSON::Builder.new)
    jb.object do
      jb.field "id", HashUtil.encode32(@data.id)
      jb.field "user_id", @data.ysuser_id

      jb.field "vname", @data.vname
      jb.field "vslug", @data.vslug

      jb.field "class", @data.klass
      jb.field "book_count", @data.book_count

      if @full
        jb.field "yl_id", @data.origin_id
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
