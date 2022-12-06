require "./base_mailer"

class CV::VcoinReceiveMailer < CV::BaseMailer
  def initialize(sender : Viuser, sendee : Viuser, amount : Int32, reason : String)
    to email: sendee.email, name: sendee.uname
    subject "Bạn nhận được #{amount} vcoin"

    html <<-HTML
      <p>Thông báo từ Chivi</p>
      <p>Bạn nhận được: <strong>#{amount}</strong> vcoin từ #{sender.uname}.</p>
      <p>Chú thích người tặng: #{reason}</p>
      <p>Bạn có thể dùng vcoin để nâng cấp quyền hạn, tăng trải nghiệm khi sử dụng Chivi.</p>
    HTML
  end
end
