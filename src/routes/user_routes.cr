require "./_utils"
require "../userdb"

module UserUtils
  extend self

  def return_user(env, user : UserInfo)
    env.session.string("uslug", user.uslug)
    {status: "ok", uname: user.uname, power: user.power}.to_json(env.response)
  end
end

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
    puts err
    {status: "err", msg: "email or password incorrect"}.to_json(env.response)
  end

  get "/_self" do |env|
    uslug = env.session.string("uslug")
    user = UserInfo.get!(uslug)
    {status: "ok", uname: user.uname, power: user.power}.to_json(env.response)
  rescue err
    {status: "err", msg: "user not logged in"}.to_json(env.response)
  end

  get "/_logout" do |env|
    env.session.destroy
    env.redirect("/")
  end
end
