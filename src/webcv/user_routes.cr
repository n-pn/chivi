require "./_route_utils"

module CV::Server
  module RouteUtils
    def self.user_res(env, uname : String, cached : Bool = false)
      env.session.string("uname", uname) unless cached

      power = ViUser.get_power(uname)
      json_res(env, {dname: uname, power: power})
    end
  end

  get "/api/_self" do |env|
    if uname = env.session.string?("uname")
      RouteUtils.user_res(env, uname, cached: true)
    else
      RouteUtils.json_res(env, {dname: "Khách", power: 0})
    end
  end

  get "/api/logout" do |env|
    env.session.destroy
    env.redirect("/")
  end

  post "/api/login" do |env|
    email = env.params.json.fetch("email", "").as(String).strip
    upass = env.params.json.fetch("upass", "").as(String).strip

    if uname = CV::ViUser.validate(email, upass)
      dname = ViUser._index.fval(uname).not_nil!
      RouteUtils.user_res(env, dname, cached: false)
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

    CV::ViUser.insert!(dname, email, upass)
    RouteUtils.user_res(env, dname, cached: false)
  rescue err
    halt env, status_code: 400, response: err.message
  end
end
