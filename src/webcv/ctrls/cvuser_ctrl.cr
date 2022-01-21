require "./base_ctrl"

class CV::CvuserCtrl < CV::BaseCtrl
  def _self
    return_user
  end

  def logout
    @_cvuser = nil
    session.delete("u_dname")
    session.delete("u_privi")

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
    upass = params.fetch_str("upass").strip

    cvuser = Cvuser.create!(email, dname, upass)
    sigin_user!(cvuser)
    return_user(cvuser)
  rescue err
    halt!(400, err.message)
  end

  def update
    if u_privi >= 0
      wtheme = params.fetch_str("wtheme", "light")
      session["_wtheme"] = wtheme
      _cvuser.update!({wtheme: wtheme})
    end

    return_user
  end

  def passwd
    raise "Quyền hạn không đủ" if u_privi < 0

    old_upass = params.fetch_str("old_pass").strip
    raise "Mật khẩu cũ không đúng" unless _cvuser.authentic?(old_upass)

    new_upass = params.fetch_str("new_pass").strip
    confirmation = params.fetch_str("confirm_pass").strip
    raise "Mật khẩu mới quá ngắn" unless new_upass.size >= 7
    raise "Mật khẩu không trùng khớp" unless new_upass == confirmation

    _cvuser.upass = new_upass
    _cvuser.save!

    render_json([1])
  rescue err
    halt!(400, err.message)
  end

  private def sigin_user!(user : Cvuser)
    @_cvuser = user
    session["u_dname"] = user.uname
    session["u_privi"] = user.privi
    session["_wtheme"] = user.wtheme
  end

  private def return_user(user = _cvuser)
    save_session!

    render_json({
      uname:  user.uname,
      privi:  user.privi,
      wtheme: user.wtheme,
    })
  end
end
