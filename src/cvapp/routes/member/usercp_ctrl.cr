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
      CtrlUtil.log_user_action("upgrade-privi", form, _uname)

      Dir.mkdir_p("var/chaps/infos/@#{_uname}")
      Dir.mkdir_p("var/texts/rzips/@#{_uname}")

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
    getter amount : Float64

    getter? as_admin : Bool = false

    def after_initialize
      @amount = @amount.round(2)
      @amount = 0.1 if @amount < 0.1
    end
  end

  @[AC::Route::PUT("/send-vcoin", body: :form)]
  def send_vcoin(form : VcoinForm)
    unless sendee = Viuser.find_any(form.sendee)
      raise BadRequest.new("Người bạn muốn tặng vcoin không tồn tại")
    end

    if _viuser.privi > 3 && form.as_admin?
      sender = Viuser.load!(-1) # sender is admin
    elsif _viuser.vcoin >= form.amount
      sender = _viuser
    else
      raise BadRequest.new("Số vcoin khả dụng của bạn ít hơn số vcoin bạn muốn tặng")
    end

    Clear::SQL.transaction do
      sender.update(vcoin: sender.vcoin - form.amount)
      sendee.update(vcoin: sendee.vcoin + form.amount)

      VcoinXlog.new(sender: sender.id, sendee: sendee.id, amount: form.amount, reason: form.reason).create!

      sender.cache!
      sendee.cache!

      spawn send_vcoin_receive_email(sender, sendee, form.amount, form.reason)
    end

    spawn CtrlUtil.log_user_action("send-vcoin", form, _viuser.uname)
    render json: {sendee: sendee.uname, remain: _viuser.vcoin}
  end

  private def send_vcoin_receive_email(sender : Viuser, sendee : Viuser, amount : Float64, reason : String)
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

  record ConfigForm, wtheme : String = "light" do
    include JSON::Serializable
  end

  @[AC::Route::PUT("/config", body: :form)]
  def update_config(form : ConfigForm)
    guard_privi 0, "thay đổi giao diện"

    _viuser.update!({wtheme: form.wtheme})
    render text: "ok"
  end

  struct PasswdForm
    include JSON::Serializable

    getter oldpw : String
    getter newpw : String

    def after_initialize
      @oldpw = @oldpw.strip
      @newpw = @newpw.strip
    end

    def validate!(user : Viuser)
      raise BadRequest.new "Mật khẩu mới quá ngắn" if @newpw.size < 8
      raise BadRequest.new "Mật khẩu cũ không đúng" unless user.authentic?(@oldpw)
    end
  end

  @[AC::Route::PUT("/passwd", body: :form)]
  def update_passwd(form : PasswdForm)
    guard_privi 0, "đổi mật khẩu"

    form.validate!(_viuser)
    _viuser.tap(&.passwd = form.newpw).save!

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
