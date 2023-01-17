require "./_ys_ctrl_base"

class YS::ReplCtrl < AC::Base
  base "/_ys"

  @[AC::Route::GET("/crits/:crit/repls")]
  def index(crit : String, pg pg_no : Int32 = 1, lm limit : Int32 = 25)
    crit_id = HashUtil.decode32(crit)
    repls = Ysrepl.query.where("yscrit_id = ?", crit_id)

    limit, offset = _paged(pg_no, limit, max: 50)
    repls = repls.limit(limit).offset(offset)

    render json: repls.with_ysuser.map { |x| ReplView.new(x) }
  end

  @[AC::Route::GET("/repls/:id/ztext", converters: {id: ConvertBase32})]
  def ztext(id : Int64)
    yrepl = Ysrepl.find!({id: id})
    vdict = yrepl.vdict

    response.headers["X-DNAME"] = vdict.dname
    response.headers["X-BNAME"] = vdict.label

    render text: yrepl.ztext
  rescue err
    render :not_found, text: "Phản hồi không tồn tại"
  end
end
