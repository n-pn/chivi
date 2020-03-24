require "kemal"
require "./kernel"

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
    limit, offset = Kernel.parse_page(page)
    sort_by = env.params.query.fetch("sort_by", "tally")

    books = Kernel.list_books(limit: limit, offset: offset, sort_by: sort_by)

    {msg: "ok", data: books}.to_json env.response
  end

  Kemal.run
end
