require "./base_mailer"

class CV::ExchVcoinMailer < CV::BaseMailer
  def initialize(exchange : ExchVcoin)
    receiver = exchange.receiver
    to email: receiver.email, name: receiver.uname
    subject "Bạn nhận được #{exchange.amount} vcoin"

    html <<-HTML
      <p>Thông báo từ Chivi</p>
      <p>Bạn nhận được: <strong>#{exchange.amount}</strong> vcoin từ #{exchange.sender.uname}.</p>
      <p>Chú thích người tặng: #{exchange.reason}</p>
      <p>Bạn có thể dùng vcoin để nâng cấp quyền hạn, tăng trải nghiệm khi sử dụng Chivi.</p>
    HTML
  end
end
