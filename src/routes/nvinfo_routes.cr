require "./_routes"

module CV::Server
  get "/api/books" do |env|
    word = env.params.query.fetch("word", "")
    type = RouteUtils.search_type(env.params.query["type"]?)

    genre = env.params.query.fetch("genre", "")

    order = RouteUtils.search_order(env.params.query["order"]?)
    anchor = env.params.query.fetch("anchor", "")

    page = RouteUtils.search_page(env.params.query["page"]?)
    limit = RouteUtils.search_limit(env.params.query["limit"]?)
    offset = (page - 1) * limit

    opts = Oldcv::BookDB::Query::Opts.new(word, type, genre, order, limit, offset, anchor)

    infos, total = Oldcv::BookDB::Query.fetch!(opts)

    items = infos.map do |info|
      {
        ubid:       info.ubid,
        slug:       info.slug,
        vi_title:   info.vi_title,
        zh_title:   info.zh_title,
        vi_author:  info.vi_author,
        vi_genres:  info.vi_genres,
        main_cover: info.main_cover,
        rating:     info.rating,
        voters:     info.voters,
      }
    end

    RouteUtils.json_res(env, {items: items, total: total, query: opts})
  end

  get "/api/books/:slug" do |env|
    slug = env.params.url["slug"]

    unless info = Oldcv::BookDB.find(slug)
      halt env, status_code: 404, response: "Book not found!"
    end

    Oldcv::BookDB.bump_access(info)
    # BookDB.inc_counter(info, read: false)

    if uslug = env.session.string?("uslug")
      mark = Oldcv::UserDB.get_book_mark(uslug, info.ubid) || ""
    else
      mark = ""
    end

    RouteUtils.json_res(env, {book: info, mark: mark}, cached: info.mftime)
  end
end
