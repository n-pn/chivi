require "./base_mailer"

class CV::PasswdMailer < CV::BaseMailer
  def initialize(user : Cvuser)
    user.set_pwtemp!

    to email: user.email, name: user.uname
    subject "Mật khẩu tạm thời đăng nhập chivi.app"

    html <<-HTML
      <p>Mật khẩu tạm thời của bạn là: <strong>#{user.pwtemp}</strong></p>
      <p>Mật khẩu này sẽ có hiệu lực trong 5 phút kể từ khi bạn yêu cầu đổi mật khẩu.</p>
      <p>Sau khi đăng nhập, hãy đổi lại mật khẩu cũ.</p>
    HTML
  end
end
