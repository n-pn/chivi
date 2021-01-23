require "./_route_utils"
require "../filedb/chinfo"

module CV::Server
  get "/api/chseeds/:b_hash/:s_name" do |env|
    b_hash = env.params.url["b_hash"]
    s_name = env.params.url["s_name"]

    unless s_nvid = ChSource.load(s_name)._index.fval(b_hash)
      halt env, status_code: 404, response: "Nguồn truyện không tồn tại!"
    end

    chinfo = Chinfo.load(s_name, s_nvid)

    u_power = env.session.int?("u_power") || 0
    mode = env.params.query["mode"]?.try(&.to_i?) || 0
    mode = u_power if mode > u_power

    if mode > 0 && chinfo.fetch!(u_power, mode > 1)
      chinfo.trans!(b_hash, u_power > 1)
      chinfo.save!

      chseed = Nvinfo.load(b_hash).fix_source!
      NvValues.source.save!(mode: :upds)
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

              chinfo.each(skip, take, desc) do |idx, (s_chid, chitem)|
                json.object do
                  json.field "ch_idx", idx + 1
                  json.field "s_chid", s_chid

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
