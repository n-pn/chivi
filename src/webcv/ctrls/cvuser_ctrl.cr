require "./_base_ctrl"

class CV::CvuserCtrl < CV::BaseCtrl
  def login
    email = params["email"].strip
    upass = params["upass"].strip

    if user = Cvuser.validate(email, upass)
      login_user!(user)
    else
      halt!(403, "Thông tin đăng nhập không chính xác!")
    end
  end

  def signup
    email = params["email"].strip
    dname = params["dname"].strip
    upass = params["upass"].strip

    cvuser = Cvuser.create!(email, dname, upass)
    login_user!(cvuser)
  rescue err
    halt!(400, err.message)
  end

  def update
    if _cvuser.privi >= 0
      wtheme = params.fetch_str("wtheme", "light")
      _cvuser.update!({wtheme: wtheme})
    end

    send_json(CvuserView.new(_cvuser))
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

    send_json("Đổi mật khẩu thành công", 201)
  rescue err
    halt!(400, err.message)
  end

  def logout
    @_cvuser = nil
    session.delete("uname")
    save_session!
    send_json("Đã đăng xuất")
  end

  private def login_user!(user : Cvuser)
    @_cvuser = user
    session["uname"] = user.uname
    save_session!
    send_json(CvuserView.new(user))
  end
end
