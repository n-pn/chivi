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
      jb.field "hname", @data.hname
      jb.field "vname", @data.vname

      jb.field "author", @data.author.vname

      jb.field "genres", @data.genres
      jb.field "bcover", @data.bcover

      jb.field "voters", @data.voters
      jb.field "rating", @data.rating / 10

      if @full
        jb.field "zseeds", @data.zseeds
        jb.field "bintro", @data.vintro.split("\n")

        jb.field "mftime", @data.utime
        jb.field "status", map_status(@data.status)

        jb.field "ys_snvid", @data.ys_snvid
        jb.field "pub_link", @data.pub_link
        jb.field "pub_name", @data.pub_name
        jb.field "author_id", @data.author_id
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
