require "./_route_utils"

require "../appcv/nv_info"
require "../appcv/ch_info"
require "../appcv/ch_text"

module CV::Server
  get "/api/texts/:bname/:sname/:snvid/:chidx" do |env|
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

  get "/api/texts/:bname/:sname/:snvid/:chidx/:schid" do |env|
    bname = env.params.url["bname"]
    sname = env.params.url["sname"]
    snvid = env.params.url["snvid"]

    chidx = env.params.url["chidx"].to_i
    schid = env.params.url["schid"]

    u_power = env.session.int?("u_power") || 0
    mode = env.params.query["mode"]?.try(&.to_i?) || 0
    mode = u_power if mode > u_power

    chtext = ChText.load(bname, sname, snvid, chidx - 1, schid)

    env.response.content_type = "text/plain; charset=utf-8"
    chtext.get_cv!(u_power, mode: mode)
  rescue err
    puts "- Error loading chap_text: #{err}"
    message = err.message || "Unknown error!"
    halt env, status_code: 500, response: message
  end

  put "/api/texts/:bname/:sname/:snvid" do |env|
    u_power = env.session.int?("u_power") || 0
    halt env, status_code: 500, response: "Access denied!" if u_power < 2

    bname = env.params.url["bname"]
    sname = env.params.url["sname"]
    snvid = env.params.url["snvid"]

    chidx = env.params.json["chidx"].as(Int64).to_i

    label = env.params.json["label"].as(String?) || ""
    label = "" if label == "正文"

    input = env.params.json["input"].as(String)
    lines = TextUtils.split_text(input)

    chinfo = ChInfo.load(bname, sname, snvid)

    chmax = chinfo.origs.size + 1
    chidx = chmax if chidx < 1 || chidx > chmax

    # schid = chinfo.origs.fval(chidx.to_s) || chidx.to_s.rjust(4, '0')

    schid = chidx.to_s.rjust(4, '0')
    chinfo.set!(chidx.to_s, schid, lines[0], label)
    NvInfo.load(bname).set_chseed("chivi", bname, Time.utc.to_unix, chinfo.origs.size)

    chtext = ChText.load(bname, sname, snvid, chidx - 1, schid)
    chtext.set_zh!(lines)

    index, infos = chinfo.infos[chidx - 1]
    RouteUtils.json_res(env, {chidx: index, uslug: infos[3]})
  rescue err
    puts "- Error loading chap_text: #{err}"
    message = err.message || "Unknown error!"
    halt env, status_code: 500, response: message
  end
end
