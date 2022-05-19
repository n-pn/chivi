class CV::CvuserCtrl < CV::BaseCtrl
  def login
    email = params["email"].strip
    upass = params["upass"].strip

    unless user = Cvuser.validate(email, upass)
      raise BadRequest.new("Thông tin đăng nhập không chính xác!")
    end

    login_user!(user)
  end

  def signup
    email = params["email"].strip
    uname = params["uname"].strip
    upass = params["upass"].strip

    cvuser = Cvuser.create!(email, uname, upass)

    spawn do
      body = {email: email, uname: uname, cpass: cvuser.cpass}
      CtrlUtil.log_user_action("user-signup", body, uname)
    end

    login_user!(cvuser)
  rescue err
    raise BadRequest.new(err.message)
  end

  def update
    if _cvuser.privi >= 0
      wtheme = params.fetch_str("wtheme", "light")
      _cvuser.update!({wtheme: wtheme})
    end

    serv_json(CvuserView.new(_cvuser))
  end

  def pwtemp
    email = params["email"].strip

    if user = Cvuser.find_by_mail(email)
      PasswdMailer.new(user).deliver
    else
      Log.error { email + " not found!" }
    end

    serv_text("Đã gửi email")
  end

  def passwd
    raise "Quyền hạn không đủ" if _cvuser.privi < 0

    old_upass = params.fetch_str("old_pass").strip
    raise "Mật khẩu cũ không đúng" unless _cvuser.authentic?(old_upass)

    new_upass = params.fetch_str("new_pass").strip
    confirmation = params.fetch_str("confirm_pass").strip
    raise "Mật khẩu mới quá ngắn" unless new_upass.size >= 7
    raise "Mật khẩu không trùng khớp" unless new_upass == confirmation

    _cvuser.upass = new_upass
    _cvuser.save!

    spawn do
      body = {email: _cvuser.email, cpass: _cvuser.cpass}
      CtrlUtil.log_user_action("change-pass", body, _cvuser.uname)
    end

    serv_text("Đổi mật khẩu thành công", 201)
  rescue err
    raise BadRequest.new(err.message)
  end

  def logout
    @_cvuser = nil
    session.delete("uname")
    save_session!
    serv_text("Đã đăng xuất", 201)
  end

  private def login_user!(user : Cvuser)
    @_cvuser = user
    session["uname"] = user.uname
    save_session!
    serv_json(CvuserView.new(user))
  end
end
