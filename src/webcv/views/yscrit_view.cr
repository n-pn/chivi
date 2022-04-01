require "json"

struct CV::YscritView
  def initialize(@data : Yscrit)
  end

  def to_json(io : IO)
    JSON.build(io) { |jb| to_json(jb) }
  end

  def to_json(jb = JSON::Builder.new)
    jb.object do
      jb.field "bid", @data.nvinfo.id
      jb.field "bname", @data.nvinfo.vname
      jb.field "bslug", @data.nvinfo.bslug
      jb.field "bhash", @data.nvinfo.bhash

      jb.field "author", @data.nvinfo.author.vname
      jb.field "bgenre", @data.nvinfo.vgenres.first? || "Loại khác"

      jb.field "uname", @data.ysuser.vname
      jb.field "uslug", @data.ysuser.id

      jb.field "id", UkeyUtil.encode32(@data.id)

      jb.field "stars", @data.stars
      jb.field "vhtml", @data.vhtml

      jb.field "like_count", @data.like_count
      jb.field "repl_count", @data.repl_count

      jb.field "mftime", @data.utime
    end
  end
end
