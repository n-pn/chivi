require "json"

module CV::NvinfoView
  extend self

  def render(jb : JSON::Builder, obj : Nvinfo, full = true)
    jb.object do
      jb.field "id", obj.id
      jb.field "bhash", obj.bhash
      jb.field "bslug", obj.bslug

      jb.field "zname", obj.zname
      jb.field "hname", obj.hname
      jb.field "vname", obj.vname

      jb.field "author", obj.author.vname

      jb.field "genres", obj.genres
      jb.field "bcover", obj.cover

      jb.field "voters", obj.voters
      jb.field "rating", obj.rating / 10

      if full
        jb.field "zseeds", obj.zseeds
        jb.field "bintro", obj.intro.split("\n")

        jb.field "mftime", obj.utime
        jb.field "status", map_status(obj.status)

        jb.field "ys_snvid", obj.ys_snvid
        jb.field "pub_link", obj.pub_link
        jb.field "pub_name", obj.pub_name
        jb.field "author_id", obj.author_id
      end
    end
  end

  private def map_status(status : Int32)
    case status
    when 0 then "Còn tiếp"
    when 1 then "Hoàn thành"
    when 2 then "Thái giám"
    else        "Không rõ"
    end
  end
end
