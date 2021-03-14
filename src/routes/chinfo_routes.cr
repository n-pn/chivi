require "./_route_utils"
require "../filedb/chinfo"

module CV::Server
  get "/api/chseeds/:bhash/:sname/:snvid" do |env|
    bhash = env.params.url["bhash"]
    sname = env.params.url["sname"]
    snvid = env.params.url["snvid"]

    nvinfo = Nvinfo.load(bhash)
    chinfo = Chinfo.load(bhash, sname, snvid)
    u_power, mode = RouteUtils.get_privi(env)

    if mode > 0
      mtime, total = chinfo.fetch!(u_power, mode)
      nvinfo.put_chseed!(sname, snvid, mtime, total) if mtime >= 0
    else
      _, mtime, total = chinfo.get_latest
    end

    RouteUtils.json_res(env) do |res|
      JSON.build(res) do |json|
        json.object do
          json.field "total", total
          json.field "utime", mtime

          json.field "lasts" do
            chinfo.load_tran("last").data.each do |index, infos|
              next if index == "_"

              json.object do
                json.field "chidx", total - index.to_i
                json.field "schid", infos[0]
                json.field "title", infos[1]
                json.field "label", infos[2]
                json.field "uslug", infos[3]
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

    chinfo = Chinfo.load(bhash, sname, snvid)

    take = RouteUtils.parse_int(env.params.query["take"]?, min: 1, max: 30)
    skip = RouteUtils.parse_int(env.params.query["skip"]?, min: 0)
    skip = (chinfo.heads.size // take) * take if skip >= chinfo.heads.size

    RouteUtils.json_res(env) do |res|
      JSON.build(res) do |json|
        chinfo.json_each(json, skip, take)
      end
    end
  rescue err
    halt env, status_code: 500, response: err.message
  end
end
