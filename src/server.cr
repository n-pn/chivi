require "kemal"
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
  serve_static false

  before_all do |env|
    env.response.content_type = "application/json"
  end

  get "/" do |env|
    {msg: "ok"}.to_json env.response
  end

  get "/books" do |env|
    page = env.params.query.fetch("page", "1")
    limit, offset = parse_page(page)
    sort_by = env.params.query.fetch("sort_by", "tally")

    books = Kernel.list_books(limit: limit, offset: offset, sort_by: sort_by)

    {items: books, total: Kernel.book_size}.to_json env.response
  end

  get "/books/:slug" do |env|
    slug = env.params.url["slug"]
    entry = Kernel.find_book(slug)
    chaps = Kernel.list_chaps(slug)

    {entry: entry, chaps: chaps}.to_json env.response
  end

  get "/chaps/:book/:slug" do |env|
    book = env.params.url["book"]
    slug = env.params.url["slug"]
    zh_lines = Kernel.load_text(book, slug)
    if zh_lines
      vi_lines = Kernel::CHIVI.translate(zh_lines, mode: :mixed, book: nil)
    end
    {zh_lines: zh_lines, vi_lines: vi_lines}.to_json env.response
  end

  Kemal.run
end
