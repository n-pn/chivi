require "json"

struct CV::YslistView
  def initialize(@data : Yslist, @full = false)
  end

  def to_json(io : IO)
    JSON.build(io) { |jb| to_json(jb) }
  end

  def to_json(jb = JSON::Builder.new)
    jb.object do
      jb.field "id", UkeyUtil.encode32(@data.id)

      jb.field "op_id", @data.ysuser.id
      jb.field "uname", @data.ysuser.vname
      jb.field "uslug", @data.ysuser.vslug

      jb.field "vname", @data.vname
      jb.field "vslug", @data.vslug

      jb.field "vdesc", @data.vdesc
      jb.field "class", @data.klass

      jb.field "genres", @data.genres
      jb.field "covers", @data.covers

      jb.field "book_count", @data.book_count
      jb.field "like_count", @data.like_count
      jb.field "view_count", @data.view_count
      jb.field "star_count", @data.star_count

      jb.field "ctime", @data.created_at.to_unix
      jb.field "utime", @data.utime
    end
  end
end
