require "../_ctrl_base"

class CV::VcoinXlogCtrl < CV::BaseCtrl
  base "/_db/vcoins"

  @[AC::Route::GET("/")]
  def index(vu_id : Int32? = nil)
    vu_id = _vu_id if _privi < 3
    pg_no, limit, offset = _paginate(min: 50)

    entries = VcoinXlog.query.order_by(id: :desc)
    # entries.where("kind >= 0")
    entries.where("(sender_id = ? or receiver_id = ?)", vu_id, vu_id) if vu_id

    total = entries.dup.count
    entries = entries.limit(limit).offset(offset).to_a

    user_ids = Set(Int32).new
    entries.each { |entry| user_ids << entry.sender_id << entry.receiver_id }
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

    getter receiver : String
    getter reason : String
    getter amount : Float64

    getter? as_admin : Bool = false

    def after_initialize
      @receiver = @receiver.strip
      @amount = @amount.round(2)
      @amount = 0.1 if @amount < 0.1
    end
  end

  @[AC::Route::POST("/", body: :form)]
  def send_vcoin(form : VcoinForm)
    unless receiver = Viuser.find_any(form.receiver)
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
      receiver.update(vcoin: receiver.vcoin + form.amount)

      VcoinXlog.new({
        kind:          form.as_admin? ? 2 : 1,
        sender_id:     sender.id,
        receiver_id:   receiver.id,
        receiver_name: form.receiver,
        amount:        form.amount,
        reason:        form.reason,
      }).save!

      sender.cache!
      receiver.cache!

      spawn send_vcoin_receive_email(sender, receiver, form.amount, form.reason)
    end

    spawn CtrlUtil.log_user_action("send-vcoin", form, _viuser.uname)
    render json: {receiver: receiver.uname, remain: _viuser.vcoin}
  end

  private def send_vcoin_receive_email(sender : Viuser, receiver : Viuser, amount : Float64, reason : String)
    MailUtil.send(to: receiver.email, name: receiver.uname) do |mail|
      mail.subject "Chivi: Bạn nhận được #{amount} vcoin"

      mail.message_html <<-HTML
        <h2>Thông báo từ Chivi:</h2>
        <p>Bạn nhận được: <strong>#{amount}</strong> vcoin từ <strong>#{sender.uname}</strong>.</p>
        <p>Chú thích của người tặng: #{reason}</p>
        <p>Bạn có thể vào <a href="https://chivi.app/hd/tat-ca-ve-vcoin">Tất cả về Vcoin</a>
          để tìm hiểu các cách dùng của vcoin.</p>
      HTML
    end
  end
end
