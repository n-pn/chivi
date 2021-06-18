require "./base_ctrl"

class CV::UserCtrl < CV::BaseCtrl
  def _self
    return_user
  end

  def logout
    session.delete("cu_uname")
    render_json({msg: "ok"})
  end

  def login
    email = params.fetch_str("email").strip
    upass = params.fetch_str("upass").strip

    if uname = ViUser.validate(email, upass)
      dname = ViUser._index.fval(uname).not_nil!
      session["cu_uname"] = dname
      return_user
    else
      halt!(403, "Thông tin đăng nhập không chính xác!")
    end
  end

  def signup
    email = params.fetch_str("email").strip
    dname = params.fetch_str("dname").strip
    upass = params.fetch_str("email").strip

    raise "Địa chỉ hòm thư quá ngắn" if email.size < 3
    raise "Địa chỉ hòm thư không hợp lệ" if email !~ /@/
    raise "Tên người dùng quá ngắn (cần ít nhất 5 ký tự)" if dname.size < 5
    raise "Tên người dùng không hợp lệ" unless dname =~ /^[\p{L}\p{N}\s_]+$/
    raise "Mật khẩu quá ngắn (cần ít nhất 7 ký tự)" if upass.size < 7

    ViUser.insert!(dname, email, upass)
    session["cu_uname"] = dname
    return_user
  rescue err
    halt!(400, err.message)
  end

  private def return_user
    render_json({dname: cu_uname, power: cu_privi})
  end
end
