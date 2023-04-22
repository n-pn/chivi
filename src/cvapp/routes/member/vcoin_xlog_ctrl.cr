require "../_ctrl_base"

class CV::VcoinXlogCtrl < CV::BaseCtrl
  base "/_db/vcoins"

  @[AC::Route::GET("/")]
  def index(vu_id : Int32? = nil)
    vu_id = _vu_id if _privi < 3
    pg_no, limit, offset = _paginate(min: 50)

    entries = VcoinXlog.query.order_by(id: :desc)
    # entries.where("kind >= 0")
    entries.where("(sender_id = ? or target_id = ?)", vu_id, vu_id) if vu_id

    total = entries.dup.count
    entries = entries.limit(limit).offset(offset).to_a

    user_ids = Set(Int32).new
    entries.each { |entry| user_ids << entry.sender_id << entry.target_id }
    viusers = Viuser.preload(user_ids)

    render json: {
      xlogs: entries,
      users: ViuserView.as_hash(viusers),
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }
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
      @amount = 0.1 if @amount < 0.1
    end
  end

  @[AC::Route::POST("/", body: :form)]
  def send_vcoin(form : VcoinForm)
    unless target = Viuser.find_any(form.target)
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
      target.update(vcoin: target.vcoin + form.amount)

      xlog = VcoinXlog.new({
        kind:        form.as_admin? ? 100 : 0,
        sender_id:   sender.id,
        target_id:   target.id,
        target_name: form.target,
        amount:      form.amount,
        reason:      form.reason,
      })

      xlog.save!

      sender.cache!
      target.cache!

      spawn send_vcoin_notification(sender, target, xlog)
    end

    _log_action("send-vcoin", form)

    render json: {target: target.uname, remain: _viuser.vcoin}
  end

  private def send_vcoin_notification(sender : Viuser, target : Viuser, xlog : VcoinXlog)
    content = <<-HTML
      <p>Bạn nhận được: <strong>#{xlog.amount}</strong> vcoin từ <strong>#{sender.uname}</strong>.</p>
      <p>Chú thích của người tặng: #{xlog.reason}</p>
      HTML

    Unotif.new(
      viuser_id: target.id, content: content,
      action: :vcoin_xchange, object_id: xlog.id, byuser_id: sender.id,
    ).create!

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
