require "./_ys_ctrl_base"

class YS::YsreplCtrl < AC::Base
  base "/_ys/repls"

  @[AC::Route::GET("/:crit_id")]
  def repls(crit_id : Int32)
    _, limit, offset = _paginate(min: 50, max: 200)
    repls = YsreplPeek.fetch_all(crit_id, limit, offset)
    render json: repls
  end

  @[AC::Route::GET("/ztext/:id")]
  def ztext(id : Int32)
    response.headers["X-WN_ID"] = "0"
    ztext = YsreplPeek.get_ztext(id)

    render text: ztext
  end
end
