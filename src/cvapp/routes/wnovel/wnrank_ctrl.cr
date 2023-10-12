require "../_ctrl_base"

class CV::WnrankCtrl < CV::BaseCtrl
  base "/_db/ranks"

  @[AC::Route::GET("/brief")]
  def brief
    query = Wninfo.query.where("shield < 2").limit(6)
    books = WninfoView.as_list(query.sort_by("access"))
    render json: books
  end
end
