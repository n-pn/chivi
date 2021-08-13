require "./base_ctrl"

class CV::UserCtrl < CV::BaseCtrl
  def _self
    return_user
  end

  def logout
    session.delete("cu_uname")
    @_cv_user = nil
    return_user
  end

  def login
    email = params.fetch_str("email").strip
    upass = params.fetch_str("upass").strip

    if user = Cvuser.validate(email, upass)
      sigin_user!(user)
      return_user(user)
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

    cvuser = Cvuser.new({email: email, uname: dname, upass: upass}).tap(&.save!)
    ViUser.insert!(dname, email, upass)
    sigin_user!(cvuser)
    return_user(cvuser)
  rescue err
    halt!(400, err.message)
  end

  def update
    if _cv_user.privi >= 0
      wtheme = params.fetch_str("wtheme", "light")
      tlmode = params.fetch_int("tlmode", min: 0, max: 2)

      session["cu_wtheme"] = wtheme
      session["cu_tlmode"] = tlmode

      _cv_user.update!({wtheme: wtheme, tlmode: tlmode})
    end

    return_user
  end

  private def sigin_user!(user : Cvuser)
    @_cv_user = user
    session["cu_uname"] = user.uname
    session["cu_privi"] = user.privi
    session["cu_wtheme"] = user.wtheme
    session["cu_tlmode"] = user.tlmode
  end

  private def return_user(user = _cv_user)
    save_session!
    render_json({
      uname:  user.uname,
      privi:  user.privi,
      wtheme: user.wtheme,
      tlmode: user.tlmode,
    })
  end
end
