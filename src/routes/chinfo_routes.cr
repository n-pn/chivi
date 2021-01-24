require "./_route_utils"
require "../filedb/chinfo"

module CV::Server
  get "/api/chseeds/:bhash/:sname" do |env|
    bhash = env.params.url["bhash"]
    sname = env.params.url["sname"]

    unless snvid = ChSource.load(sname)._index.fval(bhash)
      halt env, status_code: 404, response: "Nguồn truyện không tồn tại!"
    end

    chinfo = Chinfo.load(sname, snvid)

    u_power = env.session.int?("u_power") || 0
    mode = env.params.query["mode"]?.try(&.to_i?) || 0
    mode = u_power if mode > u_power

    if mode > 0 && chinfo.fetch!(u_power, mode > 1)
      chinfo.trans!(bhash, u_power > 1)
      chinfo.save!

      nvinfo = Nvinfo.load(bhash)
      nvinfo.set_utime(chinfo._utime)
      chseed = nvinfo.fix_source!
      nvinfo.save!
    end

    skip = RouteUtils.parse_int(env.params.query["skip"]?, min: 0)
    take = RouteUtils.parse_int(env.params.query["take"]?, min: 1, max: 30)

    # if skip >= chinfo.infos.size
    #   skip = (chinfo.chaps.size // limit) * limit
    # end

    RouteUtils.json_res(env) do |res|
      JSON.build(res) do |json|
        json.object do
          json.field "chseed", chseed
          json.field "total", chinfo.infos.size
          json.field "utime", chinfo._utime

          json.field "chaps" do
            json.array do
              desc = env.params.query["order"]? == "desc"

              chinfo.each(skip, take, desc) do |idx, (schid, chitem)|
                json.object do
                  json.field "ch_idx", idx + 1
                  json.field "schid", schid

                  json.field "title", chitem[0]
                  json.field "label", chitem[1]
                  json.field "uslug", chitem[2]
                end
              end
            end
          end
        end
      end
    end
  end
end
