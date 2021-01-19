require "./_route_utils"

module CV::Server
  get "/api/chinfos/:bslug/:seed/:cidx" do |env|
    bslug = env.params.url["bslug"]

    unless bhash = Nvinfo.find_by_slug(bslug)
      halt env, status_code: 404, response: "Quyển sách không tồn tại!"
    end

    seed = env.params.url["seed"]
    unless sbid = ChMeta.load(seed)._index.fval(bhash)
      halt env, status_code: 404, response: "Nguồn truyện không tồn tại!"
    end

    chinfo = Chinfo.load(seed, sbid)

    index = env.params.url["cidx"].to_i? || 100000

    unless curr_chap = chinfo.chaps[index - 1]?
      halt env, status_code: 404, response: "Chương tiết không tồn tại!"
    end

    btitle = NvFields.btitle.get(bhash).not_nil!
    ch_title = curr_chap[1][0]
    ch_label = curr_chap[1][1]

    RouteUtils.json_res(env) do |res|
      {
        bhash: bhash,
        bslug: bslug,
        bname: btitle[2]? || btitle[1],

        seed: seed,
        sbid: sbid,
        scid: curr_chap[0],

        title: ch_title,
        label: ch_label,

        ch_index: index,
        ch_total: chinfo.chaps.size,

        prev_url: chinfo.url_for(index - 2, bslug),
        next_url: chinfo.url_for(index, bslug),
      }.to_json(res)
    end
  rescue err
    puts "- Error loading chap_text: #{err}"
    message = err.message || "Unknown error!"
    halt env, status_code: 500, response: message
  end

  get "/api/chtexts/:seed/:sbid/:scid" do |env|
    seed = env.params.url["seed"]
    sbid = env.params.url["sbid"]
    scid = env.params.url["scid"]

    power = env.session.int?("u_power") || 0
    mode = env.params.query["mode"]?.try(&.to_i?) || 0
    mode = power if mode > power

    chtext = Chtext.load(seed, sbid, scid)
    chtext.fetch!(power) if mode > 1 || chtext.zh_lines.empty?

    unless mode == 0 && chtext.cv_mtime > (Time.utc - 3.hours)
      dname = env.params.query["dict"]? || "various"
      chtext.trans!(dname)
    end

    RouteUtils.json_res(env) do |res|
      {cvdata: chtext.cv_trans, mftime: chtext.cv_mtime.to_unix}.to_json(res)
    end
  rescue err
    puts "- Error loading chap_text: #{err}"
    message = err.message || "Unknown error!"
    halt env, status_code: 500, response: message
  end
end
