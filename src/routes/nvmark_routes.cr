require "./_routes"
require "../filedb/nvmark"

module CV::Server
  get "/api/self/book_mark/:ubid" do |env|
    uslug = env.session.string("uslug")
    ubid = env.params.url["ubid"]

    mark = Oldcv::UserDB.get_book_mark(uslug, ubid) || ""
    RouteUtils.json_res(env) { |res| {_stt: "ok", mark: mark}.to_json(res) }
  rescue err
    RouteUtils.json_res(env) { |res| {_stt: "err", _msg: "User not logged in"}.to_json(res) }
  end

  put "/api/self/book_mark/:ubid" do |env|
    uslug = env.session.string("uslug")
    ubid = env.params.url["ubid"]
    mark = env.params.query["mark"]? || ""

    if mark.empty?
      Oldcv::UserDB.unmark_book(uslug, ubid)
    else
      Oldcv::UserDB.mark_book(uslug, ubid, mark)
    end

    RouteUtils.json_res(env) { |res| {_stt: "ok", mark: mark}.to_json(res) }
  rescue err
    RouteUtils.json_res(env) { |res| {_stt: "err", _msg: "User not logged in"}.to_json(res) }
  end

  get "/api/users/:uname/marked_books" do |env|
    uname = env.params.url["uname"]
    unless user = Oldcv::UserDB.find_by_uname(uname)
      halt env, status_code: 404, response: "user not found!"
    end

    mark = env.params.query["mark"]? || "reading"
    limit, offset = RouteUtils.parse_page(env.params.query.fetch("page", "1"))

    uuids = Oldcv::UserDB.marked_books(user.uslug, mark)
    infos = uuids.compact_map do |ubid|
      Oldcv::BookInfo.get!(ubid)
    rescue
      Oldcv::UserDB.unmark_book(user.uslug, ubid)
    end

    infos = infos.sort_by(&.mftime.-)[offset, limit]
    RouteUtils.json_res(env) { |res| RouteUtils.books_json(res, infos, uuids.size) }
  end
end
