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
  Kemal.config.port = 4000

  serve_static false

  before_all do |env|
    env.response.content_type = "application/json"
  end

  get "/api" do |env|
    {msg: "ok"}.to_json env.response
  end

  get "/api/books" do |env|
    page = env.params.query.fetch("page", "1")
    limit, offset = parse_page(page)
    sort_by = env.params.query.fetch("sort_by", "updated_at")

    books = Kernel.serials(preload: true).list(limit: limit, offset: offset, sort_by: sort_by)

    {items: books, total: Kernel.serials.total}.to_json env.response
  end

  get "/api/books/:slug" do |env|
    book = Kernel.serials.get(env.params.url["slug"])
    halt env, status_code: 404, response: "Book not found" if book.nil?

    site = book.favor_crawl
    if site.empty?
      list = [] of VpChap
    else
      bsid = book.crawl_links[site]
      list = Kernel.chlists(site, bsid)
    end

    {entry: book, chaps: list}.to_json env.response
  end

  get "/api/chaps/:book/:chap" do |env|
    book = Kernel.serials.get(env.params.url["book"])
    halt env, status_code: 404, response: "Book not found" if book.nil?

    site = book.favor_crawl
    halt env, status_code: 404, response: "Text not found" if site.empty?

    bsid = book.crawl_links[site]
    list = Kernel.chlists(site, bsid)

    csid = env.params.url["chap"]
    cidx = list.index(&.csid.==(csid))

    halt env, status_code: 404, response: "Text not found" if cidx.nil?

    curr_chap = list[cidx]
    prev_chap = list[cidx - 1] if cidx > 0
    next_chap = list[cidx + 1] if cidx < list.size - 1

    {
      data: Kernel.load_text(site, bsid, csid),
      prev: prev_chap,
      next: next_chap,
      book: book,
    }.to_json env.response
  end

  Kemal.run
end
