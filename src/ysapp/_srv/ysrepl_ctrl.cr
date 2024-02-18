require "./_ys_ctrl_base"

class YS::YsreplCtrl < AC::Base
  base "/_ys/repls"

  @[AC::Route::GET("/:crit_id")]
  def repls(crit_id : Int32)
    _, limit, offset = _paginate(min: 50, max: 200)
    repls = YsreplPeek.fetch_all(crit_id, limit, offset)
    render json: repls
  end

  @[AC::Route::GET("/:crit_id/ztext")]
  def ztext(id : Int32)
    guard_privi 1, "xem text gốc phản hồi"
    response.headers["X-PDICT"] = "combine"
    ztext = YsreplPeek.get_ztext(id)
    render text: ztext
  end
end
