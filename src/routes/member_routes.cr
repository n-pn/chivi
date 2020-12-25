require "./_routes"

module Chivi::Server
  post "/api/signup" do |env|
    email = env.params.json["email"]?.as(String?) || ""
    uname = env.params.json["uname"]?.as(String?) || ""
    upass = env.params.json["upass"]?.as(String?) || ""

    email = email.strip
    uname = uname.strip
    upass = upass.strip

    raise "email too short" if email.size < 3
    raise "invalid email format" if email !~ /@/
    raise "username too short" if uname.size < 5
    raise "invalid username format" unless uname =~ /^[\p{L}\p{N}\s_]+$/
    raise "password too short" if upass.size < 7

    user = Oldcv::UserDB.create(email, uname, upass, "guest", 1)
    Utils.return_user(env, user)
  rescue err
    Utils.json(env) { |res| {_stt: "err", _msg: err.message}.to_json(res) }
  end

  post "/api/login" do |env|
    email = env.params.json["email"]?.as(String?) || ""
    upass = env.params.json["upass"]?.as(String?) || ""

    user = Oldcv::UserDB.authenticate(email.strip, upass.strip)
    Utils.return_user(env, user)
  rescue err
    Utils.json(env) do |res|
      {_stt: "err", _msg: "email or password incorrect"}.to_json(res)
    end
  end

  get "/api/logout" do |env|
    env.session.destroy
    env.redirect("/")
  end

  get "/api/self" do |env|
    uslug = env.session.string("uslug")
    user = Oldcv::UserInfo.get!(uslug)
    Utils.json(env) do |res|
      {_stt: "ok", uname: user.uname, power: user.power}.to_json(res)
    end
  rescue err
    Utils.json(env) do |res|
      {_stt: "err", _msg: "user not logged in"}.to_json(env.response)
    end
  end

  get "/api/self/book_mark/:ubid" do |env|
    uslug = env.session.string("uslug")
    ubid = env.params.url["ubid"]

    mark = Oldcv::UserDB.get_book_mark(uslug, ubid) || ""
    Utils.json(env) { |res| {_stt: "ok", mark: mark}.to_json(res) }
  rescue err
    Utils.json(env) { |res| {_stt: "err", _msg: "User not logged in"}.to_json(res) }
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

    Utils.json(env) { |res| {_stt: "ok", mark: mark}.to_json(res) }
  rescue err
    Utils.json(env) { |res| {_stt: "err", _msg: "User not logged in"}.to_json(res) }
  end

  get "/api/users/:uname/marked_books" do |env|
    uname = env.params.url["uname"]
    unless user = Oldcv::UserDB.find_by_uname(uname)
      halt env, status_code: 404, response: "user not found!"
    end

    mark = env.params.query["mark"]? || "reading"
    limit, offset = Utils.parse_page(env.params.query.fetch("page", "1"))

    uuids = Oldcv::UserDB.marked_books(user.uslug, mark)
    infos = uuids.compact_map do |ubid|
      Oldcv::BookInfo.get!(ubid)
    rescue
      Oldcv::UserDB.unmark_book(user.uslug, ubid)
    end

    infos = infos.sort_by(&.mftime.-)[offset, limit]
    Utils.json(env) { |res| Utils.books_json(res, infos, uuids.size) }
  end
end
