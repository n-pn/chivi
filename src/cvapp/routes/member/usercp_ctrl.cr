require "../_ctrl_base"
require "../../../_util/mail_util"

class CV::UsercpCtrl < CV::BaseCtrl
  base "/_db/_self"

  @[AC::Route::GET("/")]
  def profile
    _viuser.check_privi!
    response.headers["Cache-Control"] = "private, max-age=5, stale-while-revalidate"

    save_current_user!(_viuser)
    render json: ViuserView.new(_viuser, true)
  end

  struct PriviForm
    include JSON::Serializable

    getter privi : Int32
    getter tspan : Int32
  end

  @[AC::Route::PUT("/upgrade-privi", body: :form)]
  def upgrade_privi(form : PriviForm)
    _viuser.upgrade!(form.privi, form.tspan)

    spawn do
      CtrlUtil.log_user_action("upgrade-privi", form, _viuser.uname)

      # sname = "@" + _viuser.uname
      # unless ChSeed.has_sname?(sname)
      #   sn_id = _viuser.id * 2
      #   ChSeed.add_user(sname, sn_id)
      # end
    end

    save_current_user!(_viuser)
    render json: ViuserView.new(_viuser, true)
  rescue err
    render :forbidden, "Bạn chưa đủ số vcoin tối thiểu để tăng quyền hạn!"
  end

  struct VcoinForm
    include JSON::Serializable

    getter sendee : String
    getter reason : String
    getter amount : Int32

    getter? as_admin : Bool = false
  end

  @[AC::Route::PUT("/send-vcoin", body: :form)]
  def send_vcoin(form : VcoinForm)
    unless sendee = Viuser.find_any(form.sendee)
      raise BadRequest.new("Người bạn muốn tặng vcoin không tồn tại")
    end

    if _viuser.privi > 3 && form.as_admin?
      sender = Viuser.load!(-1) # sender is admin
    elsif _viuser.vcoin_avail >= form.amount
      sender = _viuser
    else
      raise BadRequest.new("Số vcoin khả dụng của bạn ít hơn số vcoin bạn muốn tặng")
    end

    Clear::SQL.transaction do
      sender.update(vcoin_avail: sender.vcoin_avail - form.amount)
      sendee.update(vcoin_avail: sendee.vcoin_avail + form.amount)

      VcoinXlog.new(sender: sender.id, sendee: sendee.id, amount: form.amount, reason: form.reason).create!

      sender.cache!
      sendee.cache!

      spawn send_vcoin_receive_email(sender, sendee, form.amount, form.reason)
    end

    spawn CtrlUtil.log_user_action("send-vcoin", form, _viuser.uname)
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
    if _viuser.privi >= 0
      wtheme = params["wtheme"]? || "light"
      cookies["theme"] = wtheme
      _viuser.update!({wtheme: wtheme})
    end

    render json: ViuserView.new(_viuser, true)
  end

  @[AC::Route::PUT("/passwd")]
  def update_passwd
    raise "Quyền hạn không đủ" if _viuser.privi < 0

    oldpw = params["oldpw"].strip
    raise "Mật khẩu cũ không đúng" unless _viuser.authentic?(oldpw)

    newpw = params["newpw"].strip
    raise "Mật khẩu mới quá ngắn" if newpw.size < 8

    _viuser.upass = newpw
    _viuser.save!

    spawn do
      body = {email: _viuser.email, cpass: _viuser.cpass}
      CtrlUtil.log_user_action("change-pass", body, _viuser.uname)
    end

    render :accepted, text: "Đổi mật khẩu thành công"
  rescue err
    raise BadRequest.new(err.message)
  end

  ################

  @[AC::Route::GET("/replied")]
  def replied(pg pg_no : Int32 = 1, lm limit : Int32 = 10)
    offset = CtrlUtil.offset(pg_no, limit)
    user_id = _viuser.id

    query = Cvrepl.query.order_by(id: :desc)
    query.where("state >= 0 AND _viuser_id != ?", user_id)
    query.where("(repl_viuser_id = ? OR tagged_ids @> ?::bigint[])", user_id, [user_id])

    query.with_cvpost.with_viuser
    query.limit(limit).offset(offset)

    items = query.to_a
    memos = UserRepl.glob(user_id, _viuser.privi, items.map(&.id))

    render json: {
      items: items.map { |x| CvreplView.new(x, full: true, memo: memos[x.id]?) },
    }
  end
end
