require "./_route_utils"
require "../filedb/viuser"

module CV::Server
  module RouteUtils
    def self.user_res(env, u_dname : String, u_power : Int32? = nil, cached : Bool = false)
      u_power ||= Viuser.upower.ival(u_dname.downcase)

      unless cached
        env.session.string("u_dname", u_dname)
        env.session.int("u_power", u_power)
      end

      json_res(env, {dname: u_dname, power: u_power})
    end
  end

  get "/api/self" do |env|
    u_dname = env.session.string("u_dname")
    u_power = env.session.int("u_power")

    RouteUtils.user_res(env, u_dname, u_power, cached: true)
  rescue err
    halt env, status_code: 403, response: "user not logged in"
  end

  get "/api/logout" do |env|
    env.session.destroy
    env.redirect("/")
  end

  post "/api/login" do |env|
    email = env.params.json["email"]?.as(String?) || ""
    upass = env.params.json["upass"]?.as(String?) || ""

    if uname = CV::Viuser.validate(email.strip, upass.strip)
      u_dname = Viuser._index.fval(uname).not_nil!
      u_power = Viuser.upower.ival(uname).not_nil!
      RouteUtils.user_res(env, u_dname, u_power, cached: false)
    else
      halt env, status_code: 403, response: "email or password incorrect"
    end
  end

  post "/api/signup" do |env|
    dname = env.params.json["uname"]?.as(String?) || ""
    email = env.params.json["email"]?.as(String?) || ""
    upass = env.params.json["upass"]?.as(String?) || ""

    dname = dname.strip
    email = email.strip
    upass = upass.strip

    raise "email too short" if email.size < 3
    raise "invalid email format" if email !~ /@/
    raise "username too short" if dname.size < 5
    raise "invalid username format" unless dname =~ /^[\p{L}\p{N}\s_]+$/
    raise "password too short" if upass.size < 7

    CV::Viuser.insert!(dname, email, upass)
    RouteUtils.user_res(env, dname, cached: false)
  rescue err
    halt env, status_code: 400, response: err.message
  end
end
