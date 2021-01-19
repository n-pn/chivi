require "./_route_utils"
require "../filedb/marked"

module CV::Server
  get "/api/book-marks/:bhash" do |env|
    unless uname = env.session.string?("u_dname").try(&.downcase)
      halt env, status_code: 403, response: "user not logged in"
    end

    bhash = env.params.url["bhash"]
    bmark = Marked.book_users(bhash).fval(uname) || ""
    RouteUtils.json_res(env, {bmark: bmark})
  end

  put "/api/book-marks/:bhash" do |env|
    unless uname = env.session.string?("u_dname").try(&.downcase)
      halt env, status_code: 403, response: "user not logged in"
    end

    bhash = env.params.url["bhash"]
    bmark = env.params.query["bmark"]? || ""

    if bmark.empty?
      Marked.unmark_book(uname, bhash)
    else
      Marked.mark_book(uname, bhash, bmark)
    end

    RouteUtils.json_res(env, {bmark: bmark})
  end

  get "/api/user-books/:dname" do |env|
    uname = env.params.url["dname"].downcase
    bmark = env.params.query["bmark"]? || "reading"
    matched = Marked.all_user_books(uname, bmark)

    matched.each do |bhash|
      next if NvFields._index.has_key?(bhash)
      puts bhash
      # Marked.unmark_book(uname, bhash)
      # matched.delete(bhash)
    end

    RouteUtils.books_res(env, matched)
  end
end
