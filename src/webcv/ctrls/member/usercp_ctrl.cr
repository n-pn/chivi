require "../_ctrl_base"
require "../../../_util/mail_util"

class CV::UsercpCtrl < CV::BaseCtrl
  base "/api/_self"

  getter viuser : Viuser { Viuser.load!(_viuser.id) }

  @[AC::Route::GET("/")]
  def profile
    viuser.check_privi! unless viuser.privi < 1

    save_current_user!(viuser)
    ViuserView.new(viuser, true)
  end

  @[AC::Route::PUT("/ugprivi")]
  @[AC::Route::PUT("/upgrade-privi")]
  def upgrade_privi(privi : Int32, tspan : Int32)
    # privi = params.read_int("privi", min: 1, max: 3)
    # tspan = params.read_int("tspan", min: 0, max: 3)
    viuser.upgrade!(privi, tspan)

    spawn do
      body = {privi: privi, tspan: tspan}
      CtrlUtil.log_user_action("upgrade-privi", body, _viuser.uname)
    end

    sname = "@" + viuser.uname
    unless ChSeed.has_sname?(sname)
      sn_id = viuser.id * 2
      ChSeed.add_user(sname, sn_id)
    end

    save_current_user!(viuser)
    render json: ViuserView.new(viuser, true)
  rescue err
    render :forbidden, "Bạn chưa đủ số vcoin tối thiểu để tăng quyền hạn!"
  end

  @[AC::Route::PUT("/send-vcoin")]
  def send_vcoin
    amount = params.read_int("amount", min: 1)
    reason = params.read_str("reason").strip

    unless sendee = Viuser.find_any(params["sendee"])
      raise BadRequest.new("Người bạn muốn tặng vcoin không tồn tại")
    end

    if viuser.privi > 3 && params["as_admin"]? == "true"
      sender = Viuser.load!(-1) # sender is admin
    elsif viuser.vcoin_avail >= amount
      sender = viuser
    else
      raise BadRequest.new("Số vcoin khả dụng của bạn ít hơn số vcoin bạn muốn tặng")
    end

    spawn do
      body = {sendee: sendee.uname, amount: amount, reason: reason}
      CtrlUtil.log_user_action("send-vcoin", body, viuser.uname)
    end

    Clear::SQL.transaction do
      sender.update(vcoin_avail: sender.vcoin_avail - amount)
      sendee.update(vcoin_avail: sendee.vcoin_avail + amount)

      VcoinXlog.new(sender: sender.id, sendee: sendee.id, amount: amount, reason: reason).create!

      sender.cache!
      sendee.cache!

      spawn send_vcoin_receive_email(sender, sendee, amount, reason)
    end

    render json: {sendee: sendee.uname, remain: _viuser.vcoin_avail}
  end

  private def send_vcoin_receive_email(sender : Viuser, sendee : Viuser, amount : Int32, reason : String)
    MailUtil.send(to: sendee.email, name: sendee.uname) do |mail|
      mail.subject "Chivi: Bạn nhận được #{amount} vcoin"

      mail.message_html <<-HTML
        <h2>Thông báo từ Chivi:</h2>
        <p>Bạn nhận được: <strong>#{amount}</strong> vcoin từ <strong>#{sender.uname}</strong>.</p>
        <p>Chú thích của người tặng: #{reason}</p>
        <p>Bạn có thể vào <a href="https://chivi.app/guide/vcoin">Tất cả về Vcoin</a>
          để tìm hiểu các cách dùng của vcoin.</p>
      HTML
    end
  end

  ##################

  @[AC::Route::PUT("/config")]
  def update_config
    if viuser.privi >= 0
      wtheme = params.read_str("wtheme", "light")
      cookies["theme"] = wtheme
      save_session!

      viuser.update!({wtheme: wtheme})
    end

    render json: ViuserView.new(viuser, true)
  end

  @[AC::Route::PUT("/passwd")]
  def update_passwd
    raise "Quyền hạn không đủ" if viuser.privi < 0

    oldpw = params.read_str("oldpw").strip
    raise "Mật khẩu cũ không đúng" unless viuser.authentic?(oldpw)

    newpw = params.read_str("newpw").strip
    raise "Mật khẩu mới quá ngắn" if newpw.size < 8

    viuser.upass = newpw
    viuser.save!

    spawn do
      body = {email: viuser.email, cpass: viuser.cpass}
      CtrlUtil.log_user_action("change-pass", body, viuser.uname)
    end

    render :accepted, text: "Đổi mật khẩu thành công"
  rescue err
    raise BadRequest.new(err.message)
  end

  ################

  @[AC::Route::GET("/replied")]
  def replied(pg pg_no = 1, lm limit = 10)
    offset = CtrlUtil.offset(pg_no, limit)
    user_id = viuser.id

    query = Cvrepl.query.order_by(id: :desc)
    query.where("state >= 0 AND viuser_id != ?", user_id)
    query.where("(repl_viuser_id = ? OR tagged_ids @> ?::bigint[])", user_id, [user_id])

    query.with_cvpost.with_viuser
    query.limit(limit).offset(offset)

    render json: {
      items: query.map { |x| CvreplView.new(x, full: true) },
      memos: UserRepl.glob(viuser, items.map(&.id)).map { |x| {x.cvrepl_id, x} }.to_h,
    }
  end
end
