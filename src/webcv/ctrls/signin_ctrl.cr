class CV::SigninCtrl < CV::BaseCtrl
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

  def log_in
    email = params["email"].strip
    upass = params["upass"].strip

    unless user = Cvuser.validate(email, upass)
      raise BadRequest.new("Thông tin đăng nhập không chính xác!")
    end

    login_user!(user)
  end

  private def login_user!(user : Cvuser)
    @_cvuser = user
    session["uname"] = user.uname
    save_session!
    serv_json(CvuserView.new(user))
  end

  def pwtemp
    email = params["email"].strip

    if user = Cvuser.find({email: email})
      PasswdMailer.new(user).deliver
    else
      Log.error { email + " not found!" }
    end

    serv_text("Đã gửi email")
  end

  def logout
    Cvuser.reset_cache(_cvuser)
    @_cvuser = nil
    session.delete("uname")
    save_session!
    serv_text("Đã đăng xuất", 201)
  end
end
