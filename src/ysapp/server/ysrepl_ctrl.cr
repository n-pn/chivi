require "./_ys_ctrl_base"

class YS::YsreplCtrl < AC::Base
  base "/_ys/repls"

  @[AC::Route::GET("/:crit_id")]
  def repls(crit_id : Int32)
    render json: YsreplPeek.fetch_all(crit_id)
  end

  @[AC::Route::GET("/ztext/:id")]
  def ztext(id : Int32)
    response.headers["X-WN_ID"] = "0"
    render text: YsreplPeek.get_ztext(id)
  end
end
