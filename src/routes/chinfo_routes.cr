require "./_route_utils"
require "../filedb/chinfo"

module CV::Server
  get "/api/chseeds/:sname/:snvid" do |env|
    sname = env.params.url["sname"]
    snvid = env.params.url["snvid"]
    chinfo = Chinfo.load(sname, snvid)

    u_power, mode = RouteUtils.get_privi(env)

    if mode > 0
      bhash = env.params.query["bhash"]? || "various"

      if chinfo.fetch!(u_power, mode > 1)
        if sname != "hetushu" || sname != "zhwenpg" || sname != "69shu"
          nvinfo = Nvinfo.load(bhash)
          nvinfo.set_utime(chinfo._utime)
          chseed = nvinfo.fix_source!
          nvinfo.save!
        end
      end

      chinfo.trans!(bhash, u_power > 1)
      chinfo.save!
    end

    RouteUtils.json_res(env) do |res|
      JSON.build(res) do |json|
        json.object do
          json.field "total", chinfo.heads.size
          json.field "utime", chinfo._utime

          json.field "lasts" do
            chinfo.json_each(json, 0, 6, true)
          end
        end
      end
    end
  end

  get "/api/chitems/:sname/:snvid" do |env|
    sname = env.params.url["sname"]
    snvid = env.params.url["snvid"]
    chinfo = Chinfo.load(sname, snvid)

    take = RouteUtils.parse_int(env.params.query["take"]?, min: 1, max: 30)
    skip = RouteUtils.parse_int(env.params.query["skip"]?, min: 0)
    skip = (chinfo.heads.size // take) * take if skip >= chinfo.heads.size

    desc = env.params.query["order"]? == "desc"

    RouteUtils.json_res(env) do |res|
      JSON.build(res) do |json|
        chinfo.json_each(json, skip, take, desc)
      end
    end
  rescue err
    halt env, status_code: 500, response: err.message
  end
end
