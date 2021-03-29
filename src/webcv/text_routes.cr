require "./_route_utils"

require "../appcv/ch_info"
require "../appcv/ch_text"

module CV::Server
  get "/api/chinfos/:bname/:sname/:snvid/:chidx" do |env|
    bname = env.params.url["bname"]
    sname = env.params.url["sname"]
    snvid = env.params.url["snvid"]

    index = env.params.url["chidx"].to_i? || 1
    index -= 1

    chinfo = ChInfo.load(bname, sname, snvid)
    unless curr_chap = chinfo.infos[index]?
      halt env, status_code: 404, response: "Chương tiết không tồn tại!"
    end

    chidx, infos = curr_chap

    RouteUtils.json_res(env) do |res|
      JSON.build(res) do |json|
        json.object do
          json.field "total", chinfo.infos.size
          json.field "chidx", chidx
          json.field "schid", infos[0]
          json.field "title", infos[1]
          json.field "label", infos[2]
          json.field "prev_url", chinfo.url_for(index - 1)
          json.field "next_url", chinfo.url_for(index + 1)
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

    chtext = ChText.load(bhash, sname, snvid, chidx - 1, schid)

    env.response.content_type = "text/plain; charset=utf-8"
    chtext.get_cv!(u_power, mode: mode)
  rescue err
    puts "- Error loading chap_text: #{err}"
    message = err.message || "Unknown error!"
    halt env, status_code: 500, response: message
  end
end
