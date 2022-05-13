require "./_base_ctrl"

class CV::UsercpCtrl < CV::BaseCtrl
  def cv_user
    set_cache :private, maxage: 5
    send_json(CvuserView.new(_cvuser))
  end

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

  def upgrade
    privi = params.fetch_int("privi", min: 1, max: 3)
    tspan = params.fetch_int("tspan", min: 0, max: 3)
    _cvuser.upgrade!(privi, tspan)

    spawn do
      body = {privi: privi, tspan: tspan}
      CtrlUtil.log_user_action("upgrade-privi", body, _cvuser.uname)
    end

    send_json(CvuserView.new(_cvuser))
  rescue err
    halt! 403, "Bạn chưa đủ số vcoin tối thiểu để tăng quyền hạn!"
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
