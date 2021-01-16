require "./_route_utils"
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

  get "/api/user-books/:dname" do |env|
    skip = RouteUtils.parse_int(env.params.query["skip"]?, min: 0)
    take = RouteUtils.parse_int(env.params.query["take"]?, min: 1, max: 24)

    uname = env.params.url["dname"].downcase
    bmark = env.params.query["bmark"]? || "reading"
    matched = Nvmark.all_user_books(uname, bmark)

    books = [] of Nvinfo::BasicInfo
    Nvinfo.each(skip: skip, take: take, matched: matched) do |bhash|
      books << Nvinfo.get_cached_basic_info(bhash)
    rescue
      Nvmark.unmark_book(uname, bhash)
    end

    RouteUtils.json_res(env, {books: books, total: matched.size})
  end
end
