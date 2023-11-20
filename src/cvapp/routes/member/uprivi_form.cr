require "json"
require "../_ctrl_base"
require "../../../_util/mail_util"

struct CV::UpriviForm
  include JSON::Serializable

  getter privi : Int32
  getter pdura : Int32

  def after_initialize
    case @privi
    when .< 0 then @privi = 0
    when .> 3 then @privi = 3
    end

    case @pdura
    when .< 0 then @pdura = 0
    when .> 3 then @pdura = 3
    end
  end

  DURA = {14, 30, 60, 90}

  COST = {
    {7, 15, 30, 45},     # privi 0
    {20, 40, 75, 100},   # privi 1
    {40, 80, 150, 210},  # privi 2
    {80, 160, 300, 420}, # privi 3
  }

  def do_upgrade!(vu_id : Int32)
    vcoin_req = COST[@privi][@pdura]
    dura_days = DURA[@pdura]

    viuser = Viuser.load!(vu_id)
    raise "Lượng vcoin không đủ!" if vcoin_req > viuser.vcoin

    uprivi = Uprivi.load!(vu_id)
    uprivi.extend_privi!(@privi.to_i16, dura_days)
    uprivi.upsert!

    viuser.vcoin -= vcoin_req
    viuser.privi = uprivi.p_now
    viuser.p_exp = uprivi.p_exp
    viuser.save!

    spawn record_action!(viuser, uprivi, vcoin_req, dura_days)
    viuser
  end

  private def record_action!(viuser : Viuser, uprivi : Uprivi, vcoin_req : Int32, dura_days : Int32)
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

      3.downto(0) do |privi|
        time = Time.unix(uprivi.exp_a[privi])
        next if time < Time.utc

        io << <<-HTML
          <p>Quyền hạn #{privi} của bạn có hiệu lực đến #{time.to_s("%H giờ %M phút ngày %d-%m-%Y")}.</p>
          HTML
      end
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
