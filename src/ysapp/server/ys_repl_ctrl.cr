require "./_ys_ctrl_base"

class YS::ReplCtrl < AC::Base
  base "/_ys"

  @[AC::Route::GET("/crits/:crit/repls")]
  def index(crit : Int32)
    pg_no, limit, offset = _paginate(min: 25, max: 50)
    repls = Ysrepl.query.where("yscrit_id = ?", crit).where("vhtml <> ''")

    total = repls.dup.limit(limit &* (pg_no &+ 2)).count

    repls = repls.limit(limit).offset(offset)
    users = Ysuser.preload(repls.map(&.ysuser_id))

    render json: {
      repls: ReplView.as_list(repls),
      users: UserView.as_hash(users),
      pgidx: pg_no,
      total: total,
      pgmax: _pgidx(limit, total),
    }
  end

  @[AC::Route::GET("/repls/:id/ztext")]
  def ztext(id : Int32)
    yrepl = Ysrepl.find!({id: id})
    response.headers["X-WN_ID"] = "0"
    render text: yrepl.ztext
  rescue err
    render :not_found, text: "Phản hồi không tồn tại"
  end
end
