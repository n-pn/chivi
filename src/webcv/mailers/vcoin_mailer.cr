require "./base_mailer"

class CV::UvcoinMailer < CV::BaseMailer
  def initialize(uvcoin : Uvcoin)
    receiver = uvcoin.receiver
    to email: receiver.email, name: receiver.uname
    subject "Bạn nhận được #{uvcoin.amount} vcoin"

    html <<-HTML
      <p>Thông báo từ Chivi</p>
      <p>Bạn nhận được: <strong>#{uvcoin.amount}</strong> vcoin từ #{uvcoin.sender.uname}.</p>
      <p>Chú thích người tặng: #{uvcoin.reason}</p>
      <p>Bạn có thể dùng vcoin để nâng cấp quyền hạn, để tăng trải nghiệm dùng Chivi.</p>
    HTML
  end
end
