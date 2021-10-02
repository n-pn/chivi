require "json"

module CV::CvbookView
  extend self

  def render(jb : JSON::Builder, obj : Cvbook, full = true)
    jb.object do
      jb.field "id", obj.id
      jb.field "bhash", obj.bhash
      jb.field "bslug", obj.bslug

      jb.field "ztitle", obj.ztitle
      jb.field "htitle", obj.htitle
      jb.field "vtitle", obj.vtitle.empty? ? obj.htitle : obj.vtitle

      jb.field "zauthor", obj.author.zname
      jb.field "vauthor", obj.author.vname

      jb.field "genres", obj.bgenres
      jb.field "bcover", obj.bcover

      jb.field "voters", obj.voters
      jb.field "rating", obj.rating / 10.0

      if full
        jb.field "bintro", obj.bintro.split("\n")

        jb.field "mftime", obj.mftime
        jb.field "status", map_status(obj.status)

        if ysbook = obj.ysbooks[0]?
          jb.field "yousuu_id", ysbook.id
          jb.field "root_link", ysbook.root_link
          jb.field "root_name", ysbook.root_name
        end

        jb.field "snames", obj.zhseeds
        jb.field "chseed" do
          jb.object do
            obj.zhbooks.each do |zhbook|
              jb.field zhbook.sname, zhbook.snvid
            end
          end

          jb.field "chivi", obj.bhash
        end
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
