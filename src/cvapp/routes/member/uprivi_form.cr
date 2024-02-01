require "json"
require "../_ctrl_base"
require "../../../_util/mail_util"

struct CV::UpriviForm
  include JSON::Serializable

  getter privi : Int16
  getter pdura : Int32

  getter auto_renew = false

  def after_initialize
    case @privi
    when .< 1 then @privi = 1
    when .> 4 then @privi = 4
    end

    case @pdura
    when .< 0 then @pdura = 0
    when .> 3 then @pdura = 3
    end
  end

  DURA = {14, 30, 60, 90}

  COST = {
    {0, 0, 0, 0, 0},     # privi 0
    {7, 15, 30, 45},     # privi 1
    {20, 40, 75, 100},   # privi 2
    {40, 80, 150, 210},  # privi 3
    {80, 160, 300, 420}, # privi 4
  }

  def do_upgrade!(vu_id : Int32)
    vcoin_req = COST[@privi][@pdura]
    dura_days = DURA[@pdura]

    viuser = Viuser.load!(vu_id)
    raise "Lượng vcoin không đủ!" if vcoin_req > viuser.vcoin

    pdata = Uprivi.extend!(vu_id, @privi, dura_days)

    viuser.vcoin -= vcoin_req

    if viuser.privi < @privi
      viuser.privi = @privi
      viuser.p_exp = pdata.first.p_til
    end

    viuser.save!

    spawn record_action!(viuser, pdata, vcoin_req, dura_days)
    viuser
  end

  private def record_action!(viuser : Viuser, pdata : Array(Uprivi), vcoin_req : Int32, dura_days : Int32)
    reason = "Nâng cấp quyền hạn Chivi lên #{@privi} trong #{dura_days} ngày."
    xvcoin = Xvcoin.new(
      kind: :privi_ug, sender_id: viuser.id, target_id: -1,
      amount: vcoin_req.to_f64, reason: reason, target_name: "Chivi",
    ).insert!

    content = String.build do |io|
      io << <<-HTML
        <p><strong>Bạn đã nâng cấp/gia hạn quyền hạn #{@privi} thành công.</strong></p>
        <p>Bạn đã mất #{vcoin_req} vcoin để quyền hạn mới có hiệu lực thêm trong vòng #{dura_days} ngày.
        HTML
    end

    Unotif.new(
      viuser_id: viuser.id, content: content,
      action: :privi_upgrade, object_id: xvcoin.id!, byuser_id: -1,
    ).insert!

    MailUtil.send(to: viuser.email, name: viuser.uname) do |mail|
      mail.subject "Chivi: Nâng cấp quyền hạn thành công"
      mail.message_html content
    end
  end
end
