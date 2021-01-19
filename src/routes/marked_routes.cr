require "./_route_utils"
require "../filedb/marked"

module CV::Server
  get "/api/book-marks/:b_hash" do |env|
    unless uname = env.session.string?("u_dname").try(&.downcase)
      halt env, status_code: 403, response: "user not logged in"
    end

    b_hash = env.params.url["b_hash"]
    bmark = Marked.book_users(b_hash).fval(uname) || ""
    RouteUtils.json_res(env, {bmark: bmark})
  end

  put "/api/book-marks/:b_hash" do |env|
    unless uname = env.session.string?("u_dname").try(&.downcase)
      halt env, status_code: 403, response: "user not logged in"
    end

    b_hash = env.params.url["b_hash"]
    bmark = env.params.query["bmark"]? || ""

    if bmark.empty?
      Marked.unmark_book(uname, b_hash)
    else
      Marked.mark_book(uname, b_hash, bmark)
    end

    RouteUtils.json_res(env, {bmark: bmark})
  end

  get "/api/user-books/:dname" do |env|
    uname = env.params.url["dname"].downcase
    bmark = env.params.query["bmark"]? || "reading"
    matched = Marked.all_user_books(uname, bmark)

    matched.each do |b_hash|
      next if NvValues._index.has_key?(b_hash)
      puts b_hash
      # Marked.unmark_book(uname, b_hash)
      # matched.delete(b_hash)
    end

    RouteUtils.books_res(env, matched)
  end
end
