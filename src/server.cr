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
    sort_by = env.params.query.fetch("sort_by", "tally")

    books = Kernel.serials.list(limit: limit, offset: offset, sort_by: sort_by)

    {items: books, total: Kernel.serials.total}.to_json env.response
  end

  get "/api/books/:slug" do |env|
    slug = env.params.url["slug"]
    book = Kernel.serials.get(slug)

    halt env, status_code: 404, response: ({msg: "Book not found"}).to_json if book.nil?

    site, bsid = book.crawl_links.first

    halt env, status_code: 404, response: ({msg: "Site [#{site}] not found"}).to_json if bsid.nil?

    chlist = Kernel.chlists.get(site, bsid)
    {book: book, site: site, chlist: chlist}.to_json env.response
  end

  get "/api/books/:slug/:site" do |env|
    slug = env.params.url["slug"]
    book = Kernel.serials.get(slug)

    halt env, status_code: 404, response: ({msg: "Book not found"}).to_json if book.nil?

    site = env.params.url["site"]
    bsid = book.crawl_links[site]?

    halt env, status_code: 404, response: ({msg: "Site [#{site}] not found"}).to_json if bsid.nil?

    chlist = Kernel.chlists.get(site, bsid)
    {book: book, site: site, chlist: chlist}.to_json env.response
  end

  get "/api/books/:slug/:site/:chap" do |env|
    slug = env.params.url["slug"]
    book = Kernel.serials.get(slug)

    halt env, status_code: 404, response: ({msg: "Book not found"}).to_json if book.nil?

    site = env.params.url["site"]
    bsid = book.crawl_links[site]?

    halt env, status_code: 404, response: ({msg: "Site not found"}).to_json if bsid.nil?

    list = Kernel.chlists.get(site, bsid)

    csid = env.params.url["chap"]
    cidx = list.index(&.csid.==(csid))

    halt env, status_code: 404, response: ({msg: "Chap not found"}) if cidx.nil?

    curr_chap = list[cidx]
    prev_chap = list[cidx - 1] if cidx > 0
    next_chap = list[cidx + 1] if cidx < list.size - 1

    {
      book_slug: book.vi_slug,
      book_name: book.vi_title,
      prev_slug: prev_chap.try(&.slug(site)),
      next_slug: next_chap.try(&.slug(site)),
      lines:     Kernel.load_text(site, bsid, csid),
    }.to_json env.response
  end

  Kemal.run
end
