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
    spawn run_after_upgrade_tasks(user.uname)
    spawn create_vcoin_xlog(user, vcoin_req, pdays)
  end

  private def run_after_upgrade_tasks(uname : String)
    Dir.mkdir_p("var/chaps/infos/@#{uname}")
    Dir.mkdir_p("var/texts/rzips/@#{uname}")

    CtrlUtil.log_user_action("upgrade-privi", self, uname)
  end

  private def create_vcoin_xlog(user : Viuser, vcoin_req : Int32, pdays : Int32)
    xlog = VcoinXlog.new({
      kind:        10,
      sender_id:   user.id,
      target_id:   -1,
      target_name: "Chivi",
      amount:      vcoin_req,
      reason:      "Nâng cấp quyền hạn Chivi lên #{@privi} trong #{pdays} ngày.",
    })

    xlog.save!

    send_notification(xlog, user, vcoin_req)
  end

  private def send_notification(xlog : VcoinXlog, user : Viuser, vcoin_req : Int32)
    content, details, link_to = gen_ugprivi_notif(xlog, user, vcoin_req)

    Unotif.new(
      viuser_id: user.id,
      action: :privi_ug, object_id: xlog.id, byuser_id: -1,
      content: content, details: details.to_json, link_to: link_to
    ).create!

    MailUtil.send(to: user.email, name: user.uname) do |mail|
      mail.subject "Chivi: Nâng cấp quyền hạn thành công"
      mail.message_html content
    end
  end

  private def gen_ugprivi_notif(xlog, user, vcoin_req)
    content = String.build do |io|
      io << "<p><strong>Bạn đã cập nhật/gia hạn quyền hạn #{@privi} thành công.</strong></p>\n"

      {3, 2, 1}.each do |privi|
        time = Time.unix(user.current_privi_until(privi))
        next if privi > user.privi || time < Time.utc

        io << <<-HTML
          <p>Quyền hạn #{privi} của bạn có hiệu lực đến #{time.to_s("ngày %d-%m-%Y lúc %H:%M:%S")}.</p>
        HTML
      end
    end

    details = {_type: "privi_ug", privi: @privi, range: @range, vcoin: vcoin_req}
    link_to = "/me/vcoin-xlog#id-#{xlog.id}"

    {content, details, link_to}
  end
end
