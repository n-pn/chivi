require "./_route_utils"

module CV::Server
  get "/api/chinfos/:sname/:snvid/:chidx" do |env|
    sname = env.params.url["sname"]
    snvid = env.params.url["snvid"]

    index = env.params.url["chidx"].to_i? || 100000
    index = 1 if index < 1

    chinfo = Chinfo.load(sname, snvid)
    unless curr_chap = chinfo.heads[index - 1]?
      halt env, status_code: 404, response: "Chương tiết không tồn tại!"
    end

    RouteUtils.json_res(env) do |res|
      JSON.build(res) do |json|
        json.object do
          json.field "total", chinfo.heads.size
          json.field "schid", curr_chap[0]
          json.field "title", curr_chap[1]
          json.field "label", curr_chap[2]
          json.field "prev_url", chinfo.url_for(index - 2)
          json.field "next_url", chinfo.url_for(index)
        end
      end
    end
  rescue err
    puts "- Error loading chap_text: #{err}"
    message = err.message || "Unknown error!"
    halt env, status_code: 500, response: message
  end

  get "/api/chtexts/:sname/:snvid/:schid" do |env|
    sname = env.params.url["sname"]
    snvid = env.params.url["snvid"]
    schid = env.params.url["schid"]

    u_power = env.session.int?("u_power") || 0
    mode = env.params.query["mode"]?.try(&.to_i?) || 0
    mode = u_power if mode > u_power

    chtext = Chtext.load(sname, snvid, schid)
    chtext.fetch!(u_power) if mode > 1 || chtext.zh_lines.empty?

    unless mode == 0 && chtext.translated?(Time.utc - 3.hours)
      dname = env.params.query["dname"]? || "various"
      chtext.trans!(dname)
    end

    env.response.content_type = "text/plain; charset=utf-8"
    chtext.cv_trans
  rescue err
    puts "- Error loading chap_text: #{err}"
    message = err.message || "Unknown error!"
    halt env, status_code: 500, response: message
  end
end
