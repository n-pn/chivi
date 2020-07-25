require "./_utils"
require "../userdb"

module UserUtils
  extend self

  def return_user(env, user : UserInfo)
    cookie = HTTP::Cookie.new(name: "uslug", value: user.uslug, secure: true)
    env.response.cookies << cookie
    {status: "ok", uname: user.uname, power: user.power}.to_json(env.response)
  end
end

module Server
  post "/_signup" do |env|
    email = env.params.json["email"].as(String).strip
    uname = env.params.json["uname"].as(String).strip
    cpass = env.params.json["cpass"].as(String).strip

    raise "email too short" if email.size < 3
    raise "invalid email" if email !~ /@/
    raise "username too short" if uname.size < 5
    raise "password too short" if uname.size < 7

    user = UserDB.create(email, uname, cpass, "guest", 1)
    UserUtils.return_user(env, user)
  rescue err
    {status: "err", msg: err.message}.to_json(env.response)
  end

  post "/_login" do |env|
    email = env.params.json["email"].as(String).strip
    upass = env.params.json["upass"].as(String).strip

    user = UserDB.authenticate(email, upass)

    UserUtils.return_user(env, user)
  rescue err
    {status: "err", msg: "email or password incorrect"}.to_json(env.response)
  end

  get "/_self" do |env|
    uslug = env.get("uslug").as(String)
    user = UserInfo.get!(uslug)
    {status: "ok", uname: user.uname, power: user.power}.to_json(env.response)
  rescue err
    {status: "err", msg: "user not logged in"}.to_json(env.response)
  end

  get "/_logout" do |env|
    env.response.cookies.delete("uslug")
    env.redirect("/")
  end
end
