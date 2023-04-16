require "../_ctrl_base"

class CV::WnrankCtrl < CV::BaseCtrl
  base "/_db/ranks"

  @[AC::Route::GET("/brief")]
  def brief
    book_query = Wninfo.query.where("shield < 2").limit(6)

    render json: {
      recent: WninfoView.as_list(book_query.dup.sort_by("access")),
      update: WninfoView.as_list(book_query.dup.sort_by("update")),
      weight: WninfoView.as_list(book_query.dup.sort_by("weight")),
    }
  end
end
