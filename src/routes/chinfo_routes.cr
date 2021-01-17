require "./_route_utils"
require "../filedb/chinfo"

module CV::Server
  get "/api/chaps/:bhash/:seed" do |env|
    bhash = env.params.url["bhash"]
    seed = env.params.url["seed"]

    unless sbid = ChMeta.load(seed)._index.fval(bhash)
      halt env, status_code: 404, response: "Nguồn truyện không tồn tại!"
    end

    chinfo = Chinfo.load(seed, sbid)

    power = env.session.int?("power") || 0
    mode = env.params.query["mode"]?.try(&.to_i?) || 0
    mode = power if mode > power

    if mode > 0 || chinfo.last_chap.empty?
      chinfo.fetch!(power, mode > 1)
      chinfo.trans!(bhash, power > 1)
    end

    skip = RouteUtils.parse_int(env.params.query["skip"]?, min: 0)
    take = RouteUtils.parse_int(env.params.query["take"]?, min: 1, max: 30)

    # if skip >= chinfo.infos.size
    #   skip = (chinfo.chaps.size // limit) * limit
    # end

    RouteUtils.json_res(env, cached: chinfo.update_tz) do |res|
      JSON.build(res) do |json|
        json.object do
          json.field "total", chinfo.infos.size
          json.field "mtime", chinfo.update_tz

          json.field "chaps" do
            json.array do
              desc = env.params.query["order"]? == "desc"

              chinfo.each(skip, take, desc) do |idx, (scid, vals)|
                json.object do
                  json.field "_idx", idx + 1
                  json.field "scid", scid
                  json.field "title", vals[0]
                  json.field "label", vals[1]
                  json.field "uslug", vals[2]
                end
              end
            end
          end
        end
      end
    end
  end
end
