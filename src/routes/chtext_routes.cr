require "./_routes"

module CV::Server
  get "/api/texts/:slug/:seed/:scid" do |env|
    slug = env.params.url["slug"]

    unless info = Oldcv::BookDB.find(slug)
      halt env, status_code: 404, response: "Quyển sách không tồn tại!"
    end

    Oldcv::BookDB.bump_access(info, Time.utc.to_unix_ms)
    # BookDB.inc_counter(info, read: true)

    seed = env.params.url["seed"]
    unless fetched = Kernel.load_list(info, seed, mode: 0)
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

    mode = env.params.query.fetch("mode", "0").try(&.to_i?) || 0
    chap = Kernel.get_text(info.ubid, seed, list.sbid, scid, mode: mode)

    RouteUtils.json_res(env) do |res|
      {
        cvdata: chap.cv_text,
        mftime: chap.cv_time,

        bslug: info.slug,
        bname: info.vi_title,

        ubid: info.ubid,
        seed: seed,
        scid: curr_chap.scid,

        ch_title: curr_chap.vi_title,
        ch_label: curr_chap.vi_label,
        ch_index: index + 1,
        ch_total: list.size,

        curr_url: curr_chap.try(&.slug_for(seed)),
        prev_url: prev_chap.try(&.slug_for(seed)),
        next_url: next_chap.try(&.slug_for(seed)),

      }.to_json(res)
    end
  rescue err
    puts "- Error loading chap_text: #{err}"
    message = err.message || "Unknown error!"
    halt env, status_code: 500, response: message
  end
end
