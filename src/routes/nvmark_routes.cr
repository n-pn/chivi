require "./_routes"
require "../filedb/nvmark"

module CV::Server
  get "/api/book-marks/:bhash" do |env|
    unless uname = env.session.string?("dname").try(&.downcase)
      halt env, status_code: 403, response: "user not logged in"
    end

    bhash = env.params.url["bhash"]
    bmark = Nvmark.book_users(bhash).fval(uname) || ""
    RouteUtils.json_res(env, {bmark: bmark})
  end

  put "/api/book-marks/:bhash" do |env|
    unless uname = env.session.string?("dname").try(&.downcase)
      halt env, status_code: 403, response: "user not logged in"
    end

    bhash = env.params.url["bhash"]
    bmark = env.params.query["bmark"]? || ""

    if bmark.empty?
      Nvmark.unmark_book(uname, bhash)
    else
      Nvmark.mark_book(uname, bhash, bmark)
    end

    RouteUtils.json_res(env, {bmark: bmark})
  end

  get "/api/user-books/:uname" do |env|
    uname = env.params.url["uname"]
    unless user = Oldcv::UserDB.find_by_uname(uname)
      halt env, status_code: 404, response: "user not found!"
    end

    bmark = env.params.query["bmark"]? || "reading"
    books = Nvmark.all_user_books(uname, bmark)

    infos = books.compact_map do |bhash|
      Oldcv::BookInfo.get!(bhash)
    rescue
      Nvmark.unmark_book(uname, bhash)
    end

    limit, offset = RouteUtils.parse_page(env.params.query.fetch("page", "1"))
    infos = infos.sort_by(&.mftime.-)[offset, limit]

    RouteUtils.json_res(env) { |res| RouteUtils.books_json(res, infos, books.size) }
  end
end
