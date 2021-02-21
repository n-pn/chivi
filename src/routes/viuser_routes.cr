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

  get "/api/_self" do |env|
    u_dname = env.session.string("u_dname")
    u_power = env.session.int("u_power")

    RouteUtils.user_res(env, u_dname, u_power, cached: true)
  rescue err
    RouteUtils.user_res(env, "Khách", 0, cached: true)
  end

  get "/api/logout" do |env|
    env.session.destroy
    env.redirect("/")
  end

  post "/api/login" do |env|
    email = env.params.json.fetch("email", "").as(String).strip
    upass = env.params.json.fetch("upass", "").as(String).strip

    if uname = CV::Viuser.validate(email, upass)
      u_dname = Viuser._index.fval(uname).not_nil!
      u_power = Viuser.upower.ival(uname).not_nil!
      RouteUtils.user_res(env, u_dname, u_power, cached: false)
    else
      halt env, status_code: 403, response: "Thông tin đăng nhập không chính xác."
    end
  end

  post "/api/signup" do |env|
    dname = env.params.json.fetch("dname", "").as(String).strip
    email = env.params.json.fetch("email", "").as(String).strip
    upass = env.params.json.fetch("upass", "").as(String).strip

    raise "Địa chỉ hòm thư quá ngắn" if email.size < 3
    raise "Địa chỉ hòm thư không hợp lệ" if email !~ /@/
    raise "Tên người dùng quá ngắn (cần ít nhất 5 ký tự)" if dname.size < 5
    raise "Tên người dùng không hợp lệ" unless dname =~ /^[\p{L}\p{N}\s_]+$/
    raise "Mật khẩu quá ngắn (cần ít nhất 7 ký tự)" if upass.size < 7

    CV::Viuser.insert!(dname, email, upass)
    RouteUtils.user_res(env, dname, cached: false)
  rescue err
    halt env, status_code: 400, response: err.message
  end
end
