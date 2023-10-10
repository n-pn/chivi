require "../_ctrl_base"

class CV::XvcoinCtrl < CV::BaseCtrl
  base "/_db/vcoins"

  @[AC::Route::GET("/")]
  def index(vu_id : Int32? = nil)
    vu_id = _vu_id if _privi < 3
    pg_no, limit, offset = _paginate(min: 50)

    xlogs_query = Xvcoin.build_select_sql(vu_id)

    args = [limit, offset] of Int32
    args << vu_id if vu_id

    xlogs = Xvcoin.db.query_all(xlogs_query, args: args, as: Xvcoin)

    if xlogs.size < limit
      total = offset &+ xlogs.size
    else
      args[0] = limit &* 3
      total = offset &+ Xvcoin.db.query_all(xlogs_query, args: args, as: Xvcoin).size
    end

    vu_ids = Set(Int32).new
    xlogs.each { |x| vu_ids << x.sender_id << x.target_id }

    output = {
      xlogs: xlogs,
      users: ViuserView.as_hash(Viuser.preload(vu_ids)),

      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }

    render json: output
  end

  struct VcoinForm
    include JSON::Serializable

    getter target : String
    getter reason : String
    getter amount : Float64

    getter? as_admin : Bool = false

    def after_initialize
      @target = @target.strip
      @amount = @amount.round(2)
      @amount = 0.01 if @amount < 0.01
    end
  end

  @[AC::Route::POST("/", body: :form)]
  def send_vcoin(form : VcoinForm)
    if form.target.starts_with?("ID ")
      user_id = form.target.sub(/^ID\s*/, "").strip.to_i
      target = Viuser.find({id: user_id})
    else
      target = Viuser.find_any(form.target)
    end

    raise BadRequest.new("Người bạn muốn tặng vcoin không tồn tại") unless target

    if _viuser.privi > 3 && form.as_admin?
      sender = Viuser.load!(-1) # sender is admin
    elsif _viuser.vcoin >= form.amount
      sender = _viuser
    else
      raise BadRequest.new("Số vcoin khả dụng của bạn ít hơn số vcoin bạn muốn tặng")
    end

    Clear::SQL.transaction do
      sender.update(vcoin: sender.vcoin - form.amount)
      target.update(vcoin: target.vcoin + form.amount)

      xlog = Xvcoin.new(
        kind: form.as_admin? ? 60 : 0,
        sender_id: sender.id,
        target_id: target.id,
        target_name: form.target,
        amount: form.amount,
        reason: form.reason,
      ).insert!

      spawn send_vcoin_notification(sender, target, xlog)
    end

    _log_action("send-vcoin", form)

    render json: {target: target.uname, remain: _viuser.vcoin}
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
