require "json"
require "../_ctrl_base"
require "../../../_util/mail_util"

struct CV::UgpriviForm
  include JSON::Serializable

  getter privi : Int32
  getter range : Int32

  def after_initialize
    @privi = 3 if @privi > 3
    @privi = 1 if @privi < 1

    @range = 3 if @range > 3
    @range = 0 if @range < 0
  end

  def do_upgrade!(user : Viuser, persist : Bool = true)
    vcoin_req, pdays = user.upgrade_privi!(@privi, @range, persist: persist)

    spawn record_action!(user, vcoin_req, pdays)
  end

  private def record_action!(user : Viuser, vcoin_req : Int32, pdays : Int32)
    xlog = Xvcoin.new({
      kind: :privi_ug, sender_id: user.id, target_id: -1,
      amount: vcoin_req, reason: "Nâng cấp quyền hạn Chivi lên #{@privi} trong #{pdays} ngày.",
    })

    xlog.insert!

    content = String.build do |io|
      io << <<-HTML
        <p><strong>Bạn đã nâng cấp/gia hạn quyền hạn #{@privi} <a href="/me/vcoin-xlog#id-#{xlog.id}">thành công</a>.</strong></p>
        <p>Bạn đã mất #{vcoin_req} vcoin để quyền hạn mới có hiệu lực thêm trong vòng #{pdays} ngày.
        HTML

      {3, 2, 1}.each do |privi|
        time = Time.unix(user.current_privi_until(privi))
        next if privi > @privi || time < Time.utc

        io << <<-HTML
          <p>Quyền hạn #{privi} của bạn có hiệu lực đến #{time.to_s("ngày %d-%m-%Y lúc %H:%M:%S")}.</p>
          HTML
      end
    end

    Unotif.new(
      viuser_id: user.id, content: content,
      action: :privi_upgrade, object_id: xlog.id, byuser_id: -1,
    ).insert!

    MailUtil.send(to: user.email, name: user.uname) do |mail|
      mail.subject "Chivi: Nâng cấp quyền hạn thành công"
      mail.message_html content
    end
  end
end
