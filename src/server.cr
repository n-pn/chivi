require "kemal"

require "./engine"
require "./kernel"

def parse_page(input, limit = 20)
  page = parse_int(input)

  offset = (page - 1) * limit
  offset = 0 if offset < 0

  {limit, offset}
end

def parse_int(str)
  str.to_i
rescue
  0
end

def json_error(msg : String)
  {msg: msg}.to_json
end

module Server
  Kemal.config.port = 5110

  serve_static false

  before_all do |env|
    case Kemal.config.env
    when "development"
      user = "local"
    when "test"
      user = "test"
    else
      user = "guest"
    end

    env.set("user", user)
    env.response.content_type = "application/json"
  end

  get "/api" do |env|
    {msg: "ok"}.to_json env.response
  end

  post "/api/convert" do |env|
    user = env.get("user").as(String)

    type = env.params.query["type"].as(String)
    text = env.params.json["text"].as(String)

    lines = Utils.split_lines(text)
    case type
    when "hanviet"
      res = lines.map { |line| Engine.hanviet(line, user, apply_cap: true) }
    when "pinyins"
      res = lines.map { |line| Engine.pinyins(line, user, apply_cap: true) }
    when "tradsim"
      res = lines.map { |line| Engine.tradsim(line, user) }
    else
      dict = env.params.json.fetch("dict", "tong-hop").as(String)
      res = Engine.convert(lines, dict, user, mode: :plain)
    end

    res.to_json(env.response)
  end

  get "/api/lookup" do |env|
    user = env.get("user").as(String)

    line = env.params.query.fetch("line", "")
    dict = env.params.query.fetch("dict", "tong-hop")

    Engine.lookup(line, dict, user).to_json(env.response)
  end

  get "/api/inquire" do |env|
    user = env.get("user").as(String)

    word = env.params.query["word"]? || ""
    dict = env.params.query["dict"]? || "tong-hop"

    res = Engine.inquire(word, dict, user)
    res.to_json(env.response)
  end

  get "/api/upsert" do |env|
    key = env.params.query["key"]? || ""
    val = env.params.query["val"]? || ""

    dict = env.params.query["dict"]? || "tong-hop"
    user = env.get("user").as(String)

    res = Engine.upsert(key, val, dict, user)
    res.to_json(env.response)
  end

  get "/api/hanviet" do |env|
    txt = env.params.query.fetch("txt", "")
    res = Engine.hanviet(txt)
    res.to_json env.response
  end

  get "/api/books" do |env|
    sort = env.params.query.fetch("sort", "access")
    page = env.params.query.fetch("page", "1")
    limit, offset = parse_page(page)

    books = BookRepo.index(limit: limit, offset: offset, sort: sort)
    items = books.map do |info|
      {
        uuid:     info.uuid,
        slug:     info.slug,
        vi_title: info.vi_title,
        vi_genre: info.vi_genre,
        score:    info.score,
        votes:    info.votes,
      }
    end

    {items: items, total: BookRepo.sort_by(sort).size, sort: sort}.to_json env.response
  end

  get "/api/search" do |env|
    query = env.params.query.fetch("word", "")
    page = env.params.query.fetch("page", "1")
    limit, offset = parse_page(page, limit: 8)

    uuids = BookRepo.glob(query)

    items = uuids[offset, limit].compact_map do |uuid|
      next unless info = BookRepo.load(uuid)

      {
        uuid:      info.uuid,
        slug:      info.slug,
        vi_title:  info.vi_title,
        zh_title:  info.zh_title,
        vi_author: info.vi_author,
        zh_author: info.zh_author,
        vi_genre:  info.vi_genre,
        score:     info.score,
        votes:     info.votes,
      }
    end

    {
      total: uuids.size,
      items: items,
      page:  page,
    }.to_json env.response
  end

  get "/api/books/:slug" do |env|
    slug = env.params.url["slug"]

    unless book = BookRepo.find(slug)
      halt env, status_code: 404, response: json_error("Book not found!")
    end

    BookRepo.update_sort("access", book)
    {book: book}.to_json env.response
  end

  get "/api/books/:slug/:site" do |env|
    user = env.get("user").as(String)
    slug = env.params.url["slug"]

    unless info = BookRepo.find(slug)
      halt env, status_code: 404, response: json_error("Book not found!")
    end

    site = env.params.url["site"]
    unless bsid = info.cr_anchors[site]?
      halt env, status_code: 404, response: json_error("Site [#{site}] not found")
    end

    reload = env.params.query.fetch("reload", "false") == "true"
    chlist, mftime = Kernel.load_list(info, site, user, reload: reload)

    chlist = chlist.map do |chap|
      {
        csid:      chap.csid,
        vi_title:  chap.vi_title,
        vi_volume: chap.vi_volume,
        url_slug:  chap.slug_for(site),
      }
    end

    {chlist: chlist, mftime: mftime}.to_json env.response
  end

  get "/api/books/:slug/:site/:csid" do |env|
    user = env.get("user").as(String)

    slug = env.params.url["slug"]

    unless info = BookRepo.find(slug)
      halt env, status_code: 404, response: ({msg: "Book not found"}).to_json
    end

    site = env.params.url["site"]
    unless bsid = info.cr_anchors[site]?
      halt env, status_code: 404, response: ({msg: "Site [#{site}] not found"}).to_json
    end

    csid = env.params.url["csid"]

    chlist, _ = Kernel.load_list(info, site, reload: false)
    unless ch_index = chlist.index(&.csid.==(csid))
      halt env, status_code: 404, response: ({msg: "Chap not found"}).to_json
    end

    curr_chap = chlist[ch_index]
    prev_chap = chlist[ch_index - 1] if ch_index > 0
    next_chap = chlist[ch_index + 1] if ch_index < chlist.size - 1

    mode = env.params.query.fetch("mode", "0").try(&.to_i) || 0

    {
      book_uuid: info.uuid,
      book_slug: info.slug,
      book_name: info.vi_title,
      ch_index:  ch_index + 1,
      ch_total:  chlist.size,
      prev_url:  prev_chap.try(&.slug_for(site)),
      next_url:  next_chap.try(&.slug_for(site)),
      curr_url:  curr_chap.try(&.slug_for(site)),

      content: Kernel.load_chap(info, site, csid, user, mode: mode),
    }.to_json env.response
  end

  Kemal.run
end
