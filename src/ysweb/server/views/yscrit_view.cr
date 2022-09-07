require "json"
require "../../../_util/ukey_util"

struct YS::YscritView
  def initialize(@data : CV::Yscrit, @full = false)
  end

  def to_json(io : IO)
    JSON.build(io) { |jb| to_json(jb) }
  end

  def to_json(jb = JSON::Builder.new)
    jb.object do
      jb.field "op_id", @data.ysuser.id
      jb.field "uname", @data.ysuser.vname
      jb.field "uslug", @data.ysuser.vslug

      jb.field "id", CV::UkeyUtil.encode32(@data.id)

      jb.field "stars", @data.stars
      jb.field "vtags", @data.vtags
      jb.field "vhtml", @data.vhtml

      jb.field "like_count", @data.like_count
      jb.field "repl_count", @data.repl_count

      jb.field "ctime", @data.created_at.to_unix
      jb.field "utime", @data.utime

      jb.field "book", {
        id:    @data.nvinfo.id,
        bslug: @data.nvinfo.bslug,

        author: @data.nvinfo.author.vname,
        btitle: @data.nvinfo.vname,

        bgenre: @data.nvinfo.vgenres.first? || "Loại khác",

        bcover: @data.nvinfo.bcover,
        scover: @data.nvinfo.scover,

        voters: @data.nvinfo.voters,
        rating: @data.nvinfo.rating / 10,

        status: @data.nvinfo.status,
        update: @data.nvinfo.utime,
      }

      if yslist = @data.yslist
        jb.field "yslist_id", CV::UkeyUtil.encode32(yslist.id)

        jb.field "yslist_vname", yslist.vname
        jb.field "yslist_vslug", yslist.vslug

        jb.field "yslist_class", yslist.klass
        jb.field "yslist_count", yslist.book_count
      end
    end
  end

  def self.map(inp : Enumerable(CV::Yscrit), full = false)
    res = [] of YscritView
    inp.each { |obj| res << new(obj, full) }
    res
  end
end
