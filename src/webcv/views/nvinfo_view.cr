require "./_base_view"

struct CV::NvinfoView
  include BaseView

  def initialize(@data : Nvinfo, @full = true)
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "id", @data.id
      jb.field "bhash", @data.bhash
      jb.field "bslug", @data.bslug

      jb.field "zname", @data.zname
      jb.field "hname", @data.btitle.hname
      jb.field "vname", @data.btitle.vname

      jb.field "author", ({
        zname: @data.author.zname,
        vname: @data.author.vname,
      })

      jb.field "genres", @data.vgenres

      jb.field "scover", @data.scover
      jb.field "bcover", @data.bcover.empty

      jb.field "status", @data.status
      jb.field "mftime", @data.utime

      jb.field "voters", @data.voters
      jb.field "rating", @data.rating / 10

      if @full
        jb.field "snames", @data.snames
        jb.field "bintro", @data.vintro.split("\n")

        jb.field "ys_snvid", @data.ysbook_id
        jb.field "pub_link", @data.pub_link
        jb.field "pub_name", @data.pub_name
      end
    end
  end
end
