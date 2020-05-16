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

module Server
  Kemal.config.port = 5110

  serve_static false

  before_all do |env|
    env.response.content_type = "application/json"
    if Kemal.config.env == "production"
      user = "guest"
    else
      user = "local"
    end

    env.set("user", user)
  end

  get "/api" do |env|
    {msg: "ok"}.to_json env.response
  end

  get "/api/lookup" do |env|
    line = env.params.query.fetch("line", "")
    udic = env.params.query["udic"]?
    user = env.get("user").as(String)

    res = Engine.lookup(line, udic, user)
    res.to_json(env.response)
  end

  get "/api/inquire" do |env|
    key = env.params.query["key"]? || ""
    dic = env.params.query["dic"]?
    user = env.get("user").as(String)
    res = Engine.inquire(key, dic, user)
    res.to_json(env.response)
  end

  get "/api/upsert" do |env|
    key = env.params.query["key"]? || ""
    val = env.params.query["val"]? || ""
    dic = env.params.query["dic"]?
    user = env.get("user").as(String)
    res = Engine.upsert(key, val, dic, user)
    res.to_json(env.response)
  end

  get "/api/hanviet" do |env|
    txt = env.params.query.fetch("txt", "")
    res = Engine.hanviet(txt)
    res.to_json env.response
  end

  get "/api/books" do |env|
    page = env.params.query.fetch("page", "1")
    limit, offset = parse_page(page)
    sort = env.params.query.fetch("sort", "access")

    books = BookRepo.index(limit: limit, offset: offset, sort: sort)

    items = books.map do |info|
      {
        uuid:     info.uuid,
        slug:     info.slug,
        vi_title: info.vi_title,
        vi_genre: info.vi_genre,
        score:    info.score,
      }
    end

    {items: items, total: BookRepo.sort_by(sort).size, sort: sort}.to_json env.response
  end

  get "/api/search" do |env|
    query = env.params.query.fetch("kw", "")
    page = env.params.query.fetch("pg", "1")
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

    unless info = BookRepo.find(slug)
      halt env, status_code: 404, response: ({msg: "Book not found"}).to_json
    end

    BookRepo.update_sort("access", info)
    {book: info}.to_json env.response
  end

  get "/api/books/:slug/:site" do |env|
    slug = env.params.url["slug"]

    unless info = BookRepo.find(slug)
      halt env, status_code: 404, response: ({msg: "Book not found"}).to_json
    end

    site = env.params.url["site"]
    unless bsid = info.cr_anchors[site]?
      halt env, status_code: 404, response: ({msg: "Site [#{site}] not found"}).to_json
    end

    refresh = env.params.query.fetch("refresh", "false") == "true"

    list = Kernel.load_list(info, site, refresh: refresh)

    list = list.map do |chap|
      {
        csid:      chap.csid,
        vi_title:  chap.vi_title,
        vi_volume: chap.vi_volume,
        url_slug:  chap.slug_for(site),
      }
    end

    {site: site, bsid: bsid, list: list}.to_json env.response
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

    list = Kernel.load_list(info, site, refresh: false)
    unless cidx = list.index(&.csid.==(csid))
      halt env, status_code: 404, response: ({msg: "Chap not found"}).to_json
    end

    curr_chap = list[cidx]
    prev_chap = list[cidx - 1] if cidx > 0
    next_chap = list[cidx + 1] if cidx < list.size - 1

    mode = env.params.query.fetch("mode", "0").to_i

    {
      book_slug: info.slug,
      book_name: info.vi_title,
      prev_slug: prev_chap.try(&.slug_for(site)),
      next_slug: next_chap.try(&.slug_for(site)),
      curr_slug: curr_chap.try(&.slug_for(site)),
      lines:     Kernel.load_chap(info, site, csid, user, mode: mode),
      chidx:     cidx + 1,
      total:     list.size,
    }.to_json env.response
  end

  Kemal.run
end
