require "./base_ctrl"

class CV::UserCtrl < CV::BaseCtrl
  def _self
    return_user
  rescue err
    puts err
    render_json({
      uname:  "Khách",
      privi:  -1,
      wtheme: "light",
      tlmode: "0",
    })
  end

  def logout
    @_cv_user = nil

    session.delete("cu_dname")
    session.delete("cu_privi")
    session.delete("cu_tlmode")
    session.delete("cu_wtheme")

    save_session!
    render_json([1])
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

  def passwd
    raise "Quyền hạn không đủ" if _cv_user.privi < 0

    wtheme = params.fetch_str("wtheme", "light")
    tlmode = params.fetch_int("tlmode", min: 0, max: 2)

    old_upass = params.fetch_str("old_pass").strip
    puts ["old pass: ", old_upass]

    raise "Mật khẩu cũ không đúng" unless _cv_user.authentic?(old_upass)

    new_upass = params.fetch_str("new_pass").strip
    confirmation = params.fetch_str("confirm_pass").strip
    raise "Mật khẩu mới quá ngắn" unless new_upass.size >= 7
    raise "Mật khẩu không trùng khớp" unless new_upass == confirmation

    _cv_user.upass = new_upass
    _cv_user.save!
    render_json([1])
  rescue err
    halt!(400, err.message)
  end

  private def sigin_user!(user : Cvuser)
    @_cv_user = user
    session["cu_dname"] = user.uname
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
