require "./_base_view"

struct CV::WnovelView
  include BaseView

  def initialize(@data : Nvinfo, @full = true)
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "id", @data.id
      jb.field "bslug", @data.bslug.sub(/^\w+/, @data.id)

      jb.field "author_vi", @data.author.vname
      jb.field "btitle_vi", @data.vname

      jb.field "genres", @data.vgenres
      jb.field "bcover", @data.bcover
      jb.field "scover", @data.scover

      jb.field "status", @data.status
      jb.field "mftime", @data.utime

      jb.field "voters", @data.voters
      jb.field "rating", @data.rating / 10

      if @full
        jb.field "bhash", @data.bhash

        jb.field "bintro", @data.bintro
        jb.field "labels", @data.vlabels

        jb.field "author_zh", @data.author.zname
        jb.field "btitle_zh", @data.btitle.zname
        jb.field "btitle_hv", @data.btitle.hname

        if ysbook = @data.ysbook
          jb.field "ys_snvid", ysbook.id
          jb.field "pub_link", ysbook.pub_link
          jb.field "pub_name", ysbook.pub_name
        end
      end
    end
  end

  def self.map(inp : Enumerable(Nvinfo), full = false)
    res = [] of self
    inp.each { |obj| res << new(obj, full) }
    res
  end
end
