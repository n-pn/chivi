require "./_route_utils"

module CV::Server
  get "/api/chinfos/:bslug/:s_name/:cidx" do |env|
    bslug = env.params.url["bslug"]

    unless bhash = Nvinfo.find_by_slug(bslug)
      halt env, status_code: 404, response: "Quyển sách không tồn tại!"
    end

    s_name = env.params.url["s_name"]
    unless snvid = ChSource.load(s_name)._index.fval(bhash)
      halt env, status_code: 404, response: "Nguồn truyện không tồn tại!"
    end

    chinfo = Chinfo.load(s_name, snvid)

    index = env.params.url["cidx"].to_i? || 100000

    unless curr_chap = chinfo.chaps[index - 1]?
      halt env, status_code: 404, response: "Chương tiết không tồn tại!"
    end

    btitle = NvValues.btitle.get(bhash).not_nil!
    ch_title = curr_chap[1][0]
    ch_label = curr_chap[1][1]

    RouteUtils.json_res(env) do |res|
      {
        bhash:  bhash,
        bslug:  bslug,
        b_name: btitle[2]? || btitle[1],

        s_name: s_name,
        snvid:  snvid,
        s_size: chinfo.chaps.size,

        schid:  curr_chap[0],
        ch_idx: index,

        title: ch_title,
        label: ch_label,

        prev_url: chinfo.url_for(index - 2, bslug),
        next_url: chinfo.url_for(index, bslug),
      }.to_json(res)
    end
  rescue err
    puts "- Error loading chap_text: #{err}"
    message = err.message || "Unknown error!"
    halt env, status_code: 500, response: message
  end

  get "/api/chtexts/:s_name/:snvid/:schid" do |env|
    s_name = env.params.url["s_name"]
    snvid = env.params.url["snvid"]
    schid = env.params.url["schid"]

    u_power = env.session.int?("u_power") || 0
    mode = env.params.query["mode"]?.try(&.to_i?) || 0
    mode = u_power if mode > u_power

    chtext = Chtext.load(s_name, snvid, schid)
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
