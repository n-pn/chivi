require "./_route_utils"

module CV::Server
  module Utils
    def self.chap_json(json, chidx, infos)
      json.object do
        json.field "chidx", chidx
        json.field "schid", infos[0]
        json.field "title", infos[1]
        json.field "label", infos[2]
        json.field "uslug", infos[3]
      end
    end
  end

  get "/api/chseeds/:bhash/:sname/:snvid" do |env|
    bhash = env.params.url["bhash"]
    sname = env.params.url["sname"]
    snvid = env.params.url["snvid"]

    nvinfo = NvInfo.load(bhash)
    chinfo = ChInfo.load(bhash, sname, snvid)
    u_power, mode = RouteUtils.get_privi(env)

    if mode > 0
      mtime, total = chinfo.fetch!(u_power, mode)
      chinfo.trans!(reset: u_power > 2)

      if mtime >= 0
        nvinfo.set_chseed(sname, snvid, mtime, total)
        NvOrders.save!(clean: false)
        NvChseed.save!(clean: false)
      end
    else
      _, mtime, total = nvinfo.get_chseed(sname)
    end

    RouteUtils.json_res(env) do |res|
      JSON.build(res) do |json|
        json.object do
          json.field "total", total
          json.field "utime", mtime

          json.field "lasts" do
            json.array do
              chinfo.last(4) do |chidx, infos|
                Utils.chap_json(json, chidx, infos)
              end
            end
          end
        end
      end
    end
  end

  get "/api/chitems/:bhash/:sname/:snvid" do |env|
    bhash = env.params.url["bhash"]
    sname = env.params.url["sname"]
    snvid = env.params.url["snvid"]

    skip = RouteUtils.parse_int(env.params.query["skip"]?, min: 0)
    chinfo = ChInfo.load(bhash, sname, snvid)

    RouteUtils.json_res(env) do |res|
      JSON.build(res) do |json|
        json.array do
          chinfo.each(from: skip, upto: skip + 30) do |chidx, infos|
            Utils.chap_json(json, chidx, infos)
          end
        end
      end
    end
  rescue err
    halt env, status_code: 500, response: err.message
  end
end
