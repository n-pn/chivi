require "json"

module CV::NvinfoView
  extend self

  def render(jb : JSON::Builder, obj : Nvinfo, full = true)
    jb.object do
      jb.field "id", obj.id
      jb.field "bhash", obj.bhash
      jb.field "bslug", obj.bslug

      jb.field "ztitle", obj.zname
      jb.field "htitle", obj.hname
      jb.field "vtitle", obj.vname

      jb.field "vauthor", obj.author.vname

      jb.field "genres", obj.genres
      jb.field "bcover", obj.cover

      jb.field "voters", obj.voters
      jb.field "rating", obj.rating / 10

      if full
        jb.field "author_id", obj.author_id

        jb.field "bintro", obj.intro.split("\n")

        jb.field "mftime", obj.utime
        jb.field "status", map_status(obj.status)

        jb.field "yousuu_id", obj.ys_snvid
        jb.field "root_link", obj.pub_link
        jb.field "root_name", obj.pub_name

        jb.field "snames", obj.zseeds
        jb.field "chseed" do
          zhbooks = obj.zhbooks.to_a.sort_by do |x|
            x.zseed == 0 ? 99 : x.zseed
          end

          jb.array do
            zhbooks.each do |zhbook|
              jb.object {
                jb.field "sname", zhbook.sname
                jb.field "snvid", zhbook.snvid
                # jb.field "wlink", zhbook.wlink
                # jb.field "utime", zhbook.mftime
                jb.field "chaps", zhbook.chap_count
                jb.field "_seed", Zhseed::REMOTES.includes?(zhbook.sname)
              }
            end
          end
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
