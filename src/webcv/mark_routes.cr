require "./_route_utils"
require "../appcv/vi_mark"

module CV::Server
  get "/api/:uname/books" do |env|
    uname = env.params.url["uname"].downcase
    bmark = env.params.query["bmark"]? || "reading"
    matched = ViMark.all_books(uname, bmark)
    RouteUtils.books_res(env, matched)
  end

  get "/api/marks/:bname" do |env|
    if uname = env.session.string?("u_dname").try(&.downcase)
      bname = env.params.url["bname"]
      bmark = ViMark.book_map(uname).fval(bname) || ""
    end

    RouteUtils.json_res(env, {bmark: bmark || ""})
  end

  put "/api/marks/:bname" do |env|
    unless uname = env.session.string?("u_dname").try(&.downcase)
      halt env, status_code: 403, response: "user not logged in"
    end

    bname = env.params.url["bname"]
    bmark = env.params.json["bmark"]?.as(String?) || ""
    ViMark.mark_book(uname, bname, bmark)

    RouteUtils.json_res(env, {bmark: bmark})
  end
end
