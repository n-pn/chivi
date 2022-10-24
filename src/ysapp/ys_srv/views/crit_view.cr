require "json"

require "../../models/ys_crit"

struct YS::CritView
  def initialize(@data : Yscrit, @full = false)
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

      if book = @data.nvinfo || CV::Nvinfo.find({id: @data.nvinfo_id})
        jb.field "book", {
          id:    book.id,
          bslug: book.bslug,

          author: book.author.vname,
          btitle: book.vname,

          bgenre: book.vgenres.first? || "Loại khác",

          bcover: book.bcover,
          scover: book.scover,

          voters: book.voters,
          rating: book.rating / 10,

          status: book.status,
          update: book.utime,
        }
      else
        jb.field "book", {id: 0}
      end

      if yslist = @data.yslist
        jb.field "yslist_id", CV::UkeyUtil.encode32(yslist.id)

        jb.field "yslist_vname", yslist.vname
        jb.field "yslist_vslug", yslist.vslug

        jb.field "yslist_class", yslist.klass
        jb.field "yslist_count", yslist.book_count
      end
    rescue err
      puts err, @data.id
    end
  end

  def self.map(inp : Enumerable(Yscrit), full = false)
    res = [] of CritView
    inp.each { |obj| res << new(obj, full) }
    res
  end
end
