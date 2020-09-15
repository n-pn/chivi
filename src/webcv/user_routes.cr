require "./route_utils"

module Server
  post "/_signup" do |env|
    email = env.params.json["email"].as(String).strip
    uname = env.params.json["uname"].as(String).strip
    upass = env.params.json["upass"].as(String).strip

    raise "email too short" if email.size < 3
    raise "invalid email format" if email !~ /@/
    raise "username too short" if uname.size < 5
    raise "invalid username format" unless uname =~ /^[\p{L}\p{N}\s_]+$/
    raise "password too short" if upass.size < 7

    user = UserDB.create(email, uname, upass, "guest", 1)
    Utils.return_user(env, user)
  rescue err
    {status: "err", msg: err.message}.to_json(env.response)
  end

  post "/_login" do |env|
    email = env.params.json["email"].as(String).strip
    upass = env.params.json["upass"].as(String).strip

    user = UserDB.authenticate(email, upass)
    Utils.return_user(env, user)
  rescue err
    puts err
    {status: "err", msg: "email or password incorrect"}.to_json(env.response)
  end

  get "/_logout" do |env|
    env.session.destroy
    env.redirect("/")
  end

  get "/_self" do |env|
    uslug = env.session.string("uslug")
    user = UserInfo.get!(uslug)
    {status: "ok", uname: user.uname, power: user.power}.to_json(env.response)
  rescue err
    {status: "err", msg: "user not logged in"}.to_json(env.response)
  end

  get "/_self/book_mark/:ubid" do |env|
    uslug = env.session.string("uslug")
    ubid = env.params.url["ubid"]

    mark = UserDB.get_book_mark(uslug, ubid) || ""
    {stt: "ok", mark: mark}
  rescue err
    {stt: "err", msg: "user not logged in"}.to_json(env.response)
  end

  put "/_self/book_mark/:ubid" do |env|
    uslug = env.session.string("uslug")
    ubid = env.params.url["ubid"]
    mark = env.params.query["mark"]? || ""

    if mark.empty?
      UserDB.unmark_book(uslug, ubid)
    else
      UserDB.mark_book(uslug, ubid, mark)
    end

    {s: "ok", mark: mark}
  rescue err
    {s: "err", m: "user not logged in"}.to_json(env.response)
  end

  get "/_users/:uname/marked_books" do |env|
    uname = env.params.url["uname"]
    unless user = UserDB.find_by_uname(uname)
      halt env, status_code: 404, response: Utils.json_error("user not found!")
    end

    mark = env.params.query["mark"]? || "reading"

    books = UserDB.marked_books(user.uslug)

    infos = books.compact_map do |ubid, marked|
      next unless mark == marked

      info = BookInfo.get!(ubid)

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
        mftime:     info.mftime,
      }
    rescue
      UserDB.unmark_book(user.uslug, ubid)
    end

    infos.sort_by(&.[:mftime].-).to_json(env.response)
  end
end
