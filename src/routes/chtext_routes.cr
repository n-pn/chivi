require "./_route_utils"

module CV::Server
  get "/api/chinfos/:bhash/:sname/:snvid/:chidx" do |env|
    bhash = env.params.url["bhash"]
    sname = env.params.url["sname"]
    snvid = env.params.url["snvid"]

    chidx = env.params.url["chidx"].to_i? || 100000
    chidx = 1 if chidx < 1

    chinfo = Chinfo.load(bhash, sname, snvid)
    unless curr_chap = chinfo.get_info(chidx - 1)
      halt env, status_code: 404, response: "Chương tiết không tồn tại!"
    end

    RouteUtils.json_res(env) do |res|
      JSON.build(res) do |json|
        json.object do
          json.field "total", chinfo.origs.size
          json.field "chidx", chidx
          json.field "schid", curr_chap[0]
          json.field "title", curr_chap[1]
          json.field "label", curr_chap[2]
          json.field "prev_url", chinfo.url_for(chidx - 2)
          json.field "next_url", chinfo.url_for(chidx)
        end
      end
    end
  rescue err
    puts "- Error loading chap_text: #{err}"
    message = err.message || "Unknown error!"
    halt env, status_code: 500, response: message
  end

  get "/api/chtexts/:bhash/:sname/:snvid/:chidx/:schid" do |env|
    bhash = env.params.url["bhash"]
    sname = env.params.url["sname"]
    snvid = env.params.url["snvid"]

    chidx = env.params.url["chidx"].to_i
    schid = env.params.url["schid"]

    u_power = env.session.int?("u_power") || 0
    mode = env.params.query["mode"]?.try(&.to_i?) || 0
    mode = u_power if mode > u_power

    chinfo = Chinfo.load(bhash, sname, snvid)

    env.response.content_type = "text/plain; charset=utf-8"
    chinfo.get_cvdata!(chidx, schid, mode, u_power)
  rescue err
    puts "- Error loading chap_text: #{err}"
    message = err.message || "Unknown error!"
    halt env, status_code: 500, response: message
  end
end
