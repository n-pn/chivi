require "./base_ctrl"

class CV::CvchapCtrl < CV::BaseCtrl
  def index
    bhash = params["bhash"]
    sname = params["sname"]
    zseed = Zhseed.index(sname)
    pgidx = params.fetch_int("page", min: 1)

    nvinfo = Cvbook.find!({bhash: bhash})
    zhbook = Zhbook.load!(nvinfo, zseed)

    mode = params.fetch_int("mode", max: cu_privi)
    utime, total = zhbook.refresh!(cu_privi, mode)

    render_json do |res|
      JSON.build(res) do |jb|
        jb.object do
          jb.field "sname", sname
          jb.field "utime", utime

          jb.field "wlink", zhbook.wlink
          jb.field "crawl", zhbook.remote?(cu_privi)

          jb.field "total", total

          jb.field "pgidx", pgidx
          jb.field "pgmax", (total - 1) / 32 + 1

          jb.field "lasts" do
            jb.array do
              zhbook.chinfo.last_chaps.each do |chidx, infos|
                chap_json(jb, chidx, infos)
              end
            end
          end

          jb.field "chaps" do
            jb.array do
              zhbook.chinfo.chaps_page(pgidx).each do |chidx, infos|
                chap_json(jb, chidx, infos)
              end
            end
          end
        end
      end
    end
  rescue err
    pp err.inspect_with_backtrace
    halt! 500, err.message
  end

  private def chap_json(jb : JSON::Builder, chidx, infos)
    jb.object do
      jb.field "chidx", chidx
      jb.field "schid", infos[0]
      jb.field "title", infos[1]
      jb.field "label", infos[2]
      jb.field "uslug", infos[3]
    end
  end
end
