class CV::UsercpCtrl < CV::BaseCtrl
  def profile
    set_cache :private, maxage: 3
    serv_json(CvuserView.new(_cvuser))
  end

  def upgrade_privi
    privi = params.fetch_int("privi", min: 1, max: 3)
    tspan = params.fetch_int("tspan", min: 0, max: 3)
    _cvuser.upgrade!(privi, tspan)

    spawn do
      body = {privi: privi, tspan: tspan}
      CtrlUtil.log_user_action("upgrade-privi", body, _cvuser.uname)
    end

    serv_json(CvuserView.new(_cvuser))
  rescue err
    halt! 403, "Bạn chưa đủ số vcoin tối thiểu để tăng quyền hạn!"
  end

  def send_vcoin
    amount = params.fetch_int("amount", min: 1)
    reason = params.fetch_str("reason").strip

    receiver_name = params["receiver"].strip
    unless receiver = Cvuser.query.where("uname = ? OR email = ?", receiver_name, receiver_name).first
      raise BadRequest.new("Người bạn muốn tặng vcoin không tồn tại")
    end

    if _cvuser.privi > 3 && params["as_admin"]? == "true"
      sender = Cvuser.load!(-1) # sender is system
    elsif _cvuser.vcoin_avail >= amount
      sender = _cvuser
    else
      raise BadRequest.new("Số vcoin khả dụng của bạn ít hơn số vcoin bạn muốn tặng")
    end

    if sender.id == receiver.id
      raise BadRequest.new("Bạn không thể gửi vcoin cho chính mình")
    end

    Clear::SQL.transaction do
      sender.update(vcoin_avail: sender.vcoin_avail - amount)
      receiver.update(vcoin_avail: receiver.vcoin_avail + amount)
      Cvuser.cache_user(receiver)

      entry = Uvcoin.new({
        receiver: receiver, sender: sender,
        amount: amount, reason: reason,
      })
      entry.save!
    end

    spawn do
      body = {receiver: receiver_name, amount: amount, reason: reason}
      CtrlUtil.log_user_action("send-vcoin", body, _cvuser.uname)
    end

    serv_json({receiver: receiver.uname, remain: _cvuser.vcoin_avail})
  end

  ##################

  def update_config
    if _cvuser.privi >= 0
      wtheme = params.fetch_str("wtheme", "light")
      _cvuser.update!({wtheme: wtheme})
    end

    serv_json(CvuserView.new(_cvuser))
  end

  def update_passwd
    raise "Quyền hạn không đủ" if _cvuser.privi < 0

    oldpw = params.fetch_str("oldpw").strip
    raise "Mật khẩu cũ không đúng" unless _cvuser.authentic?(oldpw)

    newpw = params.fetch_str("newpw").strip
    raise "Mật khẩu mới quá ngắn" if newpw.size < 8

    _cvuser.upass = newpw
    _cvuser.save!

    spawn do
      body = {email: _cvuser.email, cpass: _cvuser.cpass}
      CtrlUtil.log_user_action("change-pass", body, _cvuser.uname)
    end

    serv_text("Đổi mật khẩu thành công", 201)
  rescue err
    raise BadRequest.new(err.message)
  end

  ################

  def replied
    _pgidx, limit, offset = params.page_info(min: 10)
    user_id = _cvuser.id

    query = Cvrepl.query.order_by(id: :desc)
    query.where("state >= 0 AND cvuser_id != ?", user_id)
    query.where("(repl_cvuser_id = ? OR tagged_ids @> ?::bigint[])", user_id, [user_id])

    query.with_cvpost.with_cvuser
    query.limit(limit).offset(offset)

    items = query.to_a
    memos = UserRepl.glob(_cvuser, items.map(&.id))

    set_cache :private, maxage: 3
    send_json(items.map { |x| CvreplView.new(x, full: true, memo: memos[x.id]?) })
  end

  def mark_post
    return serv_text("Bạn cần đăng nhập", 403) if _cvuser.privi < 0

    cvpost = Cvpost.load!(params["post_ii"])
    target = UserPost.find_or_new(_cvuser.id, cvpost.id)

    case params["action"]?
    when "like"
      return serv_text("Bạn đã ưa thích bài viết", 400) if target.liked

      cvpost.inc_like_count!(1)
      target.set_liked!(true)
      serv_json({like_count: cvpost.like_count})
    when "unlike"
      return serv_text("Bạn chưa ưa thích bài viết", 400) unless target.liked

      cvpost.inc_like_count!(-1)
      target.set_liked!(false)
      serv_json({like_count: cvpost.like_count})
    else
      serv_text("Hành động không được hỗ trợ", 400)
    end
  end

  def mark_repl
    return serv_text("Bạn cần đăng nhập", 403) if _cvuser.privi < 0

    cvrepl = Cvrepl.load!(params["repl_id"].to_i64)
    target = UserRepl.find_or_new(_cvuser.id, cvrepl.id)

    case params["action"]?
    when "like"
      return serv_text("Bạn đã ưa thích bình luận", 400) if target.liked

      cvrepl.inc_like_count!(1)
      target.set_liked!(true)
      serv_json({like_count: cvrepl.like_count})
    when "unlike"
      return serv_text("Bạn chưa ưa thích bình luận", 400) unless target.liked

      cvrepl.inc_like_count!(-1)
      target.set_liked!(false)
      serv_json({like_count: cvrepl.like_count})
    else
      serv_text("Hành động không được hỗ trợ", 400)
    end
  end
end
