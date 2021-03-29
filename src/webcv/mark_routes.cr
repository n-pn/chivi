require "./_route_utils"
require "../appcv/vi_mark"

module CV::Server
  get "/api/_self/nvmarks/:bhash" do |env|
    if uname = env.session.string?("u_dname").try(&.downcase)
      bhash = env.params.url["bhash"]
      bmark = ViMark.user_books(uname).fval(bhash) || ""
    end

    RouteUtils.json_res(env, {nvmark: bmark || ""})
  end

  put "/api/book-marks/:bhash" do |env|
    unless u_name = env.session.string?("u_dname").try(&.downcase)
      halt env, status_code: 403, response: "user not logged in"
    end

    bhash = env.params.url["bhash"]
    nvmark = env.params.query["nvmark"]? || ""

    if nvmark.empty?
      ViMark.unmark_book(u_name, bhash)
    else
      ViMark.mark_book(u_name, bhash, nvmark)
    end

    RouteUtils.json_res(env, {nvmark: nvmark})
  end

  get "/api/user-books/:u_dname" do |env|
    u_uname = env.params.url["u_dname"].downcase
    nvmark = env.params.query["nvmark"]? || "reading"
    matched = ViMark.all_user_books(u_uname, nvmark)

    # remove deleted books
    matched.each do |bhash|
      next if NvInfo.exists?(bhash)
      ViMark.unmark_book(u_uname, bhash)
      matched.delete(bhash)
    end

    RouteUtils.books_res(env, matched)
  end
end
