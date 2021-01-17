require "./_route_utils"

module CV::Server
  get "/api/chinfos/:bslug/:seed/:scid" do |env|
    bslug = env.params.url["bslug"]

    unless info = Oldcv::BookDB.find(bslug)
      halt env, status_code: 404, response: "Quyển sách không tồn tại!"
    end

    Oldcv::BookDB.bump_access(info, Time.utc.to_unix_ms)
    # BookDB.inc_counter(info, read: true)

    seed = env.params.url["seed"]
    unless fetched = Kernel.load_chlist(info, seed, mode: 0)
      halt env, status_code: 404, response: "Nguồn truyện không tồn tại!"
    end

    scid = env.params.url["scid"]
    list, _ = fetched

    unless index = list.index[scid]?
      halt env, status_code: 404, response: "Chương tiết không tồn tại!"
    end

    curr_chap = list.chaps[index]
    prev_chap = list.chaps[index - 1] if index > 0
    next_chap = list.chaps[index + 1] if index < list.size - 1

    RouteUtils.json_res(env) do |res|
      {
        bhash: info.ubid,
        bslug: info.slug,
        bname: info.vi_title,

        seed: seed,
        sbid: info.seed_sbids[seed],
        scid: scid,

        title: curr_chap.vi_title,
        label: curr_chap.vi_label,

        ch_index: index + 1,
        ch_total: list.size,

        prev_url: prev_chap.try(&.slug_for(seed)),
        next_url: next_chap.try(&.slug_for(seed)),
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

    power = env.session.int?("power") || 0
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
