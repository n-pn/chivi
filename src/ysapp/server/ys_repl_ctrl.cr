require "./_ys_ctrl_base"

class YS::ReplCtrl < AC::Base
  base "/_ys"

  @[AC::Route::GET("/crits/:crit/repls")]
  def index(crit : Int32)
    _pg_no, limit, offset = _paginate(min: 25, max: 50)
    repls = Ysrepl.query.where("yscrit_id = ?", crit)

    repls = repls.limit(limit).offset(offset)

    render json: repls.with_ysuser.map { |x| ReplView.new(x) }
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
