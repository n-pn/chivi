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
    unless u_name = env.session.string?("u_dname").try(&.downcase)
      halt env, status_code: 403, response: "user not logged in"
    end

    bhash = env.params.url["bhash"]
    nvmark = env.params.query["nvmark"]? || ""

    if nvmark.empty?
      Marked.unmark_book(u_name, bhash)
    else
      Marked.mark_book(u_name, bhash, nvmark)
    end

    RouteUtils.json_res(env, {nvmark: nvmark})
  end

  get "/api/user-books/:u_dname" do |env|
    u_uname = env.params.url["u_dname"].downcase
    nvmark = env.params.query["nvmark"]? || "reading"
    matched = Marked.all_user_books(u_uname, nvmark)

    matched.each do |bhash|
      next if NvValues._index.has_key?(bhash)
      # puts bhash
      Marked.unmark_book(u_uname, bhash)
      matched.delete(bhash)
    end

    RouteUtils.books_res(env, matched)
  end
end
