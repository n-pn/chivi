require "./_routes"

module CV::Server
  get "/api/chaps/:ubid/:seed" do |env|
    ubid = env.params.url["ubid"]

    unless info = Oldcv::BookInfo.get(ubid)
      halt env, status_code: 404, response: "Book not found!"
    end

    seed = env.params.url["seed"]
    mode = env.params.query["mode"]?.try(&.to_i?) || 0

    unless fetched = Kernel.load_list(info, seed, mode: mode)
      halt env, status_code: 404, response: "Seed not found!"
    end

    chdata, mftime = fetched

    chaps = chdata.chaps
    chaps = chaps.reverse if env.params.query["order"]? == "desc"

    limit = env.params.query["limit"]?.try(&.to_i?) || 30
    limit = 30 if limit > 30

    offset = env.params.query["offset"]?.try(&.to_i?) || 0
    offset = 0 if offset < 0

    if offset >= chaps.size
      offset = (chaps.size // limit) * limit
    end

    chlist = chaps[offset, limit].map do |chap|
      {
        scid:  chap.scid,
        label: chap.vi_label,
        title: chap.vi_title,
        uslug: chap.url_slug,
      }
    end

    RouteUtils.json_res(env, {total: chdata.chaps.size, chaps: chlist, mftime: mftime}, cached: mftime)
  end
end
