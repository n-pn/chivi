class CV::UsercpCtrl < CV::BaseCtrl
  def profile
    set_cache :private, maxage: 3
    _viuser.check_privi! unless _viuser.privi < 0
    # save_current_user!(_viuser)
    serv_json(ViuserView.new(_viuser, true))
  end

  def upgrade_privi
    privi = params.read_int("privi", min: 1, max: 3)
    tspan = params.read_int("tspan", min: 0, max: 3)
    _viuser.upgrade!(privi, tspan)

    spawn do
      body = {privi: privi, tspan: tspan}
      CtrlUtil.log_user_action("upgrade-privi", body, _viuser.uname)
    end

    sname = "@" + _viuser.uname
    unless ChSeed.has_sname?(sname)
      sn_id = _viuser.id * 2
      ChSeed.add_user(sname, sn_id)
    end

    save_current_user!(_viuser)
    serv_json(ViuserView.new(_viuser, true))
  rescue err
    halt! 403, "Bạn chưa đủ số vcoin tối thiểu để tăng quyền hạn!"
  end

  def send_vcoin
    amount = params.read_int("amount", min: 1)
    reason = params.read_str("reason").strip

    unless sendee = Viuser.find_any(params["sendee"])
      raise BadRequest.new("Người bạn muốn tặng vcoin không tồn tại")
    end

    if _viuser.privi > 3 && params["as_admin"]? == "true"
      sender = Viuser.load!(-1) # sender is admin
    elsif _viuser.vcoin_avail >= amount
      sender = _viuser
    else
      raise BadRequest.new("Số vcoin khả dụng của bạn ít hơn số vcoin bạn muốn tặng")
    end

    spawn do
      body = {sendee: sendee.uname, amount: amount, reason: reason}
      CtrlUtil.log_user_action("send-vcoin", body, _viuser.uname)
    end

    Clear::SQL.transaction do
      sender.update(vcoin_avail: sender.vcoin_avail - amount)
      sendee.update(vcoin_avail: sendee.vcoin_avail + amount)

      VcoinXlog.new(sender: sender.id, sendee: sendee.id, amount: amount, reason: reason).create!

      sender.cache!
      sendee.cache!

      spawn VcoinReceiveMailer.new(sender, sendee, amount, reason).deliver
    end

    serv_json({sendee: sendee.uname, remain: _viuser.vcoin_avail})
  end

  ##################

  def update_config
    if _viuser.privi >= 0
      wtheme = params.read_str("wtheme", "light")
      cookies["theme"] = wtheme
      save_session!

      _viuser.update!({wtheme: wtheme})
    end

    serv_json(ViuserView.new(_viuser, true))
  end

  def update_passwd
    raise "Quyền hạn không đủ" if _viuser.privi < 0

    oldpw = params.read_str("oldpw").strip
    raise "Mật khẩu cũ không đúng" unless _viuser.authentic?(oldpw)

    newpw = params.read_str("newpw").strip
    raise "Mật khẩu mới quá ngắn" if newpw.size < 8

    _viuser.upass = newpw
    _viuser.save!

    spawn do
      body = {email: _viuser.email, cpass: _viuser.cpass}
      CtrlUtil.log_user_action("change-pass", body, _viuser.uname)
    end

    serv_text("Đổi mật khẩu thành công", 201)
  rescue err
    raise BadRequest.new(err.message)
  end

  ################

  def replied
    _pgidx, limit, offset = params.page_info(min: 10)
    user_id = _viuser.id

    query = Cvrepl.query.order_by(id: :desc)
    query.where("state >= 0 AND viuser_id != ?", user_id)
    query.where("(repl_viuser_id = ? OR tagged_ids @> ?::bigint[])", user_id, [user_id])

    query.with_cvpost.with_viuser
    query.limit(limit).offset(offset)

    items = query.to_a
    memos = UserRepl.glob(_viuser, items.map(&.id))

    set_cache :private, maxage: 3
    serv_json(items.map { |x| CvreplView.new(x, full: true, memo: memos[x.id]?) })
  end

  def mark_post
    return serv_text("Bạn cần đăng nhập", 403) if _viuser.privi < 0

    cvpost = Cvpost.load!(params["post_ii"])
    target = UserPost.find_or_new(_viuser.id, cvpost.id)

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
    return serv_text("Bạn cần đăng nhập", 403) if _viuser.privi < 0

    cvrepl = Cvrepl.load!(params["repl_id"].to_i64)
    target = UserRepl.find_or_new(_viuser.id, cvrepl.id)

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
