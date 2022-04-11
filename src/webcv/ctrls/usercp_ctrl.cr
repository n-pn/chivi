require "./_base_ctrl"

class CV::UsercpCtrl < CV::BaseCtrl
  def cv_user
    set_cache :private, maxage: 5
    send_json(CvuserView.new(_cvuser))
  end

  def replied
    _pgidx, limit, offset = params.page_info(min: 10)
    user_id = _cvuser.id

    query = Cvrepl.query
      .where("state >= 0 AND cvuser_id != ?", user_id)
      .where("(repl_cvuser_id = ? OR tagged_ids @> ?::bigint[])", user_id, [user_id])
      .order_by(id: :desc)
      .with_cvpost.with_cvuser
      .limit(limit).offset(offset)

    set_cache :private, maxage: 5
    send_json(query.map { |x| CvreplView.new(x, full: true) })
  end

  def upgrade
    privi = params.fetch_int("privi", min: 1, max: 3)
    tspan = params.fetch_int("tspan", min: 0, max: 3)
    _cvuser.upgrade!(privi, tspan)
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
end
