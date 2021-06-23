require "./base_ctrl"

class CV::ChapCtrl < CV::BaseCtrl
  def index
    bhash = params["bhash"]
    sname = params["sname"]
    snvid = params["snvid"]

    nvinfo = NvInfo.load(bhash)
    chinfo = ChInfo.load(bhash, sname, snvid)

    mode = params.fetch_int("mode")
    mode = cu_privi if mode > cu_privi

    if mode > 0
      mtime, total = chinfo.fetch!(cu_privi, mode)
      chinfo.trans!(reset: cu_privi > 2)

      if mtime >= 0
        nvinfo.set_chseed(sname, snvid, mtime, total)
        NvOrders.save!(clean: false)
        NvChseed.save!(clean: false)
      end
    else
      _, mtime, total = nvinfo.get_chseed(sname)
    end

    render_json do |res|
      JSON.build(res) do |json|
        json.object do
          json.field "total", total
          json.field "utime", mtime

          json.field "lasts" do
            json.array do
              chinfo.last(4) do |chidx, infos|
                chap_json(json, chidx, infos)
              end
            end
          end
        end
      end
    end
  end

  def paged
    bhash = params["bhash"]
    sname = params["sname"]
    snvid = params["snvid"]

    page = params.fetch_int("page", min: 1)

    take = 32
    skip = (page - 1) * take

    chinfo = ChInfo.load(bhash, sname, snvid)

    render_json do |res|
      JSON.build(res) do |json|
        json.array do
          chinfo.each(from: skip, upto: skip + take) do |chidx, infos|
            chap_json(json, chidx, infos)
          end
        end
      end
    end
  rescue err
    halt!(500, err.message)
  end

  private def chap_json(json : JSON::Builder, chidx, infos)
    json.object {
      json.field "chidx", chidx
      json.field "schid", infos[0]
      json.field "title", infos[1]
      json.field "label", infos[2]
      json.field "uslug", infos[3]
    }
  end
end
