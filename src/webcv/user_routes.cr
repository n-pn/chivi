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

  put "/_self/tag_book" do |env|
    uslug = env.session.string("uslug")
    ubid = env.params.query["ubid"]

    old_tag = env.params.query["old_tag"]? || ""
    new_tag = env.params.query["new_tag"]? || ""

    if old_tag.empty?
      UserDB.add_book_tag(uslug, ubid, new_tag)
    elsif new_tag.empty?
      UserDB.remove_book_tag(uslug, ubid, old_tag)
    else
      UserDB.update_book_tag(uslug, ubid, old_tag, new_tag)
    end
  rescue err
    {status: "err", msg: "user not logged in"}.to_json(env.response)
  end

  get "/_self/list_books" do |env|
    uslug = env.session.string("uslug")
    tag = env.params.query["tag"]? || "liked"

    ubids = UserDB.list_books(uslug, tag) || Set(String).new
    infos = ubids.map do |ubid|
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
      }
    end

    infos.to_json(env.response)
  end
end
