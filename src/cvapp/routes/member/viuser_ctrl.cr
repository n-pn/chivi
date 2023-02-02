require "../_ctrl_base"
require "../../../_util/mail_util"

class CV::SigninCtrl < CV::BaseCtrl
  base "/_db/_user"

  @[AC::Route::GET("privi/:uname")]
  def privi(uname : String)
    render text: Viuser.load!(uname).privi
  end

  record SignupForm, email : String, uname : String, upass : String do
    include JSON::Serializable
  end

  @[AC::Route::POST("/signup", body: :form)]
  def signup(form : SignupForm)
    viuser = Viuser.create!(form.email.strip, form.uname.strip, form.upass.strip)

    body = {email: viuser.email, uname: viuser.uname, cpass: viuser.cpass}
    spawn CtrlUtil.log_user_action("user-signup", body, viuser)

    login_user!(viuser)
  rescue err
    raise BadRequest.new(err.message)
  end

  record LoginForm, email : String, upass : String do
    include JSON::Serializable
  end

  @[AC::Route::POST("/log-in", body: :form)]
  def log_in(form : LoginForm)
    unless user = validate_user(form.email, form.upass)
      raise BadRequest.new("Thông tin đăng nhập không chính xác!")
    end

    user.check_privi!
    login_user!(user)
  end

  DUMMY_PASS = Crypto::Bcrypt::Password.create("-", cost: 10)

  private def validate_user(email : String, upass : String)
    if user = Viuser.find({email: email})
      user.authentic?(upass) ? user : nil
    else
      DUMMY_PASS.verify(upass) # prevent timing attack
      nil
    end
  end

  private def login_user!(user : Viuser)
    save_current_user!(user)
    render json: ViuserView.new(user)
  end

  record PwtempForm, email : String do
    include JSON::Serializable

    def after_initialize
      @email = @email.strip
    end
  end

  @[AC::Route::POST("/pwtemp", body: :form)]
  def pwtemp(form : PwtempForm)
    if user = Viuser.find({email: form.email})
      user.set_pwtemp!
      send_pwtemp_email(user)
    end

    render :accepted, text: "Đã gửi email"
  end

  private def send_pwtemp_email(user : Viuser)
    MailUtil.send(to: user.email, name: user.uname) do |mail|
      mail.subject "Mật khẩu tạm thời đăng nhập chivi.app"
      mail.message_html <<-HTML
        <p>Mật khẩu tạm thời của bạn là: <strong>#{user.pwtemp}</strong></p>
        <p>Mật khẩu này sẽ có hiệu lực trong 5 phút kể từ khi bạn yêu cầu đổi mật khẩu.</p>
        <p>Sau khi đăng nhập, hãy đổi lại mật khẩu cũ.</p>
      HTML
    end
  end

  @[AC::Route::DELETE("/logout")]
  def logout
    session["uname"] = nil
    # cookies.delete("_user").try { |x| CurrentUser.delete(x.value) }

    render :accepted, text: "Đã đăng xuất"
  end
end
