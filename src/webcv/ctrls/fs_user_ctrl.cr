require "./base_ctrl"

class CV::FsUserCtrl < CV::BaseCtrl
  def _self
    return_user
  end

  def logout
    session.delete("cu_uname")
    return_user
  end

  def login
    email = params.fetch_str("email").strip
    upass = params.fetch_str("upass").strip

    if uname = ViUser.validate(email, upass)
      dname = ViUser._index.fval(uname).not_nil!
      sigin_user!(dname)
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
    sigin_user!(dname)
    return_user
  rescue err
    halt!(400, err.message)
  end

  def update
    if cu_privi >= 0
      wtheme = params.fetch_str("wtheme", "light")
      tlmode = params.fetch_int("tlmode", min: 0, max: 2)

      ViUser.wtheme.set!(cu_uname, wtheme)
      ViUser.tlmode.set!(cu_uname, tlmode)

      session["cu_wtheme"] = wtheme
      session["cu_tlmode"] = tlmode

      ViUser.save!
    end

    return_user
  end

  private def sigin_user!(dname : String, uname = dname.downcase,
                          power = ViUser.get_power(uname))
    session["cu_uname"] = dname
    session["cu_privi"] = power
    session["cu_wtheme"] = ViUser.get_wtheme(uname)
    session["cu_tlmode"] = ViUser.get_tlmode(uname)
  end

  private def return_user(uname = cu_dname,
                          privi = cu_privi,
                          wtheme = cu_wtheme,
                          tlmode = cu_tlmode)
    save_session!
    render_json({uname: uname, privi: privi, wtheme: wtheme, tlmode: tlmode})
  end
end
