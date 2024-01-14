require "../_ctrl_base"

struct CV::XvcoinForm
  include JSON::Serializable

  getter target : String
  getter reason : String = ""
  getter amount : Float64

  def after_initialize
    @target = @target.strip
    @amount = @amount.round(2)
    @amount = 0.01 if @amount < 0.01
  end

  def find_target
    if @target.starts_with?("ID")
      vu_id = @target.sub(/^ID[\s\:]/, "").strip.to_i
      Viuser.find({id: vu_id})
    else
      Viuser.find_any(@target)
    end
  end

  def exchange!(sender : Viuser, target : Viuser, xvkind : Int32 = 0)
    Clear::SQL.transaction do
      sender.update(vcoin: sender.vcoin - @amount)
      target.update(vcoin: target.vcoin + @amount)

      xlog = Xvcoin.new(
        kind: xvkind,
        sender_id: sender.id,
        target_id: target.id,
        target_name: @target,
        amount: @amount,
        reason: @reason,
      ).insert!

      spawn send_vcoin_notification(sender, target, xlog)
    end
  end

  private def send_vcoin_notification(sender : Viuser, target : Viuser, xlog : Xvcoin)
    content = <<-HTML
      <p>Bạn nhận được: <strong>#{xlog.amount}</strong> vcoin từ <strong>#{sender.uname}</strong>.</p>
      <p>Chú thích của người tặng: #{xlog.reason}</p>
      HTML

    Unotif.new(
      viuser_id: target.id, content: content,
      action: Unotif::Action::VcoinXchange,
      object_id: xlog.id!, byuser_id: sender.id,
    ).insert!

    MailUtil.send(to: target.email, name: target.uname) do |mail|
      mail.subject "Chivi: Bạn nhận được #{xlog.amount} vcoin"

      mail.message_html <<-HTML
        <h2>Thông báo từ Chivi:</h2>
        #{content}
        <p>Bạn có thể vào <a href="https://chivi.app/hd/tat-ca-ve-vcoin">Tất cả về Vcoin</a>
          để tìm hiểu các cách dùng của vcoin.</p>
      HTML
    end
  end
end
